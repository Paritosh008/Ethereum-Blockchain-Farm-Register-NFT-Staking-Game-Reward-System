//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../Marketplace.sol";

// * discounts require proxy forwarding, but a problem with that is that
// * the contract checks the balances of the caller (i.e. proxy) instead
// * of the initializer. First version, plain same fee for everyone.

abstract contract MarketplaceFeeCollector is Marketplace {
    using Address for address payable;
    // 0.5% in basis points
    // uint256 public fee = 1;
    // uint256 public constant HUNDRED_PERCENT = 10**5;
    // event TakeFeeValues(uint256 serviceFee, uint256 sellerAmount, uint256 feePercentage);
    // event FirstLog(uint256 fee, uint256 HUNDRED_PERCENT);
    // event CutValue(uint256 cut);

    /// @dev Hook that is called before any token transfer.
    function _takeFee(uint256 totalPrice)
        internal virtual override
        returns (uint256)
    {
        // emit FirstLog(fee, HUNDRED_PERCENT);
        uint256 cut = (totalPrice  * fee) / HUNDRED_PERCENT;
        // emit CutValue(cut);
        require(cut < totalPrice, "");
        uint256 left = totalPrice - cut;
        // emit TakeFeeValues(cut,left,fee);
        beneficiary.sendValue(cut);
        allowedToken.transfer(beneficiary, cut*10**9);
        return left;
    }

    function changeFee(uint256 newFee) external override{
        require(msg.sender == admin, "");
        require(newFee < HUNDRED_PERCENT, "");
        fee = newFee*10**3;
    }
}
