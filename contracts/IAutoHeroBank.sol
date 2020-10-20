pragma solidity >=0.4.23 <0.6.0;

interface IAutoHeroBank {
  function addBalance(uint amount) external;
  function withdraw(address userAddr, address token, uint256 amount) external;
}