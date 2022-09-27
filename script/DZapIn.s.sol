// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../src/mock/TestToken.sol";

contract DZapIn is Script {
    function run() external {
      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
      vm.startBroadcast(deployerPrivateKey);

      TestToken sc = new TestToken("Basic Token", "BS", 100 ether);

      vm.stopBroadcast();
    }
}