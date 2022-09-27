// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "forge-std/Script.sol";
import "../src/mock/BasicToken.sol";

contract DZapIn is Script {
    function run() external {
      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
      vm.startBroadcast(deployerPrivateKey);

      BasicToken sc = new BasicToken("Zohar Token", "ZOHAR", 1000 ether);

      vm.stopBroadcast();
    }
}