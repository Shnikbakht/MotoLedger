// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import "../storage/DiamondStorage.sol";

contract InsuranceFacet {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using DiamondStorage for DiamondStorage.DiamondStorageStruct;

    modifier onlyAuthorizedInsuranceProvider() {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(ds.authorizedInsuranceProviders[msg.sender], "Not an authorized insurance provider");
        _;
    }

    function updateInsuranceRecords(
        string[] memory VINs,
        string[] memory insuranceRecordsURIs,
        bytes[] memory signatures
    ) external onlyAuthorizedInsuranceProvider {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(VINs.length == insuranceRecordsURIs.length && VINs.length == signatures.length, "Mismatched array lengths");

        for (uint256 i = 0; i < VINs.length; i++) {
            uint256 tokenId = ds.vinToTokenId[VINs[i]];
            require(tokenId != 0, "Vehicle does not exist");

            bytes32 messageHash = keccak256(abi.encodePacked(insuranceRecordsURIs[i], VINs[i]));
            bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
            address signer = ECDSA.recover(ethSignedMessageHash, signatures[i]);
            require(ds.authorizedInsuranceProviders[signer], "Invalid signature");

            ds.insuranceRecords[VINs[i]] = DiamondStorage.InsuranceRecord({
                metadataURI: insuranceRecordsURIs[i],
                isConfirmed: false,
                provider: msg.sender
            });

            // Emit InsuranceUpdateSubmitted event
        }
    }

    function confirmInsuranceUpdate(string calldata VIN) external {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        uint256 tokenId = ds.vinToTokenId[VIN];
        require(ds.vehicleOwners[tokenId] == msg.sender, "Not the vehicle owner");
        require(!ds.insuranceRecords[VIN].isConfirmed, "Already confirmed");
        require(ds.insuranceRecords[VIN].provider != address(0), "No pending update");

        ds.insuranceRecords[VIN].isConfirmed = true;
        ds.vehicles[tokenId].insuranceRecordURI = ds.insuranceRecords[VIN].metadataURI;

        // Emit InsuranceUpdateConfirmed event
    }
}