// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../storage/DiamondStorage.sol";

contract OwnershipFacet is ERC721 {
    using DiamondStorage for DiamondStorage.DiamondStorageStruct;

    constructor() ERC721("VehicleNFT", "VNFT") {}

    modifier onlyCurrentOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not the current owner");
        _; // This ensures the function continues executing after the check
    }

    function purchaseVehicleByVIN(string memory VIN) external payable {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        address currentOwner = ownerOf(tokenId);
        uint256 price = ds.vehiclePrices[tokenId];

        require(msg.value == price, "Incorrect payment amount");
        require(msg.sender != currentOwner, "Owner cannot purchase their own vehicle");
        require(ds.certifiedUsers[msg.sender], "Not a certified user");
        require(price > 0, "Vehicle not listed for sale");

        _transfer(currentOwner, msg.sender, tokenId);
        ds.vehicleOwners[tokenId] = msg.sender;
        ds.vehiclePrices[tokenId] = 0;

        payable(currentOwner).transfer(msg.value);

        // Emit VehiclePurchased event (add event emission logic if needed)
    }

    function reportStolen(string memory VIN) external {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        // Use the modifier to ensure only the current owner can report
        reportStolenInternal(tokenId, ds);
    }

    function reportLoanFree(string memory VIN) external {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        // Use the modifier to ensure only the current owner can report
        reportLoanFreeInternal(tokenId, ds);
    }

    function reportStolenInternal(uint256 tokenId, DiamondStorage.DiamondStorageStruct storage ds) internal {
        require(ownerOf(tokenId) == msg.sender, "Not the current owner");
        ds.vehicles[tokenId].isStolen = true;
        // Emit VehicleReportedStolen event
    }

    function reportLoanFreeInternal(uint256 tokenId, DiamondStorage.DiamondStorageStruct storage ds) internal {
        require(ownerOf(tokenId) == msg.sender, "Not the current owner");
        require(!ds.vehicles[tokenId].isLoanFree, "Loan already reported free");
        ds.vehicles[tokenId].isLoanFree = true;
        // Emit LoanClearanceReported event
    }

    // Override ERC721 functions
    function ownerOf(uint256 tokenId) public view override returns (address) {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        return ds.vehicleOwners[tokenId];
    }
}
