// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IPromptMonsters} from "../prompt-monsters/IPromptMonsters.sol";

/// @title IPromptMonstersImage
/// @author keit (@keitEngineer)
/// @dev This is an interface of PromptMonstersImage.
interface IPromptMonstersImage {
  // --------------------------------------------------------------------------------
  // Event
  // --------------------------------------------------------------------------------

  event SetImageURL(
    address indexed publisher,
    string oldValue,
    string newValue
  );

  event SetPromptMonsters(
    address indexed publisher,
    address oldValue,
    address newValue
  );

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Initialize
  /// @param promptMonstersAddress_ prompt monsters address
  function initialize(address promptMonstersAddress_) external;

  // --------------------------------------------------------------------------------
  // Getter
  // --------------------------------------------------------------------------------

  /// @dev Get token URI
  /// @param tokenId_ token ID
  /// @param monster_ monster
  /// @return uri token URI
  function tokenURI(
    uint256 tokenId_,
    IPromptMonsters.Monster memory monster_
  ) external view returns (string memory uri);

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set image URL
  /// @param tokenId_ token ID
  /// @param newState_ new state
  function setImageURL(uint256 tokenId_, string memory newState_) external;

  /// @dev Set image URL
  /// @param tokenIds_ token ID
  /// @param newStates_ new state
  function setBatchImageURL(
    uint256[] memory tokenIds_,
    string[] memory newStates_
  ) external;

  /// @dev Set Prompt Monsters
  /// @param newState_ new state
  function setPromptMonsters(address newState_) external;
}
