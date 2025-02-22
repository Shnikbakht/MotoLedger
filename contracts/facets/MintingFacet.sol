// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // Import the URI storage extension
import "../storage/DiamondStorage.sol";

contract MintingFacet is ERC721, ERC721URIStorage {  // Inherit from ERC721 and ERC721URIStorage
    using DiamondStorage for DiamondStorage.DiamondStorageStruct;

    constructor() ERC721("VehicleNFT", "VNFT") {}

    modifier onlyAuthorizedManufacturer() {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(ds.authorizedManufacturers[msg.sender], "Not an authorized manufacturer");
        _;
    }

    function mintVehicles(
        string[] memory VINs,
        string[] memory metadataURIs,
        bytes[] memory signatures
    ) external onlyAuthorizedManufacturer returns (uint256[] memory) {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(VINs.length == metadataURIs.length && VINs.length == signatures.length, "Mismatched array lengths");

        uint256[] memory newItemIds = new uint256[](VINs.length);

        for (uint256 i = 0; i < VINs.length; i++) {
            require(ds.vinToTokenId[VINs[i]] == 0, "VIN already exists");
            ds.currentTokenId++;
            uint256 newItemId = ds.currentTokenId;

            ds.vehicles[newItemId] = DiamondStorage.Vehicle({
                tokenId: newItemId,
                VIN: VINs[i],
                metadataURI: metadataURIs[i],
                insuranceRecordURI: "",
                serviceRecordURI: "",
                isStolen: false,
                isLoanFree: true
            });

            ds.vinToTokenId[VINs[i]] = newItemId;
            ds.tokenIdToVin[newItemId] = VINs[i];

            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, metadataURIs[i]);

            newItemIds[i] = newItemId;
            // Emit event here if needed
        }
        return newItemIds;
    }

    // Override the ERC721URIStorage function to set token URI
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal override(ERC721URIStorage) {
        super._setTokenURI(tokenId, _tokenURI);  // Calls the parent function in ERC721URIStorage
    }

    // Override supportsInterface from both ERC721 and ERC721URIStorage
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId); // Calls the function from both ERC721 and ERC721URIStorage
    }

    // Override tokenURI from ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);  // Calls the function from ERC721URIStorage
    }
}
