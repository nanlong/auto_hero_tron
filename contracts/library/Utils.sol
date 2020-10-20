pragma solidity >=0.4.23 <0.6.0;

library Utils {

  function random(address account, uint256 salt, uint256 mod) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      salt,
      account,
      block.difficulty,
      block.number,
      block.timestamp
    ))) % mod;
  }
}