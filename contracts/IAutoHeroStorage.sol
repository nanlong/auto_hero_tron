pragma solidity >=0.4.23 <0.6.0;

interface IAutoHeroStorage {
  function getBurned() external view returns (bool);
  function setBurned(bool burned) external;
  function getMiniOpended() external view returns (bool);
  function setMiniOpened(bool miniOpened) external;
  function getMiniAssigned() external view returns (bool);
  function setMiniAssigned(bool miniAssigned) external;
  function getMiniAssignBalance() external view returns (uint256);
  function setMiniAssignBalance(uint256 miniAssignBalance) external;
  function getMiniRatio() external view returns (uint256 luckyRatio, uint256 topRatio, uint256 denominator);
  function setMiniRatio(uint256 miniLuckyRatio, uint256 miniTopRatio) external;
  function getAssignRatio() external view returns (uint256 miniRatio, uint256 referrerRatio, uint256 denominator);
  function setAssignRatio(uint256 assignMiniRatio, uint256 assignReferrerRatio) external;
  function getCommissionRatio() external view returns (uint256 ratio, uint256 denominator);
  function setCommissionRatio(uint256 commissionRatio) external;
  function getInterestRatio() external view returns (uint256 ratio, uint256 denominator);
  function setInterestRatio(uint256 interestRatio) external;
  function getRatioDenominator() external view returns (uint256);
  function setRatioDenominator(uint256 ratioDenominator) external;
  function getTokenLocked(address token) external view returns (bool);
  function setTokenLocked(address token, bool locked) external;
  function addTotalCarCount(uint256 count) external;
  function addTotalUserCount(uint256 count) external;
  function addTotalCarOwnerCount(uint256 count) external;
  function addTotalUserCarCount(uint256 count) external;
  function getTotalBalance(address token) external view returns (uint);
  function addTotalBalance(address token, uint256 amount) external;
  function getReferrerBalance(address token) external view returns (uint);
  function addReferrerBalance(address token, uint256 amount) external;
  function getMiniBalance(address token) external view returns (uint);
  function addMiniBalance(address token, uint256 amount) external;
  function getFeeBalance(address token) external view returns (uint);
  function addFeeBalance(address token, uint256 amount) external;
  function getFeeAvailableBalance(address token) external view returns (uint);
  function addFeeAvailableBalance(address token, uint256 amount) external;
  function subFeeAvailableBalance(address token, uint256 amount) external;
  function getFeeWithdrawnBalance(address token) external view returns (uint);
  function addFeeWithdrawnBalances(address token, uint256 amount) external;
  function subFeeWithdrawnBalances(address token, uint256 amount) external;
  function isCarExist(uint256 carId) external view returns (bool);
  function getCar(uint256 carId) external view returns (uint256 price);
  function setCar(uint256 carId, uint256 price) external;
  function isUserExist(address userAddr) external view returns (bool);
  function getUserId(address userAddr) external view returns (uint256);
  function getUser(address userAddr) external view returns (uint256 id, address addr, address referrer, uint256 carCount, uint256 partnersCount, uint256 state );
  function addUser(address userAddr, address referrerAddr) external;
  function updateUser(address userAddr, address referrerAddr, uint256 carCount, uint256 partnersCount, uint256 state) external;
  function getUserConsumeBalance(address userAddr, address token) external view returns (uint256);
  function addUserConsumeBalance(address userAddr, address token, uint256 amount) external;
  function getUserDepositBalance(address userAddr, address token) external view returns (uint256);
  function addUserDepositBalance(address userAddr, address token, uint256 amount, string calldata note) external;
  function getUserAvailableBalance(address userAddr, address token) external view returns (uint256);
  function setUserAvailableBalance(address userAddr, address token, uint256 amount) external;
  function getUserWithdrawnBalance(address userAddr, address token) external view returns (uint256);
  function setUserWithdrawnBalance(address userAddr, address token, uint256 amount) external;
  function isUserCarExist(address userAddr, uint256 carId) external view returns (bool);
  function getUserCar(address userAddr, uint256 carId) external view returns (uint256 partnersCount, uint256 reinvestCount, uint256 state, uint256[] memory points, uint256[] memory pointsState);
  function addUserCar(address userAddr, uint256 carId, uint256[] calldata points) external;
  function updateUserCar(address userAddr, uint256 carId, uint256 partnersCount, uint256 reinvestCount, uint256 state, uint256[] calldata points, uint256[] calldata pointsState) external;
  function getBuyCarRecord(uint256 buyCarRecordId) external view returns (uint256 id, uint256 carId, uint256 amount, uint256 referrerAmount, uint256 count, uint256 state, address user, address referrer, address[] memory referrers);
  function addBuyCarRecord(address userAddr, uint256 carId, uint256 amount, uint256 referrerAmount) external;
  function updateBuyCarRecord(uint256 buyCarRecordId, uint256 count, uint256 state, address referrer) external;
  function getMiniPhasesTotal() external view returns (uint256);
  function getMiniPhasesLastId() external view returns (uint256);
  function getCurrentMiniPhase() external view returns (uint256 id, uint256 amount, uint256 state, uint256 luckysCount, uint256 topsCount, address[] memory luckys, address[] memory tops);
  function getMiniPhaseAmount(uint256 phaseId) external view returns (uint256);
  function getMiniPhaseState(uint256 phaseId) external view returns (uint256);
  function getMiniPhaseLucysCount(uint256 phaseId) external view returns (uint256);
  function getMiniPhaseLucys(uint256 phaseId) external view returns (address[] memory);
  function getMiniPhaseTopsCount(uint256 phaseId) external view returns (uint256);
  function getMiniPhaseTops(uint256 phaseId) external view returns (address[] memory);
  function getMiniPhase(uint256 phaseId) external view returns (uint256 id, uint256 amount, uint256 state, uint256 luckysCount, uint256 topsCount, address[] memory luckys, address[] memory tops);
  function createMiniPhase() external;
  function updateMiniPhase(uint256 phaseId, uint256 amount, uint256 state) external;
  function addLucky(uint256 phaseId, address account) external;
  function removeLucky(uint256 phaseId, address account) external;
  function getTopFission(uint256 phaseId, address account) external view returns (uint256);
  function addTop(uint256 phaseId, address account, uint256 fission) external;
  function removeTop(uint256 phaseId, address account) external;
  function getLuckyReward(uint256 phaseId, address account) external view returns (uint256);
  function setLuckyReward(uint256 phaseId, address account, uint256 amount) external;
  function getTopReward(uint256 phaseId, address account) external view returns (uint256);
  function setTopReward(uint256 phaseId, address account, uint256 amount) external;
  function getAirdropStockToken() external view returns (address token, string memory name, string memory symbol, uint256 decimals);
  function setAirdropStockToken(address token) external;
  function getAirdropInterestToken() external view returns (address token, string memory name, string memory symbol, uint256 decimals);
  function setAirdropInterestToken(address token) external;
  function getAirdropTotalStockBalance(address token) external view returns (uint256);
  function addAirdropTotalStockBalance(address token, uint256 amount) external;
  function getAirdropTotalInterestBalance(address token) external view returns (uint256);
  function addAirdropTotalInterestBalance(address token, uint256 amount) external;
  function isAirdropInterest(string calldata date, uint256 userId) external view returns (bool);
  function setAirdropIsInterest(string calldata date, uint256 userId, bool isInterest) external;
  function getAirdropUserStockBalance(string calldata date, uint256 userId, address token) external view returns (uint256);
  function addAirdropUserStockBalance(string calldata date, uint256 userId, address token, uint256 amount) external;
  function getAirdropUserInterestBalance(string calldata date, uint256 userId, address token) external view returns (uint256);
  function addAirdropUserInterestBalance(string calldata date, uint256 userId, address token, uint256 amount) external;
  function getPointUser(uint256 carId, uint256 point, uint256 index) external view returns (address);
  function getPointUserCount(uint256 carId, uint256 point) external view returns (uint256);
  function addPointUser(uint256 carId, uint256 point, address userAddr) external;
  function removePointUser(uint256 carId, uint256 point, address userAddr) external;
  function emitEvent(string calldata eventName, bytes calldata payload) external;
}