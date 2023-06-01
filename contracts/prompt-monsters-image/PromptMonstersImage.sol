// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {Base64Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

import {IPromptMonsters} from "../prompt-monsters/IPromptMonsters.sol";
import {IPromptMonstersImage} from "./IPromptMonstersImage.sol";

/// @title PromptMonstersImage
/// @author keit (@keitEngineer)
/// @dev This is a contract of PromptMonstersImage.
contract PromptMonstersImage is
  Initializable,
  IPromptMonstersImage,
  AccessControlEnumerableUpgradeable,
  UUPSUpgradeable
{
  // --------------------------------------------------------------------------------
  // State
  // --------------------------------------------------------------------------------

  IPromptMonsters public promptMonsters;

  mapping(uint256 => string) public imageURL;

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Constructor
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /// @dev Initialize
  /// @param promptMonstersAddress_ prompt monsters address
  function initialize(address promptMonstersAddress_) public initializer {
    __AccessControlEnumerable_init();
    __UUPSUpgradeable_init();

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    promptMonsters = IPromptMonsters(promptMonstersAddress_);
  }

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
  ) external view returns (string memory uri) {
    string memory imageURL_ = imageURL[tokenId_];
    if (bytes(imageURL_).length == 0) {
      string memory svg = _getSvg(monster_);
      imageURL_ = string.concat(
        '"data:image/svg+xml;base64,',
        Base64Upgradeable.encode(bytes(svg))
      );
    } else {
      imageURL_ = string.concat('"', imageURL_);
    }
    string memory skills = "";
    for (uint i; i < monster_.skills.length; i++) {
      if (i + 1 > 4) break;
      skills = string.concat(
        skills,
        ' }, { "trait_type": ',
        '"Skill',
        StringsUpgradeable.toString(i + 1),
        '", "value": "',
        monster_.skills[i],
        '"'
      );
    }
    string memory json = string(
      abi.encodePacked(
        '{"name": "',
        monster_.name,
        '", "description": "',
        monster_.flavor,
        '", "image": ',
        imageURL_,
        '", "attributes": [ { "trait_type": "LV", "value": ',
        StringsUpgradeable.toString(monster_.lv),
        ' }, { "trait_type": "HP", "value": ',
        StringsUpgradeable.toString(monster_.hp),
        ' }, { "trait_type": "ATK", "value": ',
        StringsUpgradeable.toString(monster_.atk)
      )
    );
    // `Stack too deep` エラーで実行できないため分割
    json = Base64Upgradeable.encode(
      bytes(
        string(
          abi.encodePacked(
            json,
            ' }, { "trait_type": "DEF", "value": ',
            StringsUpgradeable.toString(monster_.def),
            ' }, { "trait_type": "INT", "value": ',
            StringsUpgradeable.toString(monster_.inte),
            ' }, { "trait_type": "MGR", "value": ',
            StringsUpgradeable.toString(monster_.mgr),
            ' }, { "trait_type": "AGL", "value": ',
            StringsUpgradeable.toString(monster_.agl),
            skills,
            " } ] }"
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

  /// @dev Set image URL
  /// @param tokenId_ token ID
  /// @param newState_ new state
  function setImageURL(
    uint256 tokenId_,
    string memory newState_
  ) public onlyRole(DEFAULT_ADMIN_ROLE) {
    string memory oldState = imageURL[tokenId_];
    imageURL[tokenId_] = newState_;
    emit SetImageURL(_msgSender(), oldState, newState_);
  }

  /// @dev Set image URL
  /// @param tokenIds_ token ID
  /// @param newStates_ new state
  function setBatchImageURL(
    uint256[] memory tokenIds_,
    string[] memory newStates_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(tokenIds_.length == newStates_.length, "Invalid length");
    for (uint256 i; i < tokenIds_.length; i++) {
      setImageURL(tokenIds_[i], newStates_[i]);
    }
  }

  /// @dev Set Prompt Monsters
  /// @param newState_ new state
  function setPromptMonsters(
    address newState_
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    address oldState = address(promptMonsters);
    promptMonsters = IPromptMonsters(newState_);
    emit SetPromptMonsters(_msgSender(), oldState, newState_);
  }

  // --------------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------------

  /// @dev Get SVG
  /// @param monster monster
  /// @return svg SVG
  function _getSvg(
    IPromptMonsters.Monster memory monster
  ) internal pure returns (string memory svg) {
    svg = string.concat(
      '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />',
      _getSvgText(10, 20, monster.name),
      _getSvgText(
        10,
        60,
        string.concat("LV: ", StringsUpgradeable.toString(monster.lv))
      ),
      _getSvgText(
        10,
        100,
        string.concat("HP: ", StringsUpgradeable.toString(monster.hp))
      ),
      _getSvgText(
        10,
        120,
        string.concat("ATK: ", StringsUpgradeable.toString(monster.atk))
      ),
      _getSvgText(
        10,
        140,
        string.concat("DEF: ", StringsUpgradeable.toString(monster.def))
      ),
      _getSvgText(
        10,
        160,
        string.concat("INT: ", StringsUpgradeable.toString(monster.inte))
      ),
      _getSvgText(
        10,
        180,
        string.concat("MGR: ", StringsUpgradeable.toString(monster.mgr))
      ),
      _getSvgText(
        10,
        200,
        string.concat("AGL: ", StringsUpgradeable.toString(monster.agl))
      )
    );

    uint256 y = 240;
    for (uint i; i < monster.skills.length; i++) {
      if (i + 1 > 4) break;
      svg = string.concat(
        svg,
        _getSvgText(
          10,
          y + 20 * i,
          string.concat(
            "Skill",
            StringsUpgradeable.toString(i + 1),
            ": ",
            monster.skills[i]
          )
        )
      );
    }
    svg = string.concat(svg, "</svg>");
  }

  /// @dev Get SVG text
  /// @param x_ x position
  /// @param y_ y position
  /// @param text_ text
  /// @return svg SVG
  function _getSvgText(
    uint256 x_,
    uint256 y_,
    string memory text_
  ) internal pure returns (string memory svg) {
    svg = string.concat(
      '<text x="',
      StringsUpgradeable.toString(x_),
      '" y="',
      StringsUpgradeable.toString(y_),
      '" class="base">',
      text_,
      "</text>"
    );
  }

  /// @dev Authorize upgrade
  /// @param newImplementation new implementation address
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
