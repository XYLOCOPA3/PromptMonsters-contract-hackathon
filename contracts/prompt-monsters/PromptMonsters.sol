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

import {IPromptMonsters} from "./IPromptMonsters.sol";

import {IPromptMonstersImage} from "../prompt-monsters-image/IPromptMonstersImage.sol";

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
  IERC20 public erc20;

  address public promptMonstersWallet;

  uint256 public mintPrice;

  string private _externalLink;

  mapping(address => mapping(uint256 => uint256)) private _ownerToTokenIdsIndex;

  mapping(address => IPromptMonsters.Monster) private _monsterHistory;

  mapping(address => uint256[]) private _ownerToTokenIds;

  IPromptMonsters.Monster[] private _monsters;

  mapping(address => uint256) public resurrectionIndex;

  IPromptMonstersImage public promptMonstersImage;

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
    erc20 = IERC20(erc20Address_);
    mintPrice = mintPrice_;
    promptMonstersWallet = promptMonstersWallet_;
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
  // Getter
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

  /// @dev Get monsters history
  /// @param resurrectionPrompt resurrection prompt
  /// @return monsterHistory monster history
  function getMonsterHistory(
    address resurrectionPrompt
  ) external view returns (IPromptMonsters.Monster memory monsterHistory) {
    monsterHistory = _monsterHistory[resurrectionPrompt];
  }

  /// @dev Get token IDs from owner address
  /// @param owner owner
  /// @return tokenIds token IDs
  function getOwnerToTokenIds(
    address owner
  ) external view returns (uint256[] memory tokenIds) {
    tokenIds = _ownerToTokenIds[owner];
  }

  /// @dev Get token IDs from owner address index
  /// @param owner owner
  /// @param tokenId_ token ID
  /// @return tokenIdsIndex token IDs
  function getOwnerToTokenIdsIndex(
    address owner,
    uint256 tokenId_
  ) external view returns (uint256 tokenIdsIndex) {
    tokenIdsIndex = _ownerToTokenIdsIndex[owner][tokenId_];
  }

  /// @dev Get monsters
  /// @param tokenIds_ token IDs
  /// @return monsters monsters
  function getMonsters(
    uint256[] memory tokenIds_
  ) external view returns (IPromptMonsters.Monster[] memory monsters) {
    uint256 tokenIdsLength = tokenIds_.length;
    require(
      tokenIdsLength <= _monsters.length,
      "PromptMonsters: tokenIdsLength is too large"
    );
    monsters = new IPromptMonsters.Monster[](tokenIdsLength);
    for (uint i; i < tokenIdsLength; ) {
      monsters[i] = _monsters[tokenIds_[i]];
      unchecked {
        ++i;
      }
    }
  }

  /// @dev Get token URI
  /// @param tokenId_ token ID
  /// @return uri token URI
  function tokenURI(
    uint256 tokenId_
  ) public view override returns (string memory uri) {
    _requireMinted(tokenId_);
    uri = promptMonstersImage.tokenURI(tokenId_, _monsters[tokenId_]);
  }

  /// @dev Get contract URI
  /// @return uri contract URI
  function contractURI() external view returns (string memory uri) {
    string memory name_ = name();
    string memory svg = string.concat(
      "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>",
      name_,
      "</text></svg>"
    );
    string memory json = Base64Upgradeable.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            name_,
            '", "description": "',
            name_,
            ' is Generative AI Game.", "image": "data:image/svg+xml;base64,',
            Base64Upgradeable.encode(bytes(svg)),
            '", "external_link": "',
            _externalLink,
            '"}'
          )
        )
      )
    );
    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    uri = finalTokenUri;
  }

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set external link
  /// @param newState_ new state
  function setExternalLink(
    string memory newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    string memory oldState = _externalLink;
    _externalLink = newState_;
    emit SetExternalLink(_msgSender(), oldState, newState_);
  }

  /// @dev Set ERC20 address
  /// @param newState_ new state
  function setErc20(address newState_) external onlyRole(DEFAULT_ADMIN_ROLE) {
    address oldState = address(erc20);
    erc20 = IERC20(newState_);
    emit SetErc20(_msgSender(), oldState, newState_);
  }

  /// @dev Set mint price
  /// @param newState_ new state
  function setMintPrice(
    uint256 newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint256 oldState = mintPrice;
    mintPrice = newState_;
    emit SetMintPrice(_msgSender(), oldState, newState_);
  }

  /// @dev Set prompt monsters wallet
  /// @param newState_ new state
  function setPromptMonstersWallet(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    address oldState = promptMonstersWallet;
    promptMonstersWallet = newState_;
    emit SetPromptMonstersWallet(_msgSender(), oldState, newState_);
  }

  /// @dev Set owner to token ID
  /// @param user_ user
  /// @param ownerToTokenIdIndex_ owner to token ID index
  /// @param newState_ new state
  function setOwnerToTokenId(
    address user_,
    uint256 ownerToTokenIdIndex_,
    uint256 newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _ownerToTokenIds[user_][ownerToTokenIdIndex_] = newState_;
  }

  /// @dev Set owner to token ID index
  /// @param user_ user
  /// @param tokenId_ token ID
  /// @param newState_ new state
  function setOwnerToTokenIdIndex(
    address user_,
    uint256 tokenId_,
    uint256 newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _ownerToTokenIdsIndex[user_][tokenId_] = newState_;
  }

  /// @dev Set prompt monsters image
  /// @param newState_ new state
  function setPromptMonstersImage(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    promptMonstersImage = IPromptMonstersImage(newState_);
  }

  // --------------------------------------------------------------------------------
  // Main Logic
  // --------------------------------------------------------------------------------

  /// @dev Generate monster
  /// @param resurrectionPrompt_ resurrection prompt
  /// @param monster_ monster
  function generateMonster(
    address resurrectionPrompt_,
    IPromptMonsters.Monster memory monster_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
    _monsterHistory[resurrectionPrompt_] = monster_;
    emit GenerateMonster(monster_);
  }

  /// @dev Mint monster by admin
  /// @param resurrectionPrompt resurrection prompt
  function mint(address resurrectionPrompt) external {
    require(
      erc20.balanceOf(msg.sender) >= mintPrice,
      "PromptMonsters: insufficient ERC20 balance"
    );
    IPromptMonsters.Monster memory monster = _monsterHistory[
      resurrectionPrompt
    ];
    require(monster.lv != 0, "PromptMonsters: monster is not generated");
    uint256 newTokenId = _monsters.length;
    require(
      newTokenId != type(uint256).max,
      "PromptMonsters: token ID is too large"
    );
    _monsters.push(monster);
    resurrectionIndex[resurrectionPrompt] = newTokenId;
    delete _monsterHistory[resurrectionPrompt];
    erc20.safeTransferFrom(msg.sender, promptMonstersWallet, mintPrice);
    _safeMint(msg.sender, newTokenId);

    emit MintedMonster(msg.sender, newTokenId, monster);
  }

  /// @dev Burn
  /// This function is not a standard burn function.
  /// Your NFT will be transferred to the owner of this contract if you call this function.
  /// @param tokenId_ token ID
  function burn(uint256 tokenId_) external nonReentrant {
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

  // --------------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------------

  /// @dev Add owner to token IDs
  /// @param to_ recipient
  /// @param tokenId_ token ID
  function _addOwnerToTokenIds(address to_, uint256 tokenId_) private {
    _ownerToTokenIdsIndex[to_][tokenId_] = _ownerToTokenIds[to_].length;
    _ownerToTokenIds[to_].push(tokenId_);
  }

  /// @dev Remove owner to token IDs
  /// @param from_ sender
  /// @param tokenId_ token ID
  function _removeOwnerToTokenIds(address from_, uint256 tokenId_) private {
    uint256 lastTokenId = _ownerToTokenIds[from_][
      _ownerToTokenIds[from_].length - 1
    ];
    uint256 tokenIdIndex = _ownerToTokenIdsIndex[from_][tokenId_];
    if (tokenId_ != lastTokenId)
      _ownerToTokenIds[from_][tokenIdIndex] = lastTokenId;
    _ownerToTokenIds[from_].pop();
    delete _ownerToTokenIdsIndex[from_][tokenId_];
    if (tokenId_ != lastTokenId)
      _ownerToTokenIdsIndex[from_][lastTokenId] = tokenIdIndex;
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
