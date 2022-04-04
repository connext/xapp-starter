// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title Target
 * @notice A contrived example target contract.
 */
contract Target {
    mapping(address => mapping(address => uint256)) public balances;

    function deposit(address asset, uint256 amount, address onBehalfOf) public payable returns (uint256) {
      ERC20 erc20 = ERC20(asset);
      balances[asset][onBehalfOf] += amount;      
      erc20.transferFrom(msg.sender, address(this), amount);

      return balances[asset][onBehalfOf];
    }

    function withdraw(address asset, uint256 amount) public returns (uint256) {
      require(amount <= balances[asset][msg.sender], "Not enough deposited");

      ERC20 erc20 = ERC20(asset);
      balances[asset][msg.sender] -= amount;
      erc20.transfer(msg.sender, amount);

      return balances[asset][msg.sender];
    }

    function balance(address asset, address depositor) public view returns (uint256) {
      return balances[asset][depositor];
    }
}
