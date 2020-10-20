pragma solidity >=0.4.23 <0.6.0;

import "./library/AddressArray.sol";

library AutoHeroStructure {

  struct Config {
    bool burned; // 是否开启燃烧机制
    bool miniOpened; // 奖池是否开启
    bool miniAssigned; // 奖池是否允许分

    uint256 miniAssignBalance; // 奖池分配触发金额
    uint256 miniLuckyRatio; // 奖池Lucky分配比例
    uint256 miniTopRatio; // 奖池Top分配比例
    uint256 assignMiniRatio; // 业绩分配给奖池的比例
    uint256 assignReferrerRatio; // 业绩分配给推荐人的比例
    uint256 commissionRatio; // 手续费比例
    uint256 interestRatio; // 股息率
    uint256 ratioDenominator; // 比例分母

    mapping (address => bool) tokenLocked; // 通证是否锁仓
  }

  struct Data {
    uint256 totalUserCount; // 总用户数量
    uint256 totalCarCount; // 总汽车数量
    uint256 totalCarOwnerCount; // 总购买过汽车的用户数量
    uint256 totalUserCarCount; // 总用户购买的汽车数量

    mapping (address => uint256) totalBalances; // 总流水
    mapping (address => uint256) referrerBalances;// 总业绩
    mapping (address => uint256) miniBalances; // 总奖池
    mapping (address => uint256) feeBalances; // 总手续费
    mapping (address => uint256) feeAvailableBalances; // 未提现的手续费
    mapping (address => uint256) feeWithdrawnBalances; // 已提现的手续费
  }

  struct Car {
    uint256 id; // 汽车ID
    uint256 price; // 汽车价格
  }

  struct Cars {
    uint256 total; // 总汽车数
    mapping (uint256 => Car) data; // 汽车列表
  }

  struct User {
    uint256 id; // 用户ID
    uint256 carCount; // 汽车数量
    uint256 partnersCount; // 团队成员数量
    uint256 state; // 用户状态

    address addr; // 用户地址
    address referrer; // 推荐人
  }

  struct Users {
    uint256 lastId; // 自增ID
    mapping (uint256 => User) data; // 用户列表
    mapping (address => uint256) addressToId; // 地址转ID
  }

  struct UserAccount {
    mapping (address => uint256) consumeBalances; // 通证消费金额
    mapping (address => uint256) depositBalances; // 通证存款
    mapping (address => uint256) availableBalances; // 通证可用余额
    mapping (address => uint256) withdrawnBalances; // 通证已提现
  }

  struct UserAccounts {
    mapping (uint256 => UserAccount) data; // 用户账户
  }

  struct UserCar {
    uint256 carId; // 汽车ID
    uint256 partnersCount; // 成员数量
    uint256 reinvestCount; //  重置次数
    uint256 state; // 状态
    uint256[] points; // 点位
    uint256[] pointsState; // 点位状态
  }

  struct UserCars {
    mapping (uint256 => mapping (uint256 => UserCar)) data; // 用户汽车数据
    mapping (uint256 => mapping (uint256 => bool)) activeness; // 用户拥有的车
    mapping (uint256 => mapping (uint256 => AddressArray.Addresses)) pointUsers; // 不同点位的用户列表
  }

  struct BuyCarRecord {
    uint256 id; // 记录ID
    uint256 carId; // 汽车ID
    uint256 amount; // 购车金额
    uint256 referrerAmount;
    uint256 count; // 点位查询次数
    uint256 state; // 状态
    address user; // 购车用户
    address referrer; // 业绩用户
    AddressArray.Addresses referrers; // 点位查询记录
  }

  struct BuyCarRecords {
    uint256 lastId;
    mapping(uint256 => BuyCarRecord) data;
  }

  struct MiniPhase {
    uint256 id; // 开奖期数
    uint256 amount; // 开奖资金池
    uint256 state; // 状态

    mapping (address => uint256) luckyReward;
    mapping (address => uint256) topReward;
    mapping (address => uint256) topFission;

    AddressArray.Addresses luckys;
    AddressArray.Addresses tops;
  }

  struct MiniPhases {
    uint256 total;
    uint256 lastId;
    mapping (uint256 => MiniPhase) data;
  }

  struct Token {
    address addr; // 通证地址
    string name; // 通证名称
    string symbol; // 通证代码
    uint256 decimals; // 通证精度
  }

  struct Airdrop {
    Token stockToken; // 股通证
    Token interestToken; // 息通证

    mapping (address => uint256) totalStockBalances;
    mapping (address => uint256) totalInterestBalances;
    mapping (string => mapping (uint256 => bool)) isInterest;
    mapping (string => mapping (uint256 => mapping (address => uint256))) userStockBalances;
    mapping (string => mapping (uint256 => mapping (address => uint256))) userInterestBalances;
  }
}