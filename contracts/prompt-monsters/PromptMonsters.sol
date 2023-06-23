// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {Base64Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IPromptMonsters, IPromptMonstersImage, IPromptMonstersExtension} from "./IPromptMonsters.sol";

/// @title PromptMonsters
/// @author keit (@keitEngineer)
/// @dev This is a contract of PromptMonsters.
contract PromptMonsters is
  Initializable,
  IPromptMonsters,
  ERC721Upgradeable,
  AccessControlEnumerableUpgradeable,
  UUPSUpgradeable,
  ReentrancyGuardUpgradeable
{
  // --------------------------------------------------------------------------------
  // State
  // --------------------------------------------------------------------------------
  using SafeERC20 for IERC20;
  /// @custom:oz-renamed-from erc20
  IERC20 private _erc20;

  /// @custom:oz-renamed-from promptMonstersWallet
  address private _promptMonstersWallet;

  /// @custom:oz-renamed-from mintPrice
  uint256 private _mintPrice;

  /// @custom:oz-renamed-from _externalLink
  string private _externalLink;

  /// @custom:oz-renamed-from _ownerToTokenIdsIndex
  mapping(address => mapping(uint256 => uint256))
    private _ownerToTokenIdsIndexMap;

  /// @custom:oz-renamed-from _monsterHistory
  mapping(address => IPromptMonsters.Monster) private _monsterHistoryMap;

  /// @custom:oz-renamed-from _ownerToTokenIds
  mapping(address => uint256[]) private _ownerToTokenIdsMap;

  /// @custom:oz-renamed-from _monsters
  IPromptMonsters.Monster[] private _monsters;

  /// @custom:oz-renamed-from resurrectionIndex
  mapping(address => uint256) private _resurrectionPromptToTokenIdMap;

  /// @custom:oz-renamed-from promptMonstersImage
  IPromptMonstersImage private _promptMonstersImage;

  /// @custom:oz-renamed-from _paused
  bool private _paused;

  /// @custom:oz-renamed-from _mintedMap
  mapping(address => bool) private _mintedMap;

  /// @custom:oz-renamed-from _tokenIdToResurrectionPromptMap
  mapping(uint256 => address) private _tokenIdToResurrectionPromptMap;

  /// @custom:oz-renamed-from _promptMonstersExtension
  IPromptMonstersExtension private _promptMonstersExtension;

  /// @custom:oz-renamed-from GAME_ROLE
  bytes32 private GAME_ROLE;

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Constructor
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

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
  ) public initializer {
    __ERC721_init("Prompt Monsters", "MON");
    __AccessControlEnumerable_init();
    __UUPSUpgradeable_init();
    __ReentrancyGuard_init();

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _externalLink = externalLink_;
    _erc20 = IERC20(erc20Address_);
    _mintPrice = mintPrice_;
    _promptMonstersWallet = promptMonstersWallet_;
  }

  /// @dev Supports interface
  /// @param interfaceId interface ID
  function supportsInterface(
    bytes4 interfaceId
  )
    public
    view
    override(
      IERC165Upgradeable,
      ERC721Upgradeable,
      AccessControlEnumerableUpgradeable
    )
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  // --------------------------------------------------------------------------------
  // Modifier
  // --------------------------------------------------------------------------------

  /// @dev Modifier to make a function callable only when the contract is not paused.
  modifier whenNotPaused() {
    require(!_paused, "Pausable: paused");
    _;
  }

  /// @dev Modifier to make a function callable only when the contract is paused.
  modifier whenPaused() {
    require(_paused, "Pausable: not paused");
    _;
  }

  // --------------------------------------------------------------------------------
  // Getter
  // --------------------------------------------------------------------------------

  /// @dev Get _erc20
  /// @return returnValue ERC20 address
  function getErc20() external view returns (IERC20 returnValue) {
    returnValue = _erc20;
  }

  /// @dev Get _mintPrice
  /// @return returnValue _mintPrice
  function getMintPrice() external view returns (uint256 returnValue) {
    returnValue = _mintPrice;
  }

  /// @dev Get _promptMonstersWallet
  /// @return returnValue _promptMonstersWallet
  function getPromptMonstersWallet()
    external
    view
    returns (address returnValue)
  {
    returnValue = _promptMonstersWallet;
  }

  /// @dev Get token IDs from owner address
  /// @param owner owner
  /// @return returnValue token IDs
  function getOwnerToTokenIds(
    address owner
  ) external view returns (uint256[] memory returnValue) {
    returnValue = _ownerToTokenIdsMap[owner];
  }

  /// @dev Get token IDs
  /// @param resurrectionPrompts resurrection prompts
  /// @return returnValue resurrection prompts
  function getTokenIds(
    address[] memory resurrectionPrompts
  ) external view returns (uint256[] memory returnValue) {
    uint256 resurrectionPromptsLength = resurrectionPrompts.length;
    returnValue = new uint256[](resurrectionPromptsLength);
    for (uint i; i < resurrectionPromptsLength; ) {
      returnValue[i] = _resurrectionPromptToTokenIdMap[resurrectionPrompts[i]];
      unchecked {
        ++i;
      }
    }
  }

  /// @dev Get _promptMonstersImage
  /// @return returnValue _promptMonstersImage
  function getPromptMonstersImage()
    external
    view
    returns (IPromptMonstersImage returnValue)
  {
    returnValue = _promptMonstersImage;
  }

  /// @dev Get _paused
  /// @return returnValue _paused
  function getPaused() external view returns (bool returnValue) {
    returnValue = _paused;
  }

  /// @dev Get minteds
  /// @param resurrectionPrompts resurrection prompts
  /// @return returnValue minteds
  function getMinteds(
    address[] memory resurrectionPrompts
  ) external view returns (bool[] memory returnValue) {
    uint256 resurrectionPromptsLength = resurrectionPrompts.length;
    returnValue = new bool[](resurrectionPromptsLength);
    for (uint i; i < resurrectionPromptsLength; ) {
      returnValue[i] = _mintedMap[resurrectionPrompts[i]];
      unchecked {
        ++i;
      }
    }
  }

  /// @dev Get resurrection prompts
  /// @param monsterIds_ monster IDs
  /// @return returnValue resurrection prompts
  function getResurrectionPrompts(
    uint256[] memory monsterIds_
  ) external view returns (address[] memory returnValue) {
    uint256 monsterIdsLength = monsterIds_.length;
    returnValue = new address[](monsterIdsLength);
    for (uint i; i < monsterIdsLength; ) {
      returnValue[i] = _tokenIdToResurrectionPromptMap[monsterIds_[i]];
      unchecked {
        ++i;
      }
    }
  }

  /// @dev Get _promptMonstersExtension
  /// @return returnValue _promptMonstersExtension
  function getPromptMonstersExtension()
    external
    view
    returns (IPromptMonstersExtension returnValue)
  {
    returnValue = _promptMonstersExtension;
  }

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set ERC20 address
  /// @param newState_ new state
  function setErc20(address newState_) external onlyRole(DEFAULT_ADMIN_ROLE) {
    address oldState = address(_erc20);
    _erc20 = IERC20(newState_);
    emit SetErc20(_msgSender(), oldState, newState_);
  }

  /// @dev Set prompt monsters wallet
  /// @param newState_ new state
  function setPromptMonstersWallet(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    address oldState = _promptMonstersWallet;
    _promptMonstersWallet = newState_;
    emit SetPromptMonstersWallet(_msgSender(), oldState, newState_);
  }

  /// @dev Set mint price
  /// @param newState_ new state
  function setMintPrice(
    uint256 newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint256 oldState = _mintPrice;
    _mintPrice = newState_;
    emit SetMintPrice(_msgSender(), oldState, newState_);
  }

  /// @dev Set external link
  /// @param newState_ new state
  function setExternalLink(
    string memory newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    string memory oldState = _externalLink;
    _externalLink = newState_;
    emit SetExternalLink(_msgSender(), oldState, newState_);
  }

  /// @dev Set prompt monsters image
  /// @param newState_ new state
  function setPromptMonstersImage(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    IPromptMonstersImage oldState = _promptMonstersImage;
    _promptMonstersImage = IPromptMonstersImage(newState_);
    emit SetPromptMonstersImage(_msgSender(), oldState, _promptMonstersImage);
  }

  /// @dev Triggers stopped state
  function pause() external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /// @dev Returns to normal state
  function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }

  /// @dev Set prompt monsters extension
  /// @param newState_ new state
  function setPromptMonstersExtension(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    IPromptMonstersExtension oldState = _promptMonstersExtension;
    _promptMonstersExtension = IPromptMonstersExtension(newState_);
    emit SetPromptMonstersExtension(
      _msgSender(),
      oldState,
      _promptMonstersExtension
    );
  }

  // --------------------------------------------------------------------------------
  // Main Logic
  // --------------------------------------------------------------------------------

  /// @dev Get monsters total supply
  /// @return totalSupply token IDs
  function getMonstersTotalSupply()
    external
    view
    returns (uint256 totalSupply)
  {
    totalSupply = _monsters.length;
  }

  /// @dev Generate monster
  /// @param resurrectionPrompt_ resurrection prompt
  /// @param monster_ monster
  function generateMonster(
    address resurrectionPrompt_,
    IPromptMonsters.Monster memory monster_
  ) external onlyRole(GAME_ROLE) nonReentrant {
    _monsterHistoryMap[resurrectionPrompt_] = monster_;
    emit GeneratedMonsterV2(resurrectionPrompt_, monster_);
  }

  /// @dev Mint monster by user
  /// @param resurrectionPrompt resurrection prompt
  function mint(address resurrectionPrompt) external whenNotPaused {
    require(
      !_mintedMap[resurrectionPrompt],
      "PromptMonsters: This monster is already minted"
    );
    uint256 newTokenId = _monsters.length;
    require(
      newTokenId != type(uint256).max,
      "PromptMonsters: token ID is too large"
    );
    IPromptMonsters.Monster memory monster = _monsterHistoryMap[
      resurrectionPrompt
    ];
    require(monster.lv != 0, "PromptMonsters: monster is not generated");

    _monsters.push(monster);
    _resurrectionPromptToTokenIdMap[resurrectionPrompt] = newTokenId;
    _tokenIdToResurrectionPromptMap[newTokenId] = resurrectionPrompt;
    _mintedMap[resurrectionPrompt] = true;
    _erc20.safeTransferFrom(msg.sender, _promptMonstersWallet, _mintPrice);
    _safeMint(msg.sender, newTokenId);

    emit MintedMonsterV2(msg.sender, resurrectionPrompt, newTokenId, monster);
  }

  /// @dev Burn
  /// This function is not a standard burn function.
  /// Your NFT will be transferred to the owner of this contract if you call this function.
  /// @param tokenId_ token ID
  function burn(uint256 tokenId_) external nonReentrant whenNotPaused {
    safeTransferFrom(
      _msgSender(),
      getRoleMember(DEFAULT_ADMIN_ROLE, 0),
      tokenId_
    );
  }

  /// @dev Check monster ID
  /// @param monsterId monster ID
  function checkMonsterId(uint256 monsterId) external view {
    require(
      _exists(monsterId) || monsterId == type(uint256).max,
      "PromptMonsters: monster does not exist"
    );
  }

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
    )
  {
    uint256 length = resurrectionPrompts_.length;
    monsterExtensions = new IPromptMonstersExtension.MonsterExtension[](length);
    for (uint i; i < length; ) {
      address rp = resurrectionPrompts_[i];
      monsterExtensions[i] = _promptMonstersExtension.getMonsterExtension(
        rp,
        _monsterHistoryMap[rp]
      );
      unchecked {
        ++i;
      }
    }
  }

  /// @dev Get contract URI
  /// @return uri contract URI
  function contractURI() external view returns (string memory uri) {
    uri = _promptMonstersImage.contractURI(name(), _externalLink);
  }

  /// @dev Get token URI
  /// @param tokenId_ token ID
  /// @return uri token URI
  function tokenURI(
    uint256 tokenId_
  ) public view override returns (string memory uri) {
    _requireMinted(tokenId_);
    uri = _promptMonstersImage.tokenURI(tokenId_, _monsters[tokenId_]);
  }

  // --------------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------------

  /// @dev Add owner to token IDs
  /// @param to_ recipient
  /// @param tokenId_ token ID
  function _addOwnerToTokenIds(address to_, uint256 tokenId_) private {
    _ownerToTokenIdsIndexMap[to_][tokenId_] = _ownerToTokenIdsMap[to_].length;
    _ownerToTokenIdsMap[to_].push(tokenId_);
  }

  /// @dev Remove owner to token IDs
  /// @param from_ sender
  /// @param tokenId_ token ID
  function _removeOwnerToTokenIds(address from_, uint256 tokenId_) private {
    uint256 lastTokenId = _ownerToTokenIdsMap[from_][
      _ownerToTokenIdsMap[from_].length - 1
    ];
    uint256 tokenIdIndex = _ownerToTokenIdsIndexMap[from_][tokenId_];
    if (tokenId_ != lastTokenId)
      _ownerToTokenIdsMap[from_][tokenIdIndex] = lastTokenId;
    _ownerToTokenIdsMap[from_].pop();
    delete _ownerToTokenIdsIndexMap[from_][tokenId_];
    if (tokenId_ != lastTokenId)
      _ownerToTokenIdsIndexMap[from_][lastTokenId] = tokenIdIndex;
  }

  /// @dev Before token transfer
  /// @param from sender
  /// @param to recipient
  /// @param tokenId token ID
  /// @param batchSize batch size
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override {
    if (from == address(0)) {
      _addOwnerToTokenIds(to, tokenId);
    } else if (to == address(0)) {
      _removeOwnerToTokenIds(from, tokenId);
    } else {
      _removeOwnerToTokenIds(from, tokenId);
      _addOwnerToTokenIds(to, tokenId);
    }

    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  /// @dev Authorize upgrade
  /// @param newImplementation new implementation address
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
