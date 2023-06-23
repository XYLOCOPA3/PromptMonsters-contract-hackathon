// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IPromptMonstersExtension} from "../prompt-monsters-extension/IPromptMonstersExtension.sol";
import {IPromptMonstersImage} from "../prompt-monsters-image/IPromptMonstersImage.sol";

/// @title IPromptMonsters
/// @author keit (@keitEngineer)
/// @dev This is an interface of PromptMonsters.
interface IPromptMonsters is IERC721Upgradeable {
  // --------------------------------------------------------------------------------
  // Struct
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

  event SetErc20(address indexed publisher, address oldValue, address newValue);

  event SetPromptMonstersWallet(
    address indexed publisher,
    address oldValue,
    address newValue
  );

  event SetMintPrice(
    address indexed publisher,
    uint256 oldValue,
    uint256 newValue
  );

  event SetExternalLink(
    address indexed publisher,
    string oldValue,
    string newValue
  );

  event SetPromptMonstersImage(
    address indexed publisher,
    IPromptMonstersImage oldValue,
    IPromptMonstersImage newValue
  );

  event Paused(address account);

  event Unpaused(address account);

  event SetPromptMonstersExtension(
    address indexed publisher,
    IPromptMonstersExtension oldValue,
    IPromptMonstersExtension newValue
  );

  event GeneratedMonsterV2(address indexed resurrectionPrompt, Monster monster);

  event MintedMonsterV2(
    address indexed tokenOwner,
    address indexed resurrectionPrompt,
    uint256 indexed newTokenId,
    Monster monster
  );

  // 既に使用していないイベントだが、残しておかないとTxから取得できなくなる
  event SetMonsterHistory(
    address indexed publisher,
    Monster oldValue,
    Monster newValue
  );

  // 既に使用していないイベントだが、残しておかないとTxから取得できなくなる
  event SetTokenIdToResurrectionPromptMap(
    address indexed publisher,
    address oldValue,
    address newValue
  );

  // 既に使用していないイベントだが、残しておかないとTxから取得できなくなる
  event SetResurrectionPromptToTokenIdMap(
    address indexed publisher,
    uint256 oldValue,
    uint256 newValue
  );

  // 既に使用していないイベントだが、残しておかないとTxから取得できなくなる
  event GenerateMonster(Monster monster);

  // 既に使用していないイベントだが、残しておかないとTxから取得できなくなる
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

  /// @dev Get _erc20
  /// @return returnValue ERC20 address
  function getErc20() external view returns (IERC20 returnValue);

  /// @dev Get _mintPrice
  /// @return returnValue _mintPrice
  function getMintPrice() external view returns (uint256 returnValue);

  /// @dev Get _promptMonstersWallet
  /// @return returnValue _promptMonstersWallet
  function getPromptMonstersWallet()
    external
    view
    returns (address returnValue);

  /// @dev Get token IDs from owner address
  /// @param owner owner
  /// @return returnValue token IDs
  function getOwnerToTokenIds(
    address owner
  ) external view returns (uint256[] memory returnValue);

  /// @dev Get token IDs
  /// @param resurrectionPrompts resurrection prompts
  /// @return returnValue resurrection prompts
  function getTokenIds(
    address[] memory resurrectionPrompts
  ) external view returns (uint256[] memory returnValue);

  /// @dev Get _promptMonstersImage
  /// @return returnValue _promptMonstersImage
  function getPromptMonstersImage()
    external
    view
    returns (IPromptMonstersImage returnValue);

  /// @dev Get _paused
  /// @return returnValue _paused
  function getPaused() external view returns (bool returnValue);

  /// @dev Get minteds
  /// @param resurrectionPrompts resurrection prompts
  /// @return returnValue minteds
  function getMinteds(
    address[] memory resurrectionPrompts
  ) external view returns (bool[] memory returnValue);

  /// @dev Get resurrection prompts
  /// @param monsterIds_ monster IDs
  /// @return returnValue resurrection prompts
  function getResurrectionPrompts(
    uint256[] memory monsterIds_
  ) external view returns (address[] memory returnValue);

  /// @dev Get _promptMonstersExtension
  /// @return returnValue _promptMonstersExtension
  function getPromptMonstersExtension()
    external
    view
    returns (IPromptMonstersExtension returnValue);

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set ERC20 address
  /// @param newState_ new state
  function setErc20(address newState_) external;

  /// @dev Set prompt monsters wallet
  /// @param newState_ new state
  function setPromptMonstersWallet(address newState_) external;

  /// @dev Set mint price
  /// @param newState_ new state
  function setMintPrice(uint256 newState_) external;

  /// @dev Set external link
  /// @param newState_ new state
  function setExternalLink(string memory newState_) external;

  /// @dev Set prompt monsters image
  /// @param newState_ new state
  function setPromptMonstersImage(address newState_) external;

  /// @dev Triggers stopped state
  function pause() external;

  /// @dev Returns to normal state
  function unpause() external;

  /// @dev Set prompt monsters extension
  /// @param newState_ new state
  function setPromptMonstersExtension(address newState_) external;

  // --------------------------------------------------------------------------------
  // Main Logic
  // --------------------------------------------------------------------------------

  /// @dev Get monsters total supply
  /// @return totalSupply token IDs
  function getMonstersTotalSupply() external view returns (uint256 totalSupply);

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

  /// @dev Get monster extensions
  /// @param resurrectionPrompts_ resurrection prompts
  /// @return monsterExtensions monster extensions
  function getMonsterExtensions(
    address[] memory resurrectionPrompts_
  )
    external
    view
    returns (
      IPromptMonstersExtension.MonsterExtension[] memory monsterExtensions
    );

  /// @dev Get contract URI
  /// @return uri contract URI
  function contractURI() external view returns (string memory uri);
}
