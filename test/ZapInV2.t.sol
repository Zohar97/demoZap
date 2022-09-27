// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test as t} from 'forge-std/Test.sol';
import {console} from 'forge-std/console.sol';
import {ZapInV2} from '../src/ZapInV2.sol';
import {KSFactory} from '../src/KSFactory.sol';
import {KSPool} from '../src/KSPool.sol';
import {KSRouter02} from '../src/KSRouter02.sol';
import {BasicToken} from '../src/mock/BasicToken.sol';
import {WETH9} from '../src/mock/WETH9.sol';
import {IWETH} from '../src/interfaces/IWETH.sol';
import {IKSPool} from '../src/interfaces/IKSPool.sol';
import {IKSFactory} from '../src/interfaces/IKSFactory.sol';
import {ERC20Permit} from '../src/libraries/ERC20Permit.sol';

contract ZapInBase is t {
  KSFactory public f;
  KSRouter02 public r;
  ZapInV2 public zap;
  BasicToken public tokenA;
  WETH9 public weth;

  address public deployer;
  address public feeReceiver;
  address public user1;
  address public user2;
  address public token0Addr;
  address public poolAddress;
  uint256 public privDeployer;
  uint256 public privF;
  uint256 public privUser1;
  uint256 public privUser2;
  uint256 public MAX_UINT256 = type(uint256).max;
  uint256 public constant DEAD_LINE = 2524582800; // Jan 1, 2050
  uint256 public constant INIT_AMOUNT = 1_000_000 ether;
  uint256 public constant PRECISION_UNITS = 1 ether;
  uint32[2] public AMP_BPS_DEFAULT = [uint32(10_000), uint32(1000)]; // [ampBPS 1, fee]

  function setUp() public virtual {
    (deployer, privDeployer) = makeAddrAndKey('Deployer');
    (feeReceiver, privF) = makeAddrAndKey('FeeReceiver');
    (user1, privUser1) = makeAddrAndKey('Zohar');
    (user2, privUser2) = makeAddrAndKey('Rahoz');
    startHoax(deployer, INIT_AMOUNT);
    weth = new WETH9();
    tokenA = new BasicToken('Token A', 'TKA', INIT_AMOUNT);

    f = new KSFactory(address(deployer));
    f.setFeeConfiguration(address(feeReceiver), 1000);
    r = new KSRouter02(address(f), IWETH(address(weth)));
    tokenA.approve(address(r), MAX_UINT256);

    r.addLiquidityNewPoolETH{value: 30 ether}(
      IERC20(tokenA),
      AMP_BPS_DEFAULT,
      100 * PRECISION_UNITS,
      0,
      0,
      address(deployer),
      DEAD_LINE
    );
    address[] memory pools = f.getPools(IERC20(tokenA), IERC20(address(weth)));
    poolAddress = pools[0];
    token0Addr = address(IKSPool(poolAddress).token0());
    // swap to change the ratio of the pool a bit
    address[] memory poolsPath = new address[](1);
    poolsPath[0] = poolAddress;

    IERC20[] memory path = new IERC20[](2);
    path[0] = IERC20(address(weth));
    path[1] = IERC20(address(tokenA));

    r.swapExactETHForTokens{value: 7 ether}(0, poolsPath, path, address(deployer), DEAD_LINE);
    zap = new ZapInV2(IKSFactory(address(f)), address(weth));
  }

  function getDigest(address pool, address owner, address spender, uint256 liquidity) public view returns(bytes32 digest ){
    bytes32 domainSeparator = ERC20Permit(pool).domainSeparator();
    bytes32 permitHash = ERC20Permit(pool).PERMIT_TYPEHASH();
    uint256 nonce = ERC20Permit(pool).nonces(owner);
    bytes32 messageSign = keccak256(
        abi.encode(permitHash, owner, spender, liquidity, nonce, DEAD_LINE)
      );
    digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, messageSign));
  }
}

