// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./IDiamondCut.sol";
import "../storage/DiamondStorage.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        DiamondStorage.DiamondStorageStruct storage ds = DiamondStorage.diamondStorage();
        require(msg.sender == ds.contractOwner, "Only owner can cut diamond");

        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCutAction action = _diamondCut[i].action;
            bytes4[] memory selectors = _diamondCut[i].functionSelectors;
            address facetAddress = _diamondCut[i].facetAddress;

            if (action == FacetCutAction.Add) {
                require(facetAddress != address(0), "Invalid facet address");
                for (uint256 j = 0; j < selectors.length; j++) {
                    require(ds.selectorToFacet[selectors[j]] == address(0), "Selector already exists");
                    ds.selectorToFacet[selectors[j]] = facetAddress;
                }
            } else if (action == FacetCutAction.Replace) {
                require(facetAddress != address(0), "Invalid facet address");
                for (uint256 j = 0; j < selectors.length; j++) {
                    require(ds.selectorToFacet[selectors[j]] != address(0), "Selector does not exist");
                    ds.selectorToFacet[selectors[j]] = facetAddress;
                }
            } else if (action == FacetCutAction.Remove) {
                for (uint256 j = 0; j < selectors.length; j++) {
                    require(ds.selectorToFacet[selectors[j]] != address(0), "Selector does not exist");
                    delete ds.selectorToFacet[selectors[j]];
                }
            }
        }

        if (_init != address(0)) {
            (bool success, ) = _init.delegatecall(_calldata);
            require(success, "Init call failed");
        }
    }
}