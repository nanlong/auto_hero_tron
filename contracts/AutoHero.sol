pragma solidity >=0.4.23 <0.6.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/roles/WhitelistAdminRole.sol";
import "./library/Utils.sol";
import "./IAutoHeroStorage.sol";
import "./IAutoHeroBank.sol";
import "./AutoHeroStructure.sol";


contract AutoHero is Ownable, WhitelistAdminRole {
  using SafeMath for uint256;

  address public autoHeroStorageAddr;
  address public autoHeroBankAddr;

  IAutoHeroStorage public autoHeroStorage;
  IAutoHeroBank public autoHeroBank;

  uint256 private salt;
  mapping (uint => mapping (address => uint)) private topFissions;

  function setStorage(address _autoHeroStorage) public onlyOwner {
    autoHeroStorageAddr = _autoHeroStorage;
    autoHeroStorage = IAutoHeroStorage(_autoHeroStorage);
    autoHeroStorage.emitEvent("Storage", abi.encodePacked("setStorage", _autoHeroStorage));
  }

  function setBank(address _autoHeroBank) public onlyOwner {
    autoHeroBankAddr = _autoHeroBank;
    autoHeroBank = IAutoHeroBank(_autoHeroBank);
    autoHeroStorage.emitEvent("Bank", abi.encodePacked("setBank", _autoHeroBank));
  }

  // 设置推荐人
  function setReferrer(address userAddr, address referrerAddr) public onlyWhitelistAdmin {
    require(userAddr != referrerAddr);
    require(!autoHeroStorage.isUserExist(userAddr));
    AutoHeroStructure.User memory referrer = _getUser(referrerAddr);
    require(referrer.carCount > 0);

    autoHeroStorage.addUser(userAddr, referrerAddr);

    autoHeroStorage.addTotalUserCount(1);

    referrer.partnersCount = referrer.partnersCount.add(1);
    _updateUser(referrer);
  }

  // 买车
  function buyCar(uint256 carId) public payable {
    require(carId > 0);
    require(msg.value == autoHeroStorage.getCar(carId));
    require(!autoHeroStorage.isUserCarExist(msg.sender, carId));

    address userAddr = _msgSender();
    uint256 amount = msg.value;

    // 需要用户购买上级车才有资格
    if (carId != 1) {
      require(autoHeroStorage.isUserCarExist(userAddr, carId - 1));
    }

    // 如果用户不存在，则创建用户数据
    if (!autoHeroStorage.isUserExist(userAddr)) {
      autoHeroStorage.addTotalUserCount(1);
      autoHeroStorage.addUser(userAddr, address(0));
    }

    address mainToken = address(0);

    if (carId == 1) autoHeroStorage.addTotalCarOwnerCount(1);

    // 新增汽车
    uint256[] memory points = _generatePoints(userAddr);
    autoHeroStorage.addUserCar(userAddr, carId, points);
    autoHeroStorage.addTotalBalance(mainToken, amount);
    autoHeroStorage.addTotalUserCarCount(1);

    // 更新用户的汽车数量
    AutoHeroStructure.User memory user = _getUser(userAddr);
    user.carCount = user.carCount.add(1);
    _updateUser(user);

    // 更新点位用户列表
    autoHeroStorage.addPointUser(carId, 0, userAddr);

    // 设置用户的上一级车为永久运营
    if (carId > 1) {
      AutoHeroStructure.UserCar memory userCar = _getUserCar(userAddr, carId.sub(1));
      userCar.state = 2;
      _updateUserCar(userAddr, userCar);
    }

    // 更新推荐人的团队数量
    if (autoHeroStorage.isUserCarExist(user.referrer, carId)) {
      AutoHeroStructure.User memory referrer = _getUser(user.referrer);
      referrer.partnersCount = referrer.partnersCount.add(1);
      _updateUser(referrer);

      AutoHeroStructure.UserCar memory referrerCar = _getUserCar(user.referrer, carId);
      referrerCar.partnersCount = referrerCar.partnersCount.add(1);
      _updateUserCar(user.referrer, referrerCar);
    }

    // 计算奖池分配额和业绩分配额
    uint256 miniRatio;
    uint256 referrerRatio;
    uint256 denominator;
    (miniRatio, referrerRatio, denominator) = autoHeroStorage.getAssignRatio();

    if (!autoHeroStorage.getMiniOpended()) {
      miniRatio = 0;
      referrerRatio = denominator;
    }

    uint256 miniAmount = amount.mul(miniRatio).div(denominator);
    uint256 referrerAmount = amount.sub(miniAmount);

    // 奖池分配
    if (miniAmount > 0) {
      uint256 miniPhaseId = __getCurrentMiniPhaseId();
      uint256 miniPhaseAmount = autoHeroStorage.getMiniPhaseAmount(miniPhaseId);
      uint256 miniPhaseState = autoHeroStorage.getMiniPhaseState(miniPhaseId);
      autoHeroStorage.addMiniBalance(mainToken, miniAmount);
      autoHeroStorage.updateMiniPhase(miniPhaseId, miniPhaseAmount.add(miniAmount), miniPhaseState);
    }

    // 新增买车记录，用于业绩返还
    autoHeroStorage.addBuyCarRecord(userAddr, carId, msg.value, referrerAmount);

    // 通证转入到Bank合约
    Address.sendValue(Address.toPayable(autoHeroBankAddr), amount);
    autoHeroBank.addBalance(amount);
  }

  // 业绩发放
  function sendReceive(uint256 buyCarReceiveId) public onlyWhitelistAdmin {
    AutoHeroStructure.BuyCarRecord memory buyCarRecord = _getBuyCarRecord(buyCarReceiveId);
    require(buyCarRecord.state == 0);

    address mainToken = address(0);

    AutoHeroStructure.User memory user = _getUser(buyCarRecord.referrer);

    // 找不到推荐人的时候，业绩划转到奖池
    if (user.referrer == address(0)) {
      uint256 miniPhaseId = __getCurrentMiniPhaseId();
      uint256 miniPhaseAmount = autoHeroStorage.getMiniPhaseAmount(miniPhaseId);
      uint256 miniPhaseState = autoHeroStorage.getMiniPhaseState(miniPhaseId);
      autoHeroStorage.addMiniBalance(mainToken, buyCarRecord.referrerAmount);
      autoHeroStorage.updateMiniPhase(miniPhaseId, miniPhaseAmount.add(buyCarRecord.referrerAmount), miniPhaseState);

      buyCarRecord.count = buyCarRecord.count.add(1);
      buyCarRecord.state = 1;
      buyCarRecord.referrer = user.referrer;
      _updateBuyCarRecord(buyCarRecord);
      return;
    }

    AutoHeroStructure.User memory referrer = _getUser(user.referrer);
    AutoHeroStructure.UserCar memory referrerUserCar = _getUserCar(referrer.addr, buyCarRecord.carId);
    uint256 referrerUserCarPoint = referrerUserCar.points[referrerUserCar.pointsState.length];

    // 烧伤 || 冻结 || 受益人为上级
    if (
      autoHeroStorage.getBurned() && user.carCount > referrer.carCount ||
      referrerUserCar.state == 1 ||
      referrerUserCarPoint == 1
    ) {
      buyCarRecord.count = buyCarRecord.count.add(1);
      buyCarRecord.referrer = referrer.addr;
      _updateBuyCarRecord(buyCarRecord);

      // 更新汽车状态
      _useUserCarPoint(referrer.addr, referrerUserCar);
      return;
    }

    if (referrerUserCarPoint == 0) {
      address target = referrer.addr;
      uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(target, mainToken);
      autoHeroStorage.setUserAvailableBalance(target, mainToken, availableBalance.add(buyCarRecord.referrerAmount));
      autoHeroStorage.addUserDepositBalance(target, mainToken, buyCarRecord.referrerAmount, "sendReceive");
      autoHeroStorage.addReferrerBalance(mainToken, buyCarRecord.referrerAmount);

      buyCarRecord.count = buyCarRecord.count.add(1);
      buyCarRecord.state = 1;
      buyCarRecord.referrer = target;
      _updateBuyCarRecord(buyCarRecord);

      // 更新汽车状态
      _useUserCarPoint(referrer.addr, referrerUserCar);
      return;
    }

    if (referrerUserCarPoint == 2) {
      uint256 count = autoHeroStorage.getPointUserCount(buyCarRecord.carId, 0);
      uint256 index = _randomNumber(buyCarRecord.user, count);
      address target = autoHeroStorage.getPointUser(buyCarRecord.carId, 0, index);

      uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(target, mainToken);
      autoHeroStorage.setUserAvailableBalance(target, mainToken, availableBalance.add(buyCarRecord.referrerAmount));
      autoHeroStorage.addUserDepositBalance(target, mainToken, buyCarRecord.referrerAmount, "sendReceive");
      autoHeroStorage.addReferrerBalance(mainToken, buyCarRecord.referrerAmount);

      buyCarRecord.count = buyCarRecord.count.add(1);
      buyCarRecord.state = 1;
      buyCarRecord.referrer = target;
      _updateBuyCarRecord(buyCarRecord);

      // 更新汽车状态
      _useUserCarPoint(referrer.addr, referrerUserCar);
      return;
    }
  }

  function addMiniLucky(address userAddr) public onlyWhitelistAdmin {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    require(miniPhase.state == 0);
    autoHeroStorage.addLucky(miniPhase.id, userAddr);
  }

  function removeMiniLucky(address userAddr) public onlyWhitelistAdmin {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    require(miniPhase.state == 0);
    autoHeroStorage.removeLucky(miniPhase.id, userAddr);
  }

  function addMiniTop(address userAddr, uint256 fission) public onlyWhitelistAdmin {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    require(miniPhase.state == 0);
    autoHeroStorage.addTop(miniPhase.id, userAddr, fission);
  }

  function removeMiniTop(address userAddr) public onlyWhitelistAdmin {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    require(miniPhase.state == 0);
    autoHeroStorage.removeTop(miniPhase.id, userAddr);
  }

  // 奖池是否可以发奖
  function canIssueMini() public view returns (bool) {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    bool miniAssigned = autoHeroStorage.getMiniAssigned();
    uint256 miniAssignBalance = autoHeroStorage.getMiniAssignBalance();

    return miniAssigned && miniPhase.state == 0 && miniPhase.amount >= miniAssignBalance;
  }

  // 解决 'Stack too deep, try removing local variables' 错误
  // 使用 struct 存储变量
  struct MiniData {
    uint256 luckyAmount;
    uint256 topAmount;
    uint256 luckysCount;
    uint256 topsCount;
    uint256 luckyBalance;
    uint256 topBalance;
    uint256 topFissionSum;

    address[] luckys;
    address[] tops;
  }

  // 奖池发奖
  function issueMini() public onlyWhitelistAdmin {
    AutoHeroStructure.MiniPhase memory miniPhase = _getCurrentMiniPhase();
    require(autoHeroStorage.getMiniAssigned() && miniPhase.state == 0 && miniPhase.amount >= autoHeroStorage.getMiniAssignBalance());

    uint256 luckyRatio;
    uint256 denominator;
    (luckyRatio,, denominator) = autoHeroStorage.getMiniRatio();
    require(denominator > 0);

    MiniData memory miniData;

    miniData.luckys = autoHeroStorage.getMiniPhaseLucys(miniPhase.id);
    miniData.tops = autoHeroStorage.getMiniPhaseTops(miniPhase.id);
    miniData.luckyAmount = miniPhase.amount.mul(luckyRatio).div(denominator);
    miniData.topAmount = miniPhase.amount.sub(miniData.luckyAmount);
    miniData.luckysCount = miniData.luckys.length;
    miniData.topsCount = miniData.tops.length;
    miniData.luckyBalance = miniData.luckyAmount;
    miniData.topBalance = miniData.luckyAmount;

    for (uint256 i = 0; i < miniData.luckysCount; i++) {
      address luckyAccount = miniData.luckys[i];
      uint luckyAccountAmount;

      if (i < miniData.luckysCount - 1) {
        luckyAccountAmount = miniData.luckyAmount.div(miniData.luckysCount);
        miniData.luckyBalance = miniData.luckyBalance.sub(luckyAccountAmount);
      } else {
        luckyAccountAmount = miniData.luckyBalance;
      }

      _issueLuckReward(miniPhase.id, luckyAccount, luckyAccountAmount);
    }

    for (uint i = 0; i < miniData.topsCount; i++) {
      address topAccount = miniData.tops[i];
      uint256 fission = _getTopFission(miniPhase.id, topAccount);
      miniData.topFissionSum = miniData.topFissionSum.add(fission);
    }

    for (uint i = 0; i < miniData.topsCount; i++) {
      address topAccount = miniData.tops[i];
      uint topAccountAmount;

      if (i < miniData.topsCount - 1) {
        topAccountAmount = miniData.topAmount.mul(topFissions[miniPhase.id][topAccount]).div(miniData.topFissionSum);
        miniData.topBalance = miniData.topBalance.sub(topAccountAmount);
      } else {
        topAccountAmount = miniData.topBalance;
      }

      _issueTopReward(miniPhase.id, topAccount, topAccountAmount);
    }

    miniPhase.state = 1;
    _updateMiniPhase(miniPhase);

    autoHeroStorage.createMiniPhase();
  }

  // 发股
  function issueStock(string memory date, address userAddr, uint amount) public onlyWhitelistAdmin {
    AutoHeroStructure.Token memory token = _getAirdropStockToken();
    uint256 userId = autoHeroStorage.getUserId(userAddr);
    autoHeroStorage.addAirdropUserStockBalance(date, userId, token.addr, amount);
    autoHeroStorage.addAirdropTotalStockBalance(token.addr, amount);

    uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(userAddr, token.addr);
    autoHeroStorage.setUserAvailableBalance(userAddr, token.addr, availableBalance.add(amount));
    autoHeroStorage.addUserDepositBalance(userAddr, token.addr, amount, "issueStock");
  }

  // 发息
  function issueInterest(string memory date, address userAddr) public onlyWhitelistAdmin {
    uint256 userId = autoHeroStorage.getUserId(userAddr);
    require(!autoHeroStorage.isAirdropInterest(date, userId));

    uint256 ratio;
    uint256 denominator;
    (ratio, denominator) = autoHeroStorage.getInterestRatio();

    AutoHeroStructure.Token memory stockToken = _getAirdropStockToken();
    AutoHeroStructure.Token memory interestToken = _getAirdropInterestToken();

    uint256 stockAvailableBalance = autoHeroStorage.getUserAvailableBalance(userAddr, stockToken.addr);
    uint256 todayStockBalance = autoHeroStorage.getAirdropUserStockBalance(date, userId, stockToken.addr);

    uint256 amount = stockAvailableBalance
      .sub(todayStockBalance)
      .div(10 ** stockToken.decimals)
      .mul(10 ** interestToken.decimals)
      .mul(ratio)
      .div(denominator);

    autoHeroStorage.addAirdropUserInterestBalance(date, userId, interestToken.addr, amount);
    autoHeroStorage.addAirdropTotalInterestBalance(interestToken.addr, amount);

    uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(userAddr, interestToken.addr);
    autoHeroStorage.setUserAvailableBalance(userAddr, interestToken.addr, availableBalance.add(amount));
    autoHeroStorage.addUserDepositBalance(userAddr, interestToken.addr, amount, "issueInterest");
    autoHeroStorage.setAirdropIsInterest(date, userId, true);
  }

  // 用户提现
  function withdraw(address token, uint256 amount) public {
    address userAddr = _msgSender();
    uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(userAddr, token);
    require(amount <= availableBalance);

    uint256 ratio;
    uint256 denominator;
    (ratio, denominator) = autoHeroStorage.getInterestRatio();

    uint256 fee = amount.mul(ratio).div(denominator);
    autoHeroStorage.addFeeBalance(token, fee);
    autoHeroStorage.addFeeAvailableBalance(token, fee);

    autoHeroBank.withdraw(userAddr, token, amount.sub(fee));

    uint256 withdrawnBalance = autoHeroStorage.getUserWithdrawnBalance(userAddr, token);
    autoHeroStorage.setUserWithdrawnBalance(userAddr, token, withdrawnBalance.add(amount));
    autoHeroStorage.setUserAvailableBalance(userAddr, token, availableBalance.sub(amount));

    autoHeroStorage.emitEvent("UserAccount", abi.encodePacked("withdraw", userAddr, token, amount.sub(fee), fee));
  }

  // 管理员提取手续费
  function withdrawFee(address token, uint256 amount) public onlyOwner {
    address userAddr = _msgSender();
    uint256 availableBalance = autoHeroStorage.getFeeAvailableBalance(token);
    require(amount <= availableBalance);

    autoHeroBank.withdraw(userAddr, token, amount);
    autoHeroStorage.subFeeAvailableBalance(token, amount);
    autoHeroStorage.addFeeWithdrawnBalances(token, amount);

    autoHeroStorage.emitEvent("Fee", abi.encodePacked("withdraw", userAddr, token, amount));
  }

  function _randomNumber(address userAddr, uint256 mod) internal returns (uint256) {
    salt = salt.add(1);
    return Utils.random(userAddr, salt, mod);
  }

  function _generatePoints(address userAddr) internal returns (uint256[] memory) {
    uint256[] memory points = new uint256[](4);
    points[2] = _randomNumber(userAddr, 3);
    points[2] = _randomNumber(userAddr, 4);

    return points;
  }

  function __getCurrentMiniPhaseId() internal returns (uint256) {
    uint256 phasesLastId = autoHeroStorage.getMiniPhasesLastId();

    if (phasesLastId == 0 || autoHeroStorage.getMiniPhaseState(phasesLastId) == 1) {
      autoHeroStorage.createMiniPhase();
    }

    return autoHeroStorage.getMiniPhasesLastId();
  }

  function _getBuyCarRecord(uint256 buyCarReceiveId) internal view returns (AutoHeroStructure.BuyCarRecord memory) {
    uint256 carId;
    uint256 amount;
    uint256 referrerAmount;
    uint256 count;
    uint256 state;
    address user;
    address referrer;
    AutoHeroStructure.BuyCarRecord memory buyCarRecord;

    (,carId,amount,referrerAmount,count,state,user,referrer,) = autoHeroStorage.getBuyCarRecord(buyCarReceiveId);

    buyCarRecord.id = buyCarReceiveId;
    buyCarRecord.carId = carId;
    buyCarRecord.amount = amount;
    buyCarRecord.referrerAmount = referrerAmount;
    buyCarRecord.count = count;
    buyCarRecord.state = state;
    buyCarRecord.user = user;
    buyCarRecord.referrer = referrer;

    return buyCarRecord;
  }

  function _updateBuyCarRecord(AutoHeroStructure.BuyCarRecord memory buyCarRecord) internal {
    autoHeroStorage.updateBuyCarRecord(buyCarRecord.id, buyCarRecord.count, buyCarRecord.state, buyCarRecord.referrer);
  }

  function _getUser(address userAddr) internal view returns (AutoHeroStructure.User memory) {
    uint256 id;
    address referrer;
    uint256 carCount;
    uint256 partnersCount;
    uint256 state;
    AutoHeroStructure.User memory user;

    (id,,referrer,carCount,partnersCount,state) = autoHeroStorage.getUser(userAddr);

    user.id = id;
    user.addr = userAddr;
    user.referrer = referrer;
    user.carCount = carCount;
    user.partnersCount = partnersCount;
    user.state = state;

    return user;
  }

  function _updateUser(AutoHeroStructure.User memory user) internal {
    autoHeroStorage.updateUser(user.addr, user.referrer, user.carCount, user.partnersCount, user.state);
  }

  function _getUserCar(address userAddr, uint256 carId) internal view returns (AutoHeroStructure.UserCar memory) {
    uint256 partnersCount;
    uint256 reinvestCount;
    uint256 state;
    uint256[] memory points;
    uint256[] memory pointsState;
    AutoHeroStructure.UserCar memory userCar;

    (partnersCount,reinvestCount,state,points,pointsState) = autoHeroStorage.getUserCar(userAddr, carId);

    userCar.carId = carId;
    userCar.partnersCount = partnersCount;
    userCar.reinvestCount = reinvestCount;
    userCar.state = state;
    userCar.points = points;
    userCar.pointsState = pointsState;

    return userCar;
  }

  function _updateUserCar(address userAddr, AutoHeroStructure.UserCar memory userCar) internal {
    autoHeroStorage.updateUserCar(userAddr, userCar.carId, userCar.partnersCount, userCar.reinvestCount, userCar.state, userCar.points, userCar.pointsState);
  }

  function _useUserCarPoint(address userAddr, AutoHeroStructure.UserCar memory userCar) internal {
    uint256 prevPoint = userCar.points[userCar.pointsState.length];
    autoHeroStorage.removePointUser(userCar.carId, prevPoint, userAddr);

    userCar.pointsState = new uint256[](userCar.pointsState.length + 1);

    if (userCar.pointsState.length == userCar.points.length && userCar.state != 2) {
      userCar.state = 1;
    }

    if (userCar.pointsState.length == userCar.points.length) {
      userCar.reinvestCount = userCar.reinvestCount.add(1);
      userCar.pointsState = new uint256[](0);
    }

    uint256 currPoint = userCar.points[userCar.pointsState.length];
    autoHeroStorage.addPointUser(userCar.carId, currPoint, userAddr);

    _updateUserCar(userAddr, userCar);
  }

  function _getCurrentMiniPhase() internal view returns (AutoHeroStructure.MiniPhase memory) {
    uint256 id;
    uint256 amount;
    uint256 state;
    AutoHeroStructure.MiniPhase memory miniPhase;

    (id, amount, state,,,,) = autoHeroStorage.getCurrentMiniPhase();
    miniPhase.id = id;
    miniPhase.amount = amount;
    miniPhase.state = state;

    return miniPhase;
  }

  function _updateMiniPhase(AutoHeroStructure.MiniPhase memory miniPhase) internal {
    autoHeroStorage.updateMiniPhase(miniPhase.id, miniPhase.amount, miniPhase.state);
  }

  function _issueLuckReward(uint256 miniPhaseId, address account, uint256 amount) internal {
    autoHeroStorage.setLuckyReward(miniPhaseId, account, amount);

    uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(account, address(0));
    autoHeroStorage.setUserAvailableBalance(account, address(0), availableBalance.add(amount));
    autoHeroStorage.addUserDepositBalance(account, address(0), amount, "issueRewardLucky");
  }

  function _getTopFission(uint256 miniPhaseId, address account) internal returns (uint256) {
    uint256 fission = autoHeroStorage.getTopFission(miniPhaseId, account);
    topFissions[miniPhaseId][account] = fission;
    return fission;
  }

  function _issueTopReward(uint256 miniPhaseId, address account, uint256 amount) internal {
    autoHeroStorage.setTopReward(miniPhaseId, account, amount);

    uint256 availableBalance = autoHeroStorage.getUserAvailableBalance(account, address(0));
    autoHeroStorage.setUserAvailableBalance(account, address(0), availableBalance.add(amount));
    autoHeroStorage.addUserDepositBalance(account, address(0), amount, "issueRewardTop");
  }

  function _getAirdropStockToken() internal view returns (AutoHeroStructure.Token memory) {
    address addr;
    string memory name;
    string memory symbol;
    uint256 decimals;
    AutoHeroStructure.Token memory token;

    (addr, name, symbol, decimals) = autoHeroStorage.getAirdropStockToken();
    token.addr = addr;
    token.name = name;
    token.symbol = symbol;
    token.decimals = decimals;

    return token;
  }

  function _getAirdropInterestToken() internal view returns (AutoHeroStructure.Token memory) {
    address addr;
    string memory name;
    string memory symbol;
    uint256 decimals;
    AutoHeroStructure.Token memory token;

    (addr, name, symbol, decimals) = autoHeroStorage.getAirdropInterestToken();
    token.addr = addr;
    token.name = name;
    token.symbol = symbol;
    token.decimals = decimals;

    return token;
  }
}