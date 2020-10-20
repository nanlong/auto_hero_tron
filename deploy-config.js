module.exports = {
  networks: {
    development: {
      burned: true,
      miniOpened: true,
      miniAssigned: true,
      miniAssignBalance: 1000e6,
      ratioDenominator: 10000,
      miniLuckyRatio: 5000,
      miniTopRatio: 5000,
      assignMiniRatio: 1000,
      assignReferrerRatio: 9000,
      commissionRatio: 1000,
      interestRatio: 30,
      stockToken: null,
      interestToken: null,
      tokenLocked: [],
      whitelistAdmins: [],
      cars: []
    },
    shasta: {
      burned: true,
      miniOpened: true,
      miniAssigned: true,
      miniAssignBalance: 10e6,
      ratioDenominator: 10000,
      miniLuckyRatio: 5000,
      miniTopRatio: 5000,
      assignMiniRatio: 1000,
      assignReferrerRatio: 9000,
      commissionRatio: 1000,
      interestRatio: 30,
      stockToken: 'THqVx9K84Zp8cHNdoKknP53MZV9wtgELXg',
      interestToken: 'TMWcoACjKu9wczbtKtjPnBRPqJVrowswTp',
      tokenLocked: [
        'THqVx9K84Zp8cHNdoKknP53MZV9wtgELXg',
        'TMWcoACjKu9wczbtKtjPnBRPqJVrowswTp'
      ],
      whitelistAdmins: [
        'TGKaeLBzNdDYKeNA1LQg7FnWBf2kczPvKA'
      ],
      cars: [
        {id: 1, price: 1e6},
        {id: 2, price: 2e6},
        {id: 3, price: 4e6},
        {id: 4, price: 8e6},
        {id: 5, price: 16e6},
        {id: 6, price: 31e6},
        {id: 7, price: 64e6},
        {id: 8, price: 128e6},
        {id: 9, price: 256e6},
        {id: 10, price: 512e6},
        {id: 11, price: 1024e6},
        {id: 12, price: 2048e6},
      ]
    },
  }
}