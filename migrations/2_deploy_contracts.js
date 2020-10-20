const TronWeb = require('tronweb');
const tronBox = require('../tronbox');
const fs = require('fs');
const output = require('./helpers/output');
const moment = require('moment');
const AutoHero = artifacts.require("./AutoHero.sol");
const AutoHeroStorage = artifacts.require("./AutoHeroStorage.sol");
const AutoHeroBank = artifacts.require("./AutoHeroBank.sol");


module.exports = async function(deployer, network, accounts) {
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

    const autoHeroStorage = await tronWeb.contract().at(autoHeroStorageAddr);
    await autoHeroStorage.setLogic(AutoHero.address).send({feeLimit: 1e9});

    const autoHeroBank = await tronWeb.contract().at(autoHeroBankAddr);
    await autoHeroBank.setLogic(AutoHero.address).send({feeLimit: 1e9});

    const autoHero = await AutoHero.deployed();
    await autoHero.setStorage(autoHeroStorageAddr);
    await autoHero.setBank(autoHeroBankAddr);

    config['contracts']['autoHero'] = tronWeb.address.fromHex(AutoHero.address);

    output(network, config);
  }

  async function deployed() {
    const tronWeb = new TronWeb({
      fullHost: tronBox.networks[network].fullHost
    });

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

    await autoHeroStorage.setBurned(true);
    await autoHeroStorage.setMiniOpened(true);
    await autoHeroStorage.setMiniAssigned(true);
    await autoHeroStorage.setMiniAssignBalance(5e6);
    await autoHeroStorage.setRatioDenominator(10000);
    await autoHeroStorage.setMiniRatio(5000, 5000);
    await autoHeroStorage.setAssignRatio(1000, 9000);
    await autoHeroStorage.setCommissionRatio(1000);
    await autoHeroStorage.setInterestRatio(30);

    await autoHeroStorage.setCar(1, 1e6);
    await autoHeroStorage.setCar(2, 2e6);
    await autoHeroStorage.setCar(3, 4e6);
    await autoHeroStorage.setCar(4, 8e6);
    await autoHeroStorage.setCar(5, 16e6);
    await autoHeroStorage.setCar(6, 32e6);
    await autoHeroStorage.setCar(7, 64e6);
    await autoHeroStorage.setCar(8, 128e6);
    await autoHeroStorage.setCar(9, 256e6);
    await autoHeroStorage.setCar(10, 512e6);
    await autoHeroStorage.setCar(11, 1024e6);
    await autoHeroStorage.setCar(12, 2048e6);

    if (network == 'shasta') {
      const stockToken = 'THqVx9K84Zp8cHNdoKknP53MZV9wtgELXg';
      const interestToken = 'TMWcoACjKu9wczbtKtjPnBRPqJVrowswTp';
      await autoHeroStorage.setTokenLocked(stockToken, true);
      await autoHeroStorage.setTokenLocked(interestToken, true);
      await autoHeroStorage.setAirdropStockToken(stockToken);
      await autoHeroStorage.setAirdropInterestToken(interestToken);
    }

    output(network, {
      deployTimestamp: Number(moment().format('X')) * 1000,
      contracts: {
        autoHero: tronWeb.address.fromHex(autoHero.address),
        autoHeroStorage: tronWeb.address.fromHex(autoHeroStorage.address),
        autoHeroBank: tronWeb.address.fromHex(autoHeroBank.address),
      }
    });
  }
};
