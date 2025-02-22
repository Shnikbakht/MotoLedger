// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IDiamondCut.sol";
import "./storage/DiamondStorage.sol";

contract VehicleDiamond {
    constructor(address _owner, address _diamondCutFacet) {
        DiamondStorage.setContractOwner(_owner);

        // Initial facet cut (add DiamondCutFacet)
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondCutFacet")
        });
        DiamondStorage.diamondCut(cut, address(0), "");
    }

    // Fallback delegates calls to facets
    fallback() external payable {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        address facet = ds.selectorToFacet[msg.sig];
        require(facet != address(0), "Function does not exist");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), facet, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {}
    
    // Helper to generate function selectors (simplified for example)
    function generateSelectors(string memory _facetName) internal pure returns (bytes4[] memory) {
        // In practice, list specific selectors here
        bytes4[] memory selectors = new bytes4[](1); // Example
        if (keccak256(abi.encodePacked(_facetName)) == keccak256(abi.encodePacked("DiamondCutFacet"))) {
            selectors[0] = IDiamondCut.diamondCut.selector;
        }
        return selectors;
    }
}