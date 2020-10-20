const AutoHeroStorage = artifacts.require('./AutoHeroStorage.sol');

contract('AutoHeroStorageTest', async (accounts) => {
  let autoHeroStorage;
  let mainToken = 'T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb';
  let stockToken = 'TQakNHXAgipkwDqxeDNungNZRqt5tt8eHK';
  let interestToken = 'TC4sgBbJPLCkm2Cx3mqVMzxkxuHZLMSRyH';

  before(async function() {
    autoHeroStorage = await AutoHeroStorage.deployed();
    await autoHeroStorage.setLogic.call(accounts[0]);
  });

  it('setBurned', async () => {
    await autoHeroStorage.setBurned.call(true);
    assert.isTrue((await autoHeroStorage.getBurned.call()));

    await autoHeroStorage.setBurned.call(false);
    assert.isFalse((await autoHeroStorage.getBurned.call()));
  });

  it('setMiniOpened', async () => {
    await autoHeroStorage.setMiniOpened.call(true);
    assert.isTrue((await autoHeroStorage.getMiniOpended.call()));

    await autoHeroStorage.setMiniOpened.call(false);
    assert.isFalse((await autoHeroStorage.getMiniOpended.call()));
  });

  it('setMiniAssigned', async () => {
    await autoHeroStorage.setMiniAssigned.call(true);
    assert.isTrue((await autoHeroStorage.getMiniAssigned.call()));

    await autoHeroStorage.setMiniAssigned.call(false);
    assert.isFalse((await autoHeroStorage.getMiniAssigned.call()));
  });

  it('setMiniAssignBalance', async () => {
    await autoHeroStorage.setMiniAssignBalance.call(5e6);
    assert.equal((await autoHeroStorage.getMiniAssignBalance.call()), 5e6);

    await autoHeroStorage.setMiniAssignBalance.call(10e6);
    assert.equal((await autoHeroStorage.getMiniAssignBalance.call()), 10e6);
  });

  it('setRatioDenominator', async () => {
    await autoHeroStorage.setRatioDenominator.call(1000);
    assert.equal((await autoHeroStorage.getRatioDenominator.call()), 1000);

    await autoHeroStorage.setRatioDenominator.call(10000);
    assert.equal((await autoHeroStorage.getRatioDenominator.call()), 10000);
  });

  it('setMiniRatio', async () => {
    await autoHeroStorage.setMiniRatio.call(4000, 6000);

    let miniRatio = await autoHeroStorage.getMiniRatio.call();
    assert.equal(miniRatio.luckyRatio, 4000);
    assert.equal(miniRatio.topRatio, 6000);
    assert.equal(miniRatio.denominator, 10000);

    await autoHeroStorage.setMiniRatio.call(5000, 5000);

    miniRatio = await autoHeroStorage.getMiniRatio.call();
    assert.equal(miniRatio.luckyRatio, 5000);
    assert.equal(miniRatio.topRatio, 5000);
    assert.equal(miniRatio.denominator, 10000);
  });

  it('setAssignRatio', async () => {
    await autoHeroStorage.setAssignRatio.call(2000, 8000);

    let assignRatio = await autoHeroStorage.getAssignRatio.call();
    assert.equal(assignRatio.miniRatio, 2000);
    assert.equal(assignRatio.referrerRatio, 8000);
    assert.equal(assignRatio.denominator, 10000);

    await autoHeroStorage.setAssignRatio.call(1000, 9000);

    assignRatio = await autoHeroStorage.getAssignRatio.call();
    assert.equal(assignRatio.miniRatio, 1000);
    assert.equal(assignRatio.referrerRatio, 9000);
    assert.equal(assignRatio.denominator, 10000);
  });

  it('setCommissionRatio', async () => {
    await autoHeroStorage.setCommissionRatio.call(500);

    let commissionRatio = await autoHeroStorage.getCommissionRatio.call();
    assert.equal(commissionRatio.ratio, 500);
    assert.equal(commissionRatio.denominator, 10000);

    await autoHeroStorage.setCommissionRatio.call(1000);

    commissionRatio = await autoHeroStorage.getCommissionRatio.call();
    assert.equal(commissionRatio.ratio, 1000);
    assert.equal(commissionRatio.denominator, 10000);
  });

  it('setInterestRatio', async () => {
    await autoHeroStorage.setInterestRatio.call(30);

    let interestRatio = await autoHeroStorage.getInterestRatio.call();
    assert.equal(interestRatio.ratio, 30);
    assert.equal(interestRatio.denominator, 10000);

    await autoHeroStorage.setCommissionRatio.call(50);

    interestRatio = await autoHeroStorage.getInterestRatio.call();
    assert.equal(interestRatio.ratio, 50);
    assert.equal(interestRatio.denominator, 10000);
  });

  it('setTokenLocked', async () => {
    await autoHeroStorage.setTokenLocked.call(stockToken, true);
    assert.isTrue((await autoHeroStorage.getTokenLocked.call(stockToken)));

    await autoHeroStorage.setTokenLocked.call(stockToken, false);
    assert.isFalse((await autoHeroStorage.getTokenLocked.call(stockToken)));
  });

  it('addTotalCarCount', async () => {
    await autoHeroStorage.addTotalCarCount.call(1);
    assert.equal((await autoHeroStorage.data.call()).totalCarCount, 1);

    await autoHeroStorage.addTotalCarCount.call(2);
    assert.equal((await autoHeroStorage.data.call()).totalCarCount, 3);
  });

  it('addTotalUserCount', async () => {
    await autoHeroStorage.addTotalUserCount.call(1);
    assert.equal((await autoHeroStorage.data.call()).totalUserCount, 1);

    await autoHeroStorage.addTotalUserCount.call(2);
    assert.equal((await autoHeroStorage.data.call()).totalUserCount, 3);
  });

  it('addTotalCarOwnerCount', async () => {
    await autoHeroStorage.addTotalCarOwnerCount.call(1);
    assert.equal((await autoHeroStorage.data.call()).totalCarOwnerCount, 1);

    await autoHeroStorage.addTotalCarOwnerCount.call(2);
    assert.equal((await autoHeroStorage.data.call()).totalCarOwnerCount, 3);
  });

  it('addTotalUserCarCount', async () => {
    await autoHeroStorage.addTotalUserCarCount.call(1);
    assert.equal((await autoHeroStorage.data.call()).totalUserCarCount, 1);

    await autoHeroStorage.addTotalUserCarCount.call(2);
    assert.equal((await autoHeroStorage.data.call()).totalUserCarCount, 3);
  });

  it('addTotalBalance', async () => {
    await autoHeroStorage.addTotalBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getTotalBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addTotalBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getTotalBalance.call(mainToken)), 10e6);
  });

  it('addReferrerBalance', async () => {
    await autoHeroStorage.addReferrerBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getReferrerBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addReferrerBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getReferrerBalance.call(mainToken)), 10e6);
  });

  it('addMiniBalance', async () => {
    await autoHeroStorage.addMiniBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getMiniBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addMiniBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getMiniBalance.call(mainToken)), 10e6);
  });

  it('addFeeBalance', async () => {
    await autoHeroStorage.addFeeBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addFeeBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeBalance.call(mainToken)), 10e6);
  });

  it('addFeeAvailableBalance', async () => {
    await autoHeroStorage.addFeeAvailableBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeAvailableBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addFeeAvailableBalance.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeAvailableBalance.call(mainToken)), 10e6);
  });

  it('subFeeAvailableBalance', async () => {
    await autoHeroStorage.subFeeAvailableBalance.call(mainToken, 4e6);
    assert.equal((await autoHeroStorage.getFeeAvailableBalance.call(mainToken)), 6e6);
  });

  it('addFeeWithdrawnBalances', async () => {
    await autoHeroStorage.addFeeWithdrawnBalances.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeWithdrawnBalance.call(mainToken)), 5e6);

    await autoHeroStorage.addFeeWithdrawnBalances.call(mainToken, 5e6);
    assert.equal((await autoHeroStorage.getFeeWithdrawnBalance.call(mainToken)), 10e6);
  });

  it('subFeeWithdrawnBalances', async () => {
    await autoHeroStorage.subFeeWithdrawnBalances.call(mainToken, 4e6);
    assert.equal((await autoHeroStorage.getFeeWithdrawnBalance.call(mainToken)), 6e6);
  });

  it('setCar', async () => {
    await autoHeroStorage.setCar.call(1, 5e6);
    assert.equal((await autoHeroStorage.getCar.call(1)).price, 5e6);

    await autoHeroStorage.setCar.call(2, 10e6);
    assert.equal((await autoHeroStorage.getCar.call(2)).price, 10e6);

    assert.isTrue(await autoHeroStorage.isCarExist.call(2));
    assert.isFalse(await autoHeroStorage.isCarExist.call(3));
  });

  it('addUser', async () => {
    await autoHeroStorage.addUser.call(accounts[0], accounts[1]);
    const user = await autoHeroStorage.getUser.call(accounts[0]);

    assert.equal(user.id, 1);
    assert.equal(tronWeb.address.fromHex(user.addr), accounts[0]);
    assert.equal(tronWeb.address.fromHex(user.referrer), accounts[1]);
    assert.equal(user.carCount, 0);
    assert.equal(user.partnersCount, 0);
    assert.equal(user.state, 0);

    assert.equal(await autoHeroStorage.getUserId.call(accounts[0]), 1);
    assert.equal(await autoHeroStorage.getUserId.call(accounts[1]), 0);
  });

  it('updateUser', async () => {
    await autoHeroStorage.updateUser.call(accounts[0], accounts[2], 1, 1, 1);
    const user = await autoHeroStorage.getUser.call(accounts[0]);

    assert.equal(user.id, 1);
    assert.equal(tronWeb.address.fromHex(user.addr), accounts[0]);
    assert.equal(tronWeb.address.fromHex(user.referrer), accounts[2]);
    assert.equal(user.carCount, 1);
    assert.equal(user.partnersCount, 1);
    assert.equal(user.state, 1);
  });

  it('addUserConsumeBalance', async () => {
    await autoHeroStorage.addUserConsumeBalance.call(accounts[0], mainToken, 5e6);
    assert.equal(await autoHeroStorage.getUserConsumeBalance.call(accounts[0], mainToken), 5e6);

    await autoHeroStorage.addUserConsumeBalance.call(accounts[0], mainToken, 10e6);
    assert.equal(await autoHeroStorage.getUserConsumeBalance.call(accounts[0], mainToken), 15e6);
  });

  it('addUserDepositBalance', async () => {
    await autoHeroStorage.addUserDepositBalance.call(accounts[0], mainToken, 5e6, "sendReceive");
    assert.equal(await autoHeroStorage.getUserDepositBalance.call(accounts[0], mainToken), 5e6);

    await autoHeroStorage.addUserDepositBalance.call(accounts[0], mainToken, 10e6, "sendReceive");
    assert.equal(await autoHeroStorage.getUserDepositBalance.call(accounts[0], mainToken), 15e6);
  });

  it('setUserAvailableBalance', async () => {
    await autoHeroStorage.setUserAvailableBalance.call(accounts[0], mainToken, 5e6);
    assert.equal(await autoHeroStorage.getUserAvailableBalance.call(accounts[0], mainToken), 5e6);

    await autoHeroStorage.setUserAvailableBalance.call(accounts[0], mainToken, 10e6);
    assert.equal(await autoHeroStorage.getUserAvailableBalance.call(accounts[0], mainToken), 10e6);
  });

  it('setUserWithdrawnBalances', async () => {
    await autoHeroStorage.setUserWithdrawnBalances.call(accounts[0], mainToken, 5e6);
    assert.equal(await autoHeroStorage.getUserWithdrawnBalances.call(accounts[0], mainToken), 5e6);

    await autoHeroStorage.setUserWithdrawnBalances.call(accounts[0], mainToken, 10e6);
    assert.equal(await autoHeroStorage.getUserWithdrawnBalances.call(accounts[0], mainToken), 10e6);
  });

  it('addUserCar', async () => {
    await autoHeroStorage.addUserCar.call(accounts[0], 1, [1, 1, 2, 2]);
    const userCar = await autoHeroStorage.getUserCar(accounts[0], 1);

    assert.equal(userCar.points[0], 1);
    assert.equal(userCar.points[1], 1);
    assert.equal(userCar.points[2], 2);
    assert.equal(userCar.points[3], 2);
    assert.equal(userCar.pointsState.length, 0);
    assert.equal(userCar.partnersCount, 0);
    assert.equal(userCar.reinvestCount, 0);
    assert.equal(userCar.state, 0);
  });

  it('updateUserCar', async () => {
    await autoHeroStorage.updateUserCar.call(accounts[0], 1, 1, 1, 1, [1, 1, 2, 2], [1, 1, 1]);
    const userCar = await autoHeroStorage.getUserCar(accounts[0], 1);

    assert.equal(userCar.points[0], 1);
    assert.equal(userCar.points[1], 1);
    assert.equal(userCar.points[2], 2);
    assert.equal(userCar.points[3], 2);
    assert.equal(userCar.pointsState[0], 1);
    assert.equal(userCar.pointsState[1], 1);
    assert.equal(userCar.pointsState[2], 1);
    assert.equal(userCar.partnersCount, 1);
    assert.equal(userCar.reinvestCount, 1);
    assert.equal(userCar.state, 1);
  });

  it('createMiniPhase', async () => {
    await autoHeroStorage.createMiniPhase.call();
    const miniPhase = await autoHeroStorage.getCurrentMiniPhase.call();

    assert.equal(miniPhase.id, 1);
    assert.equal(miniPhase.amount, 0);
    assert.equal(miniPhase.state, 0);
    assert.equal(miniPhase.luckysCount, 0);
    assert.equal(miniPhase.topsCount, 0);
    assert.equal(miniPhase.luckys.length, 0);
    assert.equal(miniPhase.tops.length, 0);

    const miniPhaseId = miniPhase.id.toNumber();
    assert.equal(await autoHeroStorage.getMiniPhasesTotal.call(), 1);
    assert.equal(await autoHeroStorage.getMiniPhasesLastId.call(), 1);
    assert.equal(await autoHeroStorage.getMiniPhaseAmount.call(miniPhaseId), 0);
    assert.equal(await autoHeroStorage.getMiniPhaseState.call(miniPhaseId), 0);
    assert.equal(await autoHeroStorage.getMiniPhaseLucysCount.call(miniPhaseId), 0);
    assert.equal(await autoHeroStorage.getMiniPhaseTopsCount.call(miniPhaseId), 0);
    assert.equal((await autoHeroStorage.getMiniPhaseLucys.call(miniPhaseId)).length, 0);
    assert.equal((await autoHeroStorage.getMiniPhaseTops.call(miniPhaseId)).length, 0);
  });

  it('addLucky', async () => {
    await autoHeroStorage.addLucky.call(1, accounts[0]);
    const miniPhase = await autoHeroStorage.getMiniPhase.call(1);

    assert.equal(miniPhase.luckysCount, 1);
    assert.equal(tronWeb.address.fromHex(miniPhase.luckys[0]), accounts[0]);
  });

  it('setLuckyReward', async () => {
    await autoHeroStorage.setLuckyReward.call(1, accounts[0], 5e6);

    assert.equal(await autoHeroStorage.getLuckyReward(1, accounts[0]), 5e6);
  });

  it('removeLucky', async () => {
    await autoHeroStorage.removeLucky.call(1, accounts[0]);
    const miniPhase = await autoHeroStorage.getMiniPhase.call(1);

    assert.equal(miniPhase.luckysCount, 0);
    assert.equal(miniPhase.luckys.length, 0);
  })

  it('addTop', async () => {
    await autoHeroStorage.addTop.call(1, accounts[0], 2);
    const miniPhase = await autoHeroStorage.getMiniPhase.call(1);

    assert.equal(miniPhase.topsCount, 1);
    assert.equal(tronWeb.address.fromHex(miniPhase.tops[0]), accounts[0]);
    assert.equal(await autoHeroStorage.getTopFission.call(1, accounts[0]), 2);
  });

  it('setTopReward', async () => {
    await autoHeroStorage.setTopReward.call(1, accounts[0], 5e6);

    assert.equal(await autoHeroStorage.getTopReward(1, accounts[0]), 5e6);
  });

  it('removeTop', async () => {
    await autoHeroStorage.removeTop.call(1, accounts[0]);
    const miniPhase = await autoHeroStorage.getMiniPhase.call(1);

    assert.equal(miniPhase.topsCount, 0);
    assert.equal(miniPhase.tops.length, 0);
  });

  it('updateMiniPhase', async () => {
    await autoHeroStorage.updateMiniPhase.call(1, 5e6, 1);

    const miniPhase = await autoHeroStorage.getMiniPhase.call(1);
    assert.equal(miniPhase.id, 1);
    assert.equal(miniPhase.amount, 5e6);
    assert.equal(miniPhase.state, 1);
  });

  it('addAirdropTotalStockBalance', async () => {
    await autoHeroStorage.addAirdropTotalStockBalance.call(stockToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropTotalStockBalance.call(stockToken), 5e6);

    await autoHeroStorage.addAirdropTotalStockBalance.call(stockToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropTotalStockBalance.call(stockToken), 10e6);
  });

  it('addAirdropTotalInterestBalance', async () => {
    await autoHeroStorage.addAirdropTotalInterestBalance.call(interestToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropTotalInterestBalance.call(interestToken), 5e6);

    await autoHeroStorage.addAirdropTotalInterestBalance.call(interestToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropTotalInterestBalance.call(interestToken), 10e6);
  });

  it('setAirdropIsInterest', async () => {
    await autoHeroStorage.setAirdropIsInterest.call("2020-10-01", 1, true);
    assert.isTrue(await autoHeroStorage.isAirdropInterest.call("2020-10-01", 1));
  });

  it('addAirdropUserStockBalance', async () => {
    await autoHeroStorage.addAirdropUserStockBalance.call("2020-10-01", 1, stockToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropUserStockBalance.call("2020-10-01", 1, stockToken), 5e6);
  });

  it('addAirdropUserInterestBalance', async () => {
    await autoHeroStorage.addAirdropUserInterestBalance.call("2020-10-01", 1, interestToken, 5e6);
    assert.equal(await autoHeroStorage.getAirdropUserInterestBalance.call("2020-10-01", 1, interestToken), 5e6);
  });

  it('addBuyCarRecord', async () => {
    await autoHeroStorage.addBuyCarRecord.call(accounts[0], 1, 5e6, 4.5e6);

    const buyCarRecord = await autoHeroStorage.getBuyCarRecord.call(1);

    assert.equal(buyCarRecord.id, 1);
    assert.equal(buyCarRecord.carId, 1);
    assert.equal(buyCarRecord.amount, 5e6);
    assert.equal(buyCarRecord.referrerAmount, 4.5e6);
    assert.equal(buyCarRecord.count, 0);
    assert.equal(buyCarRecord.state, 0);
    assert.equal(tronWeb.address.fromHex(buyCarRecord.user), accounts[0]);
    assert.equal(tronWeb.address.fromHex(buyCarRecord.referrer), accounts[0]);
    assert.equal(buyCarRecord.referrers.length, 0);
  });

  it('updateBuyCarRecord', async () => {
    await autoHeroStorage.updateBuyCarRecord.call(1, 1, 1, accounts[1]);

    const buyCarRecord = await autoHeroStorage.getBuyCarRecord.call(1);
    assert.equal(buyCarRecord.count, 1);
    assert.equal(buyCarRecord.state, 1);
    assert.equal(tronWeb.address.fromHex(buyCarRecord.referrer), accounts[1]);
  });

  it('addPointUser', async () => {
    await autoHeroStorage.addPointUser(1, 0, accounts[1]);

    assert.equal(await autoHeroStorage.getPointUserCount.call(1, 0), 1);
    assert.equal(tronWeb.address.fromHex(await autoHeroStorage.getPointUser(1, 0, 0)), accounts[1]);

    await autoHeroStorage.removePointUser(1, 0, accounts[1]);
    assert.equal(await autoHeroStorage.getPointUserCount.call(1, 0), 0);
  });
});