pragma solidity >=0.4.23 <0.6.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/roles/WhitelistAdminRole.sol";

contract AutoHeroBank is Ownable, WhitelistAdminRole {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  function() external payable {}

  // - 逻辑合约 -
  address public autoHeroLogic;

  modifier onlyLogic() {
    require(_msgSender() == autoHeroLogic || _msgSender() == owner());
    _;
  }

  function setLogic(address _autoHeroLogic) public onlyWhitelistAdmin {
    autoHeroLogic = _autoHeroLogic;
  }

  uint256 public balance;

  function addBalance(uint256 amount) public onlyLogic {
    balance = balance.add(amount);
  }

  function withdraw(address userAddr, address token, uint256 amount) public onlyLogic {
    if (token == address(0)) {
      require(amount <= balance);
      balance = balance.sub(amount);
      Address.toPayable(userAddr).transfer(amount);
    } else {
      require(amount <= ERC20(token).balanceOf(address(this)));
      ERC20(token).safeTransfer(userAddr, amount);
    }
  }
}