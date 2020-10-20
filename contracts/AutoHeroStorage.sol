pragma solidity >=0.4.23 <0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/access/roles/WhitelistAdminRole.sol";
import "./AutoHeroStructure.sol";
import "./library/AddressArray.sol";

contract AutoHeroStorage is Ownable, WhitelistAdminRole {
  using SafeMath for uint256;
  using AddressArray for AddressArray.Addresses;

  // - 逻辑合约 -
  address public autoHeroLogic;

  modifier onlyLogic() {
    require(_msgSender() == autoHeroLogic || _msgSender() == owner());
    _;
  }

  function setLogic(address _autoHeroLogic) public onlyWhitelistAdmin {
    autoHeroLogic = _autoHeroLogic;
  }
  // = 逻辑合约 =

  // - 配置 -
  AutoHeroStructure.Config public config;

  function getBurned() public view returns (bool) {
    return config.burned;
  }

  function setBurned(bool burned) public onlyWhitelistAdmin {
    config.burned = burned;
    emitEvent("Config", abi.encodePacked("setBurned", burned));
  }

  function getMiniOpended() public view returns (bool) {
    return config.miniOpened;
  }

  function setMiniOpened(bool miniOpened) public onlyWhitelistAdmin {
    config.miniOpened = miniOpened;
    emitEvent("Config", abi.encodePacked("setMiniOpened", miniOpened));
  }

  function getMiniAssigned() public view returns (bool) {
    return config.miniAssigned;
  }

  function setMiniAssigned(bool miniAssigned) public onlyWhitelistAdmin {
    config.miniAssigned = miniAssigned;
    emitEvent("Config", abi.encodePacked("setMiniAssigned", miniAssigned));
  }

  function getMiniAssignBalance() public view returns (uint256) {
    return config.miniAssignBalance;
  }

  function setMiniAssignBalance(uint256 miniAssignBalance) public onlyWhitelistAdmin {
    require(miniAssignBalance > 0);
    config.miniAssignBalance = miniAssignBalance;
    emitEvent("Config", abi.encodePacked("setMiniAssignBalance", miniAssignBalance));
  }

  function getMiniRatio() public view returns (uint256 luckyRatio, uint256 topRatio, uint256 denominator) {
    return (config.miniLuckyRatio, config.miniTopRatio, config.ratioDenominator);
  }

  function setMiniRatio(uint256 miniLuckyRatio, uint256 miniTopRatio) public onlyWhitelistAdmin {
    require(miniLuckyRatio + miniTopRatio == config.ratioDenominator);
    config.miniLuckyRatio = miniLuckyRatio;
    config.miniTopRatio = miniTopRatio;
    emitEvent("Config", abi.encodePacked("setMiniRatio", miniLuckyRatio, miniTopRatio));
  }

  function getAssignRatio() public view returns (uint256 miniRatio, uint256 referrerRatio, uint256 denominator) {
    return (config.assignMiniRatio, config.assignReferrerRatio, config.ratioDenominator);
  }

  function setAssignRatio(uint256 assignMiniRatio, uint256 assignReferrerRatio) public onlyWhitelistAdmin {
    require(assignMiniRatio + assignReferrerRatio == config.ratioDenominator);
    config.assignMiniRatio = assignMiniRatio;
    config.assignReferrerRatio = assignReferrerRatio;
    emitEvent("Config", abi.encodePacked("setAssignRatio", assignMiniRatio, assignReferrerRatio));
  }

  function getCommissionRatio() public view returns (uint256 ratio, uint256 denominator) {
    return (config.commissionRatio, config.ratioDenominator);
  }

  function setCommissionRatio(uint256 commissionRatio) public onlyWhitelistAdmin {
    require(commissionRatio <= config.ratioDenominator);
    config.commissionRatio = commissionRatio;
    emitEvent("Config", abi.encodePacked("setCommissionRatio", commissionRatio));
  }

  function getInterestRatio() public view returns (uint256 ratio, uint256 denominator) {
    return (config.interestRatio, config.ratioDenominator);
  }

  function setInterestRatio(uint256 interestRatio) public onlyWhitelistAdmin {
    require(interestRatio <= config.ratioDenominator);
    config.interestRatio = interestRatio;
    emitEvent("Config", abi.encodePacked("setInterestRatio", interestRatio));
  }

  function getRatioDenominator() public view returns (uint256) {
    return config.ratioDenominator;
  }

  function setRatioDenominator(uint256 ratioDenominator) public onlyWhitelistAdmin {
    require(ratioDenominator > 0);
    config.ratioDenominator = ratioDenominator;
    emitEvent("Config", abi.encodePacked("setRatioDenominator", ratioDenominator));
  }

  function getTokenLocked(address token) public view returns (bool) {
    return config.tokenLocked[token];
  }

  function setTokenLocked(address token, bool locked) public onlyWhitelistAdmin {
    config.tokenLocked[token] = locked;
    emitEvent("Config", abi.encodePacked("setTokenLocked", token, locked));
  }
  // = 配置 =

  // - 数据 -
  AutoHeroStructure.Data public data;

  function addTotalCarCount(uint256 count) public onlyLogic {
    require(count > 0);
    data.totalCarCount = data.totalCarCount.add(count);
    emitEvent("Data", abi.encodePacked("addTotalCarCount", count, data.totalCarCount));
  }

  function addTotalUserCount(uint256 count) public onlyLogic {
    require(count > 0);
    data.totalUserCount = data.totalUserCount.add(count);
    emitEvent("Data", abi.encodePacked("addTotalUserCount", count, data.totalUserCount));
  }

  function addTotalCarOwnerCount(uint256 count) public onlyLogic {
    require(count > 0);
    data.totalCarOwnerCount = data.totalCarOwnerCount.add(count);
    emitEvent("Data", abi.encodePacked("addTotalCarOwnerCount", count, data.totalCarOwnerCount));
  }

  function addTotalUserCarCount(uint256 count) public onlyLogic {
    require(count > 0);
    data.totalUserCarCount = data.totalUserCarCount.add(count);
    emitEvent("Data", abi.encodePacked("addTotalCarOwnerCount", count, data.totalUserCarCount));
  }

  function getTotalBalance(address token) public view returns (uint) {
    return data.totalBalances[token];
  }

  function addTotalBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.totalBalances[token] = data.totalBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addTotalBalance", token, amount, data.totalBalances[token]));
  }

  function getReferrerBalance(address token) public view returns (uint) {
    return data.referrerBalances[token];
  }

  function addReferrerBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.referrerBalances[token] = data.referrerBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addReferrerBalance", token, amount, data.referrerBalances[token]));
  }

  function getMiniBalance(address token) public view returns (uint) {
    return data.miniBalances[token];
  }

  function addMiniBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.miniBalances[token] = data.miniBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addMiniBalance", token, amount, data.miniBalances[token]));
  }

  function getFeeBalance(address token) public view returns (uint) {
    return data.feeBalances[token];
  }

  function addFeeBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.feeBalances[token] = data.feeBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addFeeBalance", token, amount, data.feeBalances[token]));
  }

  function getFeeAvailableBalance(address token) public view returns (uint) {
    return data.feeAvailableBalances[token];
  }

  function addFeeAvailableBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.feeAvailableBalances[token] = data.feeAvailableBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addFeeAvailableBalance", token, amount, data.feeAvailableBalances[token]));
  }

  function subFeeAvailableBalance(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.feeAvailableBalances[token] = data.feeAvailableBalances[token].sub(amount);
    emitEvent("Data", abi.encodePacked("subFeeAvailableBalance", token, amount, data.feeAvailableBalances[token]));
  }

  function getFeeWithdrawnBalance(address token) public view returns (uint) {
    return data.feeWithdrawnBalances[token];
  }

  function addFeeWithdrawnBalances(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.feeWithdrawnBalances[token] = data.feeWithdrawnBalances[token].add(amount);
    emitEvent("Data", abi.encodePacked("addFeeWithdrawnBalances", token, amount, data.feeWithdrawnBalances[token]));
  }

  function subFeeWithdrawnBalances(address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    data.feeWithdrawnBalances[token] = data.feeWithdrawnBalances[token].sub(amount);
    emitEvent("Data", abi.encodePacked("subFeeWithdrawnBalances", token, amount, data.feeWithdrawnBalances[token]));
  }
  // = 数据 =

  // - 汽车 -
  AutoHeroStructure.Cars private cars;

  function isCarExist(uint256 carId) public view returns (bool) {
    AutoHeroStructure.Car storage car = cars.data[carId];
    return car.id != 0;
  }

  function getCar(uint256 carId) public view returns (uint256 price) {
    AutoHeroStructure.Car storage car = cars.data[carId];
    return car.price;
  }

  function setCar(uint256 carId, uint256 price) public onlyLogic {
    AutoHeroStructure.Car storage car = cars.data[carId];

    car.id = carId;
    car.price = price;
    emitEvent("Car", abi.encodePacked("setCar", carId, price));
  }
  // = 汽车 =

  // - 用户 -
  AutoHeroStructure.Users private users;

  function isUserExist(address userAddr) public view returns (bool) {
    return users.addressToId[userAddr] != 0;
  }

  function getUserId(address userAddr) public view returns (uint256) {
    return users.addressToId[userAddr];
  }

  function getUser(address userAddr) public view returns (
    uint256 id,
    address addr,
    address referrer,
    uint256 carCount,
    uint256 partnersCount,
    uint256 state
  ) {
    uint256 userId = getUserId(userAddr);
    AutoHeroStructure.User storage user = users.data[userId];

    return (
      user.id,
      user.addr,
      user.referrer,
      user.carCount,
      user.partnersCount,
      user.state
    );
  }

  function addUser(address userAddr, address referrerAddr) public onlyLogic {
    require(!isUserExist(userAddr));

    users.lastId = users.lastId.add(1);
    users.addressToId[userAddr] = users.lastId;

    AutoHeroStructure.User storage user = users.data[users.lastId];
    user.id = users.lastId;
    user.addr = userAddr;
    user.referrer = referrerAddr;

    emitEvent("User", abi.encodePacked("addUser", user.id, userAddr, referrerAddr));
  }

  function updateUser(
    address userAddr,
    address referrerAddr,
    uint256 carCount,
    uint256 partnersCount,
    uint256 state
  ) public onlyLogic {
    require(isUserExist(userAddr));

    uint256 userId = getUserId(userAddr);
    AutoHeroStructure.User storage user = users.data[userId];

    user.referrer = referrerAddr;
    user.carCount = carCount;
    user.partnersCount = partnersCount;
    user.state = state;

    emitEvent("User", abi.encodePacked("updateUser", userAddr, referrerAddr, carCount, partnersCount, state));
  }
  // = 用户 =

  // - 用户账户信息 -
  AutoHeroStructure.UserAccounts private userAccounts;

  function getUserConsumeBalance(address userAddr, address token) public view returns (uint256) {
    uint256 userId = getUserId(userAddr);
    return userAccounts.data[userId].consumeBalances[token];
  }

  function addUserConsumeBalance(address userAddr, address token, uint256 amount) public onlyLogic {
    require(amount > 0);
    uint256 userId = getUserId(userAddr);
    userAccounts.data[userId].consumeBalances[token] = userAccounts.data[userId].consumeBalances[token].add(amount);
    emitEvent("UserAccount", abi.encodePacked("addUserConsumeBalance", userAddr, token, amount, userAccounts.data[userId].consumeBalances[token]));
  }

  function getUserDepositBalance(address userAddr, address token) public view returns (uint256) {
    uint256 userId = getUserId(userAddr);
    return userAccounts.data[userId].depositBalances[token];
  }

  function addUserDepositBalance(address userAddr, address token, uint256 amount, string memory note) public onlyLogic {
    require(amount > 0);
    uint256 userId = getUserId(userAddr);
    userAccounts.data[userId].depositBalances[token] = userAccounts.data[userId].depositBalances[token].add(amount);
    emitEvent("UserAccount", abi.encodePacked("addUserDepositBalance", userAddr, token, amount, userAccounts.data[userId].depositBalances[token], note));
  }

  function getUserAvailableBalance(address userAddr, address token) public view returns (uint256) {
    uint256 userId = getUserId(userAddr);
    return userAccounts.data[userId].availableBalances[token];
  }

  function setUserAvailableBalance(address userAddr, address token, uint256 amount) public onlyLogic {
    uint256 userId = getUserId(userAddr);
    userAccounts.data[userId].availableBalances[token] = amount;
    emitEvent("UserAccount", abi.encodePacked("setUserAvailableBalance", userAddr, token, amount));
  }

  function getUserWithdrawnBalance(address userAddr, address token) public view returns (uint256) {
    uint256 userId = getUserId(userAddr);
    return userAccounts.data[userId].withdrawnBalances[token];
  }

  function setUserWithdrawnBalance(address userAddr, address token, uint256 amount) public onlyLogic {
    uint256 userId = getUserId(userAddr);
    userAccounts.data[userId].withdrawnBalances[token] = amount;
    emitEvent("UserAccount", abi.encodePacked("setUserWithdrawnBalances", userAddr, token, amount));
  }
  // = 用户账户信息 =

  // - 用户汽车 -
  AutoHeroStructure.UserCars private userCars;

  function isUserCarExist(address userAddr, uint256 carId) public view returns (bool) {
    uint256 userId = getUserId(userAddr);
    return userCars.activeness[userId][carId];
  }

  function getUserCar(address userAddr, uint256 carId) public view returns (
    uint256 partnersCount,
    uint256 reinvestCount,
    uint256 state,
    uint256[] memory points,
    uint256[] memory pointsState
  ) {
    require(isUserExist(userAddr));
    require(isUserCarExist(userAddr, carId));

    uint256 userId = getUserId(userAddr);
    AutoHeroStructure.UserCar storage userCar = userCars.data[userId][carId];

    return (
      userCar.partnersCount,
      userCar.reinvestCount,
      userCar.state,
      userCar.points,
      userCar.pointsState
    );
  }

  function addUserCar(
    address userAddr,
    uint256 carId,
    uint256[] memory points
  ) public onlyLogic {
    require(isUserExist(userAddr));
    require(!isUserCarExist(userAddr, carId));

    uint256 userId = getUserId(userAddr);

    AutoHeroStructure.UserCar storage userCar = userCars.data[userId][carId];
    userCar.carId = carId;
    userCar.points = points;

    userCars.activeness[userId][carId] = true;

    emitEvent("UserCar", abi.encodePacked("addUserCar", userAddr, carId, points));
  }

  function updateUserCar(
    address userAddr,
    uint256 carId,
    uint256 partnersCount,
    uint256 reinvestCount,
    uint256 state,
    uint256[] memory points,
    uint256[] memory pointsState
  ) public onlyLogic {
    require(isUserExist(userAddr));
    require(isUserCarExist(userAddr, carId));

    uint256 userId = getUserId(userAddr);

    AutoHeroStructure.UserCar storage userCar = userCars.data[userId][carId];
    userCar.partnersCount = partnersCount;
    userCar.reinvestCount = reinvestCount;
    userCar.state = state;
    userCar.points = points;
    userCar.pointsState = pointsState;

    emitEvent("UserCar", abi.encodePacked("updateUserCar", userAddr, carId, partnersCount, reinvestCount, state, points, pointsState));
  }

  function getPointUser(uint256 carId, uint256 point, uint256 index) public view returns (address) {
    return userCars.pointUsers[carId][point].getAtIndex(index);
  }

  function getPointUserCount(uint256 carId, uint256 point) public view returns (uint256) {
    return userCars.pointUsers[carId][point].size();
  }

  function addPointUser(uint256 carId, uint256 point, address userAddr) public onlyLogic {
    userCars.pointUsers[carId][point].push(userAddr);
    emitEvent("UserCar", abi.encodePacked("addPointUser", carId, point, userAddr));
  }

  function removePointUser(uint256 carId, uint256 point, address userAddr) public onlyLogic {
    userCars.pointUsers[carId][point].remove(userAddr);
    emitEvent("UserCar", abi.encodePacked("removePointUser", carId, point, userAddr));
  }
  // = 用户汽车 =

  // - 用户购车记录 -
  AutoHeroStructure.BuyCarRecords private buyCarRecords;

  function getBuyCarRecord(uint256 buyCarRecordId) public view returns (
    uint256 id,
    uint256 carId,
    uint256 amount,
    uint256 referrerAmount,
    uint256 count,
    uint256 state,
    address user,
    address referrer,
    address[] memory referrers
  ) {
    AutoHeroStructure.BuyCarRecord storage buyCarRecord = buyCarRecords.data[buyCarRecordId];

    return (
      buyCarRecord.id,
      buyCarRecord.carId,
      buyCarRecord.amount,
      buyCarRecord.referrerAmount,
      buyCarRecord.count,
      buyCarRecord.state,
      buyCarRecord.user,
      buyCarRecord.referrer,
      buyCarRecord.referrers.getAll()
    );
  }

  function addBuyCarRecord(address userAddr, uint256 carId, uint256 amount, uint256 referrerAmount) public onlyLogic {
    buyCarRecords.lastId = buyCarRecords.lastId.add(1);
    AutoHeroStructure.BuyCarRecord storage buyCarRecord = buyCarRecords.data[buyCarRecords.lastId];
    buyCarRecord.id = buyCarRecords.lastId;
    buyCarRecord.carId = carId;
    buyCarRecord.amount = amount;
    buyCarRecord.referrerAmount = referrerAmount;
    buyCarRecord.user = userAddr;
    buyCarRecord.referrer = userAddr;

    emitEvent("BuyCarRecord", abi.encodePacked("addBuyCarRecord", buyCarRecords.lastId, userAddr, carId, amount));
  }

  function updateBuyCarRecord(uint256 buyCarRecordId, uint256 count, uint256 state, address referrer) public onlyLogic {
    AutoHeroStructure.BuyCarRecord storage buyCarRecord = buyCarRecords.data[buyCarRecordId];
    require(buyCarRecord.id != 0);

    buyCarRecord.count = count;
    buyCarRecord.state = state;
    buyCarRecord.referrer = referrer;

    emitEvent("BuyCarRecord", abi.encodePacked("updateBuyCarRecord", buyCarRecordId, count, state, referrer));
  }
  // = 用户购车记录 -

  // - Mini奖池 -
  AutoHeroStructure.MiniPhases private miniPhases;

  function getMiniPhasesTotal() public view returns (uint256) {
    return miniPhases.total;
  }

  function getMiniPhasesLastId() public view returns (uint256) {
    return miniPhases.lastId;
  }

  function getCurrentMiniPhase() public view returns (
    uint256 id,
    uint256 amount,
    uint256 state,
    uint256 luckysCount,
    uint256 topsCount,
    address[] memory luckys,
    address[] memory tops
  ) {
    return getMiniPhase(miniPhases.lastId);
  }

  function getMiniPhaseAmount(uint256 phaseId) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.amount;
  }

  function getMiniPhaseState(uint256 phaseId) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.state;
  }

  function getMiniPhaseLucysCount(uint256 phaseId) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.luckys.size();
  }

  function getMiniPhaseLucys(uint256 phaseId) public view returns (address[] memory) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.luckys.getAll();
  }

  function getMiniPhaseTopsCount(uint256 phaseId) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.tops.size();
  }

  function getMiniPhaseTops(uint256 phaseId) public view returns (address[] memory) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.tops.getAll();
  }

  function getMiniPhase(uint256 phaseId) public view returns (
    uint256 id,
    uint256 amount,
    uint256 state,
    uint256 luckysCount,
    uint256 topsCount,
    address[] memory luckys,
    address[] memory tops
  ) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];

    return (
      miniPhase.id,
      miniPhase.amount,
      miniPhase.state,
      miniPhase.luckys.size(),
      miniPhase.tops.size(),
      miniPhase.luckys.getAll(),
      miniPhase.tops.getAll()
    );
  }

  function createMiniPhase() public onlyLogic {
    require(miniPhases.lastId == 0 || miniPhases.data[miniPhases.lastId].state == 1);

    miniPhases.total = miniPhases.total.add(1);
    miniPhases.lastId = miniPhases.lastId.add(1);

    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[miniPhases.lastId];
    miniPhase.id = miniPhases.lastId;

    emitEvent("Mini", abi.encodePacked("createMiniPhase", miniPhases.lastId));
  }

  function updateMiniPhase(uint256 phaseId, uint256 amount, uint256 state) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    miniPhase.amount = amount;
    miniPhase.state = state;
    emitEvent("Mini", abi.encodePacked("updateMiniPhase", phaseId, amount, state));
  }

  function addLucky(uint256 phaseId, address account) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    miniPhase.luckys.push(account);
    emitEvent("Mini", abi.encodePacked("addLucky", phaseId, account));
  }

  function removeLucky(uint256 phaseId, address account) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    bool removed = miniPhase.luckys.remove(account);

    if (removed) {
      emitEvent("Mini", abi.encodePacked("remoteLucky", phaseId, account));
    }
  }

  function getTopFission(uint256 phaseId, address account) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.topFission[account];
  }

  function addTop(uint256 phaseId, address account, uint256 fission) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    miniPhase.tops.push(account);
    miniPhase.topFission[account] = fission;
    emitEvent("Mini", abi.encodePacked("addTop", phaseId, account));
  }

  function removeTop(uint256 phaseId, address account) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    bool removed = miniPhase.tops.remove(account);

    if (removed) {
      emitEvent("Mini", abi.encodePacked("removeTop", phaseId, account));
    }
  }

  function getLuckyReward(uint256 phaseId, address account) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.luckyReward[account];
  }

  function setLuckyReward(uint256 phaseId, address account, uint256 amount) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    require(miniPhase.luckys.exists(account));
    miniPhase.luckyReward[account] = amount;
    emitEvent("Mini", abi.encodePacked("setLuckyReward", phaseId, account, amount));
  }

  function getTopReward(uint256 phaseId, address account) public view returns (uint256) {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    return miniPhase.topReward[account];
  }

  function setTopReward(uint256 phaseId, address account, uint256 amount) public onlyLogic {
    AutoHeroStructure.MiniPhase storage miniPhase = miniPhases.data[phaseId];
    require(miniPhase.tops.exists(account));
    miniPhase.topReward[account] = amount;
    emitEvent("Mini", abi.encodePacked("setTopReward", phaseId, account, amount));
  }
  // = Mini奖池 =

  // - 空投 -
  AutoHeroStructure.Airdrop private airdrop;

  function getAirdropStockToken() public view returns (
    address token,
    string memory name,
    string memory symbol,
    uint256 decimals
  ) {
    return (
      airdrop.stockToken.addr,
      airdrop.stockToken.name,
      airdrop.stockToken.symbol,
      airdrop.stockToken.decimals
    );
  }

  function setAirdropStockToken(address token) public onlyLogic {
    string memory name;
    string memory symbol;
    uint256 decimals;

    (name, symbol, decimals) = getToken(token);
    AutoHeroStructure.Token storage stockToken = airdrop.stockToken;
    stockToken.addr = token;
    stockToken.name = name;
    stockToken.symbol = symbol;
    stockToken.decimals = decimals;
    emitEvent("Airdrop", abi.encodePacked("setAirdropStockToken", token, name, symbol, decimals));
  }

  function getAirdropInterestToken() public view onlyLogic returns (
    address token,
    string memory name,
    string memory symbol,
    uint256 decimals
  ) {
    return (
      airdrop.interestToken.addr,
      airdrop.interestToken.name,
      airdrop.interestToken.symbol,
      airdrop.interestToken.decimals
    );
  }

  function setAirdropInterestToken(address token) public onlyLogic {
    string memory name;
    string memory symbol;
    uint256 decimals;

    (name, symbol, decimals) = getToken(token);
    AutoHeroStructure.Token storage interestToken = airdrop.interestToken;
    interestToken.addr = token;
    interestToken.name = name;
    interestToken.symbol = symbol;
    interestToken.decimals = decimals;
    emitEvent("Airdrop", abi.encodePacked("setAirdropInterestToken", token, name, symbol, decimals));
  }

  function getAirdropTotalStockBalance(address token) public view returns (uint256) {
    return airdrop.totalStockBalances[token];
  }

  function addAirdropTotalStockBalance(address token, uint256 amount) public onlyLogic {
    airdrop.totalStockBalances[token] = airdrop.totalStockBalances[token].add(amount);
    emitEvent("Airdrop", abi.encodePacked("addAirdropTotalStockBalance", token, amount, airdrop.totalStockBalances[token]));
  }

  function getAirdropTotalInterestBalance(address token) public view returns (uint256) {
    return airdrop.totalInterestBalances[token];
  }

  function addAirdropTotalInterestBalance(address token, uint256 amount) public onlyLogic {
    airdrop.totalInterestBalances[token] = airdrop.totalInterestBalances[token].add(amount);
    emitEvent("Airdrop", abi.encodePacked("addAirdropTotalInterestBalance", token, amount, airdrop.totalInterestBalances[token]));
  }

  function isAirdropInterest(string memory date, uint256 userId) public view returns (bool) {
    return airdrop.isInterest[date][userId];
  }

  function setAirdropIsInterest(string memory date, uint256 userId, bool isInterest) public onlyLogic {
    airdrop.isInterest[date][userId] = isInterest;
    emitEvent("Airdrop", abi.encodePacked("setAirdropIsInterest", date, userId, isInterest));
  }

  function getAirdropUserStockBalance(string memory date, uint256 userId, address token) public view returns (uint256) {
    return airdrop.userStockBalances[date][userId][token];
  }

  function addAirdropUserStockBalance(string memory date, uint256 userId, address token, uint256 amount) public onlyLogic {
    airdrop.userStockBalances[date][userId][token] = airdrop.userStockBalances[date][userId][token].add(amount);
    emitEvent("Airdrop", abi.encodePacked("addAirdropUserStockBalance", date, userId, token, amount, airdrop.userStockBalances[date][userId][token]));
  }

  function getAirdropUserInterestBalance(string memory date, uint256 userId, address token) public view returns (uint256) {
    return airdrop.userInterestBalances[date][userId][token];
  }

  function addAirdropUserInterestBalance(string memory date, uint256 userId, address token, uint256 amount) public onlyLogic {
    airdrop.userInterestBalances[date][userId][token] = airdrop.userInterestBalances[date][userId][token].add(amount);
    emitEvent("Airdrop", abi.encodePacked("addAirdropUserInterestBalance", date, userId, token, amount, airdrop.userInterestBalances[date][userId][token]));
  }
  // = 空投 =

  // - 事件相关 -
  event AutoHeroEvent(string eventName, bytes payload);

  function emitEvent(string memory eventName, bytes memory payload) public onlyLogic {
    emit AutoHeroEvent(eventName, payload);
  }
  // = 事件相关 =

  function getToken(address tokeness) internal view returns (
    string memory name,
    string memory symbol,
    uint256 decimals
  ) {
    ERC20Detailed token = ERC20Detailed(tokeness);
    return (token.name(), token.symbol(), token.decimals());
  }
}