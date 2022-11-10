pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    
    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;
    event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:

    function buyTokens() public payable {
        require(msg.value > 0, "The value must be more than 0");
        uint256 amtToTransfer = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, amtToTransfer);
        emit BuyTokens(msg.sender, msg.value, amtToTransfer);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has no balance to withdraw");
        (bool sent, ) = msg.sender.call{value: ownerBalance}("");
        require(sent, "Failed to send balance");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 tokensToSell) public {
        require(
            tokensToSell > 0,
            "Amounts of tokens to sell must be greater than 0"
        );

        uint256 userBalance = yourToken.balanceOf(msg.sender);
        require(
            userBalance >= tokensToSell,
            "User has insufficient tokens to sell"
        );

        uint256 ethAmtToTransfer = tokensToSell / tokensPerEth;
        uint256 ownerBalance = address(this).balance;

        require(
            ownerBalance >= ethAmtToTransfer,
            "Owner has insuffient balance to transfer"
        );
        yourToken.transferFrom(msg.sender, address(this), tokensToSell);
        (bool sent, ) = msg.sender.call{value: ethAmtToTransfer}("");
        require(sent, "Failed to send ETH to user");
    }
}
