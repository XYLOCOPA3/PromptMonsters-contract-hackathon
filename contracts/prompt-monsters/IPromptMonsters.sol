// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/// @title IPromptMonsters
/// @author keit (@keitEngineer)
/// @dev This is an interface of PromptMonsters.
interface IPromptMonsters is IERC721Upgradeable {
  // --------------------------------------------------------------------------------
  // State
  // --------------------------------------------------------------------------------

  struct Monster {
    string feature;
    string name;
    string flavor;
    string[] skills;
    uint32 lv;
    uint32 hp;
    uint32 atk;
    uint32 def;
    uint32 inte; // INT
    uint32 mgr;
    uint32 agl;
  }

  // --------------------------------------------------------------------------------
  // Event
  // --------------------------------------------------------------------------------

  event SetExternalLink(
    address indexed publisher,
    string oldValue,
    string newValue
  );

  event SetErc20(address indexed publisher, address oldValue, address newValue);

  event SetMintPrice(
    address indexed publisher,
    uint256 oldValue,
    uint256 newValue
  );

  event SetPromptMonstersWallet(
    address indexed publisher,
    address oldValue,
    address newValue
  );

  event SetOwnerToTokenId(
    address indexed publisher,
    uint256 oldValue,
    uint256 newValue
  );

  event SetOwnerToTokenIdIndex(
    address indexed publisher,
    uint256 oldValue,
    uint256 newValue
  );

  event GenerateMonster(Monster monster);

  event MintedMonster(
    address indexed tokenOwner,
    uint256 indexed newTokenId,
    Monster monster
  );

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Initialize
  /// @param externalLink_ external link
  /// @param erc20Address_ ERC20 address
  /// @param mintPrice_ mint price
  /// @param promptMonstersWallet_ prompt monsters wallet
  function initialize(
    string memory externalLink_,
    address erc20Address_,
    uint256 mintPrice_,
    address promptMonstersWallet_
  ) external;

  // --------------------------------------------------------------------------------
  // Getter
  // --------------------------------------------------------------------------------

  /// @dev Get monsters total supply
  /// @return totalSupply token IDs
  function getMonstersTotalSupply() external view returns (uint256 totalSupply);

  /// @dev Get monsters history
  /// @param resurrectionPrompt resurrection prompt
  /// @return monsterHistory monster history
  function getMonsterHistory(
    address resurrectionPrompt
  ) external view returns (Monster memory monsterHistory);

  /// @dev Get token IDs from owner address
  /// @param owner owner
  /// @return tokenIds token IDs
  function getOwnerToTokenIds(
    address owner
  ) external view returns (uint256[] memory tokenIds);

  /// @dev Get token IDs from owner address index
  /// @param owner owner
  /// @param tokenId_ token ID
  /// @return tokenIdsIndex token IDs
  function getOwnerToTokenIdsIndex(
    address owner,
    uint256 tokenId_
  ) external view returns (uint256 tokenIdsIndex);

  /// @dev Get monsters
  /// @param tokenIds_ token IDs
  /// @return monsters monsters
  function getMonsters(
    uint256[] memory tokenIds_
  ) external view returns (Monster[] memory monsters);

  /// @dev Get contract URI
  /// @return uri contract URI
  function contractURI() external view returns (string memory uri);

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set external link
  /// @param newState_ new state
  function setExternalLink(string memory newState_) external;

  /// @dev Set owner to token ID
  /// @param user_ user
  /// @param ownerToTokenIdIndex_ owner to token ID index
  /// @param newState_ new state
  function setOwnerToTokenId(
    address user_,
    uint256 ownerToTokenIdIndex_,
    uint256 newState_
  ) external;

  /// @dev Set owner to token ID index
  /// @param user_ user
  /// @param tokenId_ token ID
  /// @param newState_ new state
  function setOwnerToTokenIdIndex(
    address user_,
    uint256 tokenId_,
    uint256 newState_
  ) external;

  /// @dev Set prompt monsters image
  /// @param newState_ new state
  function setPromptMonstersImage(address newState_) external;

  // --------------------------------------------------------------------------------
  // Main Logic
  // --------------------------------------------------------------------------------

  /// @dev Generate monster
  /// @param resurrectionPrompt_ resurrection prompt
  /// @param monster_ monster
  function generateMonster(
    address resurrectionPrompt_,
    Monster memory monster_
  ) external;

  /// @dev Mint monster by admin
  /// @param resurrectionPrompt resurrection prompt
  function mint(address resurrectionPrompt) external;

  /// @dev Burn
  /// @param tokenId_ token ID
  function burn(uint256 tokenId_) external;

  /// @dev Check monster ID
  /// @param monsterId monster ID
  function checkMonsterId(uint256 monsterId) external view;
}
