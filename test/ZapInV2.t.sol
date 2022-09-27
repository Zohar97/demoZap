// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {Test as t} from 'forge-std/Test.sol';
import {console} from 'forge-std/console.sol';
import {ZapInV2} from '../../src/ZapInV2.sol';
import {KSFactory} from '../../src/KSFactory.sol';
import {KSRouter02} from '../../src/KSRouter02.sol';
import {TestToken} from '../../src/mock/TestToken.sol';
import {WETH9} from '../../src/mock/WETH9.sol';


contract ZapInBase is t {
  KSFactory public f;
  KSRouter02 public r;
  ZapInV2 public zap;
  TestToken public tokenA;
  WETH9 public weth;

  address public deployer;
  address public user1;
  address public user2;
  uint256 public MAX_UINT256 = type(uint256).max;
  uint256 public constant DEAD_LINE = 2524582800; // Jan 1, 2050

  function setUp() public virtual{
    (deployer, privDeployer) = makeAddrAndKey('Deployer');
    (feeReceiver, privF) = makeAddrAndKey('FeeRe');
    (user1, privUser1) = makeAddrAndKey('Zohar');
    (user2, privUser2) = makeAddrAndKey('Rahoz');
    vm.startPrank(deployer);
    weth = new WETH9();
    tokenA = new TestToken('Token A', 'TKA', 1_000_000 ether);
    f = new KSFactory(address(feeReceiver));

  }


}