contract TestZap is ZapInBase {
  function setUp() public virtual override {
    ZapInBase.setUp();
  }

  function testZapIn() public {
    t.changePrank(user1);
    tokenA.approve(address(zap), MAX_UINT256);
    t.changePrank(deployer);

    uint256 userInAmount = 5 ether;
    tokenA.transfer(address(user1), userInAmount);

    (uint256 amountSwap, uint256 amountOutput) = zap.calculateSwapAmounts(
      IERC20(address(tokenA)),
      IERC20(address(weth)),
      poolAddress,
      userInAmount
    );
    t.changePrank(user1);
    uint256 result = zap.zapIn(
      IERC20(address(tokenA)),
      IERC20(address(weth)),
      userInAmount,
      poolAddress,
      address(user1),
      1,
      DEAD_LINE
    );
  }

  function testZapInETH() public {
    uint256 userInAmount = 3 ether;
    vm.stopPrank();
    startHoax(user1, MAX_UINT256);
    uint256 result = zap.zapInEth{value: userInAmount}(
      IERC20(address(tokenA)),
      poolAddress,
      address(user1),
      1,
      DEAD_LINE
    );

    assertGt(IERC20(poolAddress).balanceOf(address(user1)), 0);
  }

  function testZapOut() public {
    uint256 userInAmount = 3 ether;
    vm.stopPrank();
    startHoax(user1, MAX_UINT256);
    zap.zapInEth{value: userInAmount}(
      IERC20(address(tokenA)),
      poolAddress,
      address(user1),
      1,
      DEAD_LINE
    );

    IERC20(poolAddress).approve(address(zap), MAX_UINT256);

    uint256 liq = IERC20(poolAddress).balanceOf(address(user1));

    uint256 zapOutAmount = zap.calculateZapOutAmount(
      IERC20(address(tokenA)),
      IERC20(address(weth)),
      poolAddress,
      liq
    );

    uint256 beforeBalance = user1.balance;
    zap.zapOutEth(IERC20(address(tokenA)), liq, poolAddress, address(user1), 1, DEAD_LINE);
    uint256 afterBalance = user1.balance;

    assertEq(afterBalance - beforeBalance, zapOutAmount);
  }

  function testZapOutPermit() public {
    uint256 userInAmount = 3 ether;
    vm.stopPrank();

    // liquidity provider
    startHoax(user2, MAX_UINT256);
    zap.zapInEth{value: userInAmount}(
      IERC20(address(tokenA)),
      poolAddress,
      address(user2),
      1,
      DEAD_LINE
    );

    uint256 liq = IERC20(poolAddress).balanceOf(address(user2));
    bytes32 digest = getDigest(poolAddress, address(user2), address(zap), liq);

    (uint8 v, bytes32 rsign, bytes32 s) = vm.sign(privUser2, digest);

    zap.zapOutPermit(
      IERC20(address(tokenA)),
      IERC20(address(weth)),
      liq,
      poolAddress,
      address(user1),
      1,
      DEAD_LINE,
      false,
      v,
      rsign,
      s
    );
  }
  function testZapOutETHPermit() public {
    uint256 userInAmount = 3 ether;
    vm.stopPrank();

    // liquidity provider
    startHoax(user2, MAX_UINT256);
    zap.zapInEth{value: userInAmount}(
      IERC20(address(tokenA)),
      poolAddress,
      address(user2),
      1,
      DEAD_LINE
    );

    uint256 liq = IERC20(poolAddress).balanceOf(address(user2));
    bytes32 digest = getDigest(poolAddress, address(user2), address(zap), liq);

    (uint8 v, bytes32 rsign, bytes32 s) = vm.sign(privUser2, digest);

    zap.zapOutEthPermit(
      IERC20(address(tokenA)),
      liq,
      poolAddress,
      address(user1),
      1,
      DEAD_LINE,
      false,
      v,
      rsign,
      s
    );
  }
}
