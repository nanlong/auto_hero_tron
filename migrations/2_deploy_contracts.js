const TronWeb = require('tronweb');
const tronBox = require('../tronbox');
const fs = require('fs');
const output = require('./helpers/output');
const moment = require('moment');
const AutoHero = artifacts.require("./AutoHero.sol");
const AutoHeroStorage = artifacts.require("./AutoHeroStorage.sol");
const AutoHeroBank = artifacts.require("./AutoHeroBank.sol");


module.exports = async function(deployer, network, accounts) {
  const deployConfig = require('../deploy-config').networks[network];

  // 测试
  if (process.env.CURRENT == 'test') {
    test();
    return;
  }

  if (process.env.CURRENT == 'migrate') {
    const deployedFile = './deployed/' + network + '.json'

    if (fs.existsSync(deployedFile)) {
      upgrade(read(deployedFile));
    } else {
      deployed();
    }
  }

  function read(file) {
    let buffer = fs.readFileSync(file);
    buffer = JSON.stringify(buffer);
    buffer = JSON.parse(buffer);
    buffer = Buffer.from(buffer);
    return JSON.parse(buffer.toString());
  }

  async function test() {
    await deployer.deploy(AutoHeroStorage);
    await deployer.deploy(AutoHeroBank);
    await deployer.deploy(AutoHero);

    const autoHeroStorage = await AutoHeroStorage.deployed();
    const autoHeroBank = await AutoHeroBank.deployed();
    const autoHero = await AutoHero.deployed();

    await autoHeroStorage.setLogic(AutoHero.address);
    await autoHeroBank.setLogic(AutoHero.address);

    await autoHero.setStorage(AutoHeroStorage.address);
    await autoHero.setBank(autoHeroBank.address);
  }

  async function upgrade(config) {
    const tronWeb = new TronWeb({
      fullHost: tronBox.networks[network].fullHost
    });

    tronWeb.setPrivateKey(tronBox.networks[network].privateKey);
    const autoHeroStorageAddr = config['contracts']['autoHeroStorage'];
    const autoHeroBankAddr = config['contracts']['autoHeroBank'];

    await deployer.deploy(AutoHero);

    config['contracts']['autoHero'] = tronWeb.address.fromHex(AutoHero.address);
    output(network, config);

    const autoHeroStorage = await tronWeb.contract().at(autoHeroStorageAddr);
    await autoHeroStorage.setLogic(AutoHero.address).send({feeLimit: 1e9});

    const autoHeroBank = await tronWeb.contract().at(autoHeroBankAddr);
    await autoHeroBank.setLogic(AutoHero.address).send({feeLimit: 1e9});

    const autoHero = await AutoHero.deployed();
    await autoHero.setStorage(autoHeroStorageAddr);
    await autoHero.setBank(autoHeroBankAddr);

    for (let i = 0; i < deployConfig.whitelistAdmins.length; i++) {
      await autoHero.addWhitelistAdmin(deployConfig.whitelistAdmins[i]);
    }
  }

  async function deployed() {
    const tronWeb = new TronWeb({
      fullHost: tronBox.networks[network].fullHost
    });

    await deployer.deploy(AutoHeroStorage);
    await deployer.deploy(AutoHeroBank);
    await deployer.deploy(AutoHero);

    output(network, {
      deployTimestamp: Number(moment().format('X')) * 1000,
      contracts: {
        autoHero: tronWeb.address.fromHex(AutoHero.address),
        autoHeroStorage: tronWeb.address.fromHex(AutoHeroStorage.address),
        autoHeroBank: tronWeb.address.fromHex(AutoHeroBank.address),
      }
    });

    const autoHeroStorage = await AutoHeroStorage.deployed();
    const autoHeroBank = await AutoHeroBank.deployed();
    const autoHero = await AutoHero.deployed();

    await autoHeroStorage.setLogic(AutoHero.address);
    await autoHeroBank.setLogic(AutoHero.address);

    await autoHero.setStorage(AutoHeroStorage.address);
    await autoHero.setBank(autoHeroBank.address);

    await autoHeroStorage.setBurned(deployConfig.burned);
    await autoHeroStorage.setMiniOpened(deployConfig.miniOpened);
    await autoHeroStorage.setMiniAssigned(deployConfig.miniAssigned);
    await autoHeroStorage.setMiniAssignBalance(deployConfig.miniAssignBalance);
    await autoHeroStorage.setRatioDenominator(deployConfig.ratioDenominator);
    await autoHeroStorage.setMiniRatio(deployConfig.miniLuckyRatio, deployConfig.miniTopRatio);
    await autoHeroStorage.setAssignRatio(deployConfig.assignMiniRatio, deployConfig.assignReferrerRatio);
    await autoHeroStorage.setCommissionRatio(deployConfig.commissionRatio);
    await autoHeroStorage.setInterestRatio(deployConfig.interestRatio);

    if (deployConfig.stockToken) {
      await autoHeroStorage.setAirdropStockToken(deployConfig.stockToken);
    }

    if (deployConfig.interestToken) {
      await autoHeroStorage.setAirdropInterestToken(deployConfig.stockToken);
    }

    for (var i = 0; i < deployConfig.whitelistAdmins.length; i++) {
      await autoHero.addWhitelistAdmin(deployConfig.whitelistAdmins[i]);
      await autoHeroBank.addWhitelistAdmin(deployConfig.whitelistAdmins[i]);
      await autoHeroStorage.addWhitelistAdmin(deployConfig.whitelistAdmins[i]);
    }

    for (var i = 0; i < deployConfig.tokenLocked.length; i++) {
      await autoHeroStorage.setTokenLocked(deployConfig.tokenLocked[i], true);
    }

    for (var i = 0; i < deployConfig.cars.length; i++) {
      var car = deployConfig.cars[i];
      await autoHero.setCar(car.id, car.price);
    }
  }
};
