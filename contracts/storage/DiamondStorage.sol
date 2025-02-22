// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IDiamondCut.sol";
library DiamondStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.storage");

    struct Vehicle {
        uint256 tokenId;
        string VIN;
        string metadataURI;
        string insuranceRecordURI;
        string serviceRecordURI;
        bool isStolen;
        bool isLoanFree;
    }

    struct InsuranceRecord {
        string metadataURI;
        bool isConfirmed;
        address provider;
    }

    struct ServiceRecord {
        string metadataURI;
        bool isConfirmed;
        address provider;
    }

    struct DiamondStorageStruct {
        mapping(bytes4 => address) selectorToFacet; // Maps function selectors to facet addresses
        address contractOwner; // Owner of the diamond
        mapping(uint256 => Vehicle) vehicles; // Vehicle data by tokenId
        mapping(string => uint256) vinToTokenId; // VIN to tokenId mapping
        mapping(uint256 => string) tokenIdToVin; // tokenId to VIN mapping
        mapping(address => bool) authorizedManufacturers; // Authorized manufacturers
        mapping(address => bool) authorizedInsuranceProviders; // Authorized insurance providers
        mapping(address => bool) authorizedCarServiceProviders; // Authorized service providers
        mapping(address => bool) certifiedUsers; // Certified users
        mapping(uint256 => address) vehicleOwners; // Owners of vehicles by tokenId
        mapping(uint256 => uint256) vehiclePrices; // Prices for vehicles listed for sale
        mapping(string => InsuranceRecord) insuranceRecords; // Insurance records by VIN
        mapping(string => ServiceRecord) serviceRecords; // Service records by VIN
        mapping(uint256 => string) tokenURIs;        
        uint256 currentTokenId; // Tracks the current token ID
    }

    function diamondStorage() internal pure returns (DiamondStorageStruct storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setContractOwner(address _owner) internal {
        DiamondStorageStruct storage ds = diamondStorage();
        ds.contractOwner = _owner;
    }

    function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal {
        DiamondStorageStruct storage ds = diamondStorage();
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            IDiamondCut.FacetCutAction action = _diamondCut[i].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                for (uint256 j = 0; j < _diamondCut[i].functionSelectors.length; j++) {
                    ds.selectorToFacet[_diamondCut[i].functionSelectors[j]] = _diamondCut[i].facetAddress;
                }
            }
        }
        if (_init != address(0)) {
            (bool success, ) = _init.delegatecall(_calldata);
            require(success, "Initialization failed");
        }
    }
}