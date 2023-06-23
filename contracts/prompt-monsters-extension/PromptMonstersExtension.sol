// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {Base64Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

import {IPromptMonstersExtension, IPromptMonsters} from "./IPromptMonstersExtension.sol";

/// @title PromptMonstersExtension
/// @author keit (@keitEngineer)
/// @dev This is a contract of PromptMonstersExtension.
contract PromptMonstersExtension is
  Initializable,
  IPromptMonstersExtension,
  AccessControlEnumerableUpgradeable,
  UUPSUpgradeable
{
  // --------------------------------------------------------------------------------
  // State
  // --------------------------------------------------------------------------------

  /// @custom:oz-renamed-from GAME_ROLE
  bytes32 private GAME_ROLE;

  // 1 → Other
  // 100 → Physical Attack
  // 101 → Special Attack
  // 200 → Healing
  // other → Unknown
  /// @custom:oz-renamed-from _skillTypes
  mapping(address => mapping(string => uint32)) private _skillTypes;

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Constructor
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /// @dev Initialize
  function initialize() public initializer {
    __AccessControlEnumerable_init();
    __UUPSUpgradeable_init();

    GAME_ROLE = keccak256("GAME_ROLE");

    _grantRole(GAME_ROLE, msg.sender);
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  // --------------------------------------------------------------------------------
  // Modifier
  // --------------------------------------------------------------------------------

  // --------------------------------------------------------------------------------
  // Getter
  // --------------------------------------------------------------------------------

  /// @dev Get _skillTypes
  /// @param rps_ resurrection prompts
  /// @param skills_ skills each monster
  /// @return returnState skillTypes
  function getBatchSkillTypes(
    address[] memory rps_,
    string[][] memory skills_
  ) external view returns (uint32[][] memory returnState) {
    uint256 rpsLength = rps_.length;
    returnState = new uint32[][](rpsLength);

    for (uint256 i = 0; i < rpsLength; ) {
      uint256 skillLength = skills_[i].length;
      returnState[i] = new uint32[](skillLength);
      unchecked {
        ++i;
      }

      for (uint256 j = 0; j < skillLength; ) {
        returnState[i][j] = _skillTypes[rps_[i]][skills_[i][j]];
        unchecked {
          ++j;
        }
      }
    }
  }

  // --------------------------------------------------------------------------------
  // Setter
  // --------------------------------------------------------------------------------

  /// @dev Set batch batchSkillTypes
  /// @param rps_ resurrection prompts
  /// @param skills_ skills
  /// @param skillTypes_ skillTypes
  function setBatchSkillTypes(
    address[] memory rps_,
    string[][] memory skills_,
    uint32[][] memory skillTypes_
  ) external onlyRole(GAME_ROLE) {
    uint256 rpsLength = rps_.length;
    require(
      rpsLength == skills_.length,
      "PromptMonstersExtension: mismatch rps length"
    );
    uint32[][] memory oldState = new uint32[][](rpsLength);
    for (uint256 i; i < rpsLength; ) {
      uint256 skillsLength = skills_[i].length;
      require(
        skillsLength == skillTypes_[i].length,
        "PromptMonstersExtension: mismatch skill length"
      );
      oldState[i] = new uint32[](skillsLength);
      for (uint256 j; j < skillsLength; ) {
        oldState[i][j] = _skillTypes[rps_[i]][skills_[i][j]];
        _skillTypes[rps_[i]][skills_[i][j]] = skillTypes_[i][j];
        unchecked {
          ++j;
        }
      }
      unchecked {
        ++i;
      }
    }

    emit SetBatchSkillTypes(_msgSender(), rps_, skills_, oldState, skillTypes_);
  }

  // --------------------------------------------------------------------------------
  // Main Logic
  // --------------------------------------------------------------------------------

  /// @dev Get monster extensions
  /// @param resurrectionPrompt_ resurrection prompt
  /// @param monster_ monster
  /// @return monsterExtension monster extensions
  function getMonsterExtension(
    address resurrectionPrompt_,
    IPromptMonsters.Monster memory monster_
  )
    external
    view
    returns (IPromptMonstersExtension.MonsterExtension memory monsterExtension)
  {
    uint256 skillsLength = monster_.skills.length;
    if (skillsLength > 4) skillsLength = 4;
    uint32[] memory skillTypes = new uint32[](skillsLength);
    for (uint i; i < skillsLength; ) {
      skillTypes[i] = _skillTypes[resurrectionPrompt_][monster_.skills[i]];
      unchecked {
        ++i;
      }
    }
    monsterExtension = IPromptMonstersExtension.MonsterExtension({
      feature: monster_.feature,
      name: monster_.name,
      flavor: monster_.flavor,
      skills: monster_.skills,
      lv: monster_.lv,
      hp: monster_.hp,
      atk: monster_.atk,
      def: monster_.def,
      inte: monster_.inte,
      mgr: monster_.mgr,
      agl: monster_.agl,
      skillTypes: skillTypes,
      resurrectionPrompt: resurrectionPrompt_
    });
  }

  // --------------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------------

  /// @dev Authorize upgrade
  /// @param newImplementation new implementation address
  function _authorizeUpgrade(
    address newImplementation
  ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
