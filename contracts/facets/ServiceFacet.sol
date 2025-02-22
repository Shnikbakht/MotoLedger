// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import "../storage/DiamondStorage.sol";

contract ServiceFacet {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using DiamondStorage for DiamondStorage.DiamondStorageStruct;

    modifier onlyAuthorizedCarServiceProvider() {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(ds.authorizedCarServiceProviders[msg.sender], "Not an authorized service provider");
        _;
    }

    function updateCarServiceRecords(
        string memory VIN,
        string memory serviceRecordsURI,
        bytes memory signature
    ) external onlyAuthorizedCarServiceProvider {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        require(tokenId != 0, "Vehicle does not exist");

        bytes32 messageHash = keccak256(abi.encodePacked(serviceRecordsURI, VIN));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        address signer = ECDSA.recover(ethSignedMessageHash, signature);
        require(ds.authorizedCarServiceProviders[signer], "Invalid signature");

        ds.serviceRecords[VIN] = DiamondStorage.ServiceRecord({
            metadataURI: serviceRecordsURI,
            isConfirmed: false,
            provider: msg.sender
        });

        // Emit ServiceUpdateSubmitted event
    }

    function confirmServiceUpdate(string calldata VIN) external {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        require(ds.vehicleOwners[tokenId] == msg.sender, "Not the vehicle owner");
        require(!ds.serviceRecords[VIN].isConfirmed, "Already confirmed");
        require(ds.serviceRecords[VIN].provider != address(0), "No pending update");

        ds.serviceRecords[VIN].isConfirmed = true;
        ds.vehicles[tokenId].serviceRecordURI = ds.serviceRecords[VIN].metadataURI;

        // Emit ServiceUpdateConfirmed event
    }
}