// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../src/KSFactory.sol";
import "../src/mock/WETH9.sol";
import "../src/ZapInV2.sol";
import "forge-std/console.sol";

contract DZapIn is Script {
    function run() external {
      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
      address deployerAddr = vm.addr(deployerPrivateKey);
      console.log("Deployer : ", deployerAddr);
      vm.startBroadcast(deployerPrivateKey);

      KSFactory factory = new KSFactory(deployerAddr);
      WETH9 weth = new WETH9();
      ZapInV2 zapSc = new ZapInV2(factory, address(weth));

      vm.stopBroadcast();
    }
}