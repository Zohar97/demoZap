// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BasicToken is ERC20 {
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _totalSupply
  ) public ERC20(_name, _symbol) {
    _mint(msg.sender, _totalSupply);
  }

  function giveMe(uint256 amount) external {
    _mint(msg.sender, amount);
  }
}
