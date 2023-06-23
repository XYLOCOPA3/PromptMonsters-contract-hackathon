// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IPromptMonsters} from "../prompt-monsters/IPromptMonsters.sol";

/// @title IPromptMonstersExtension
/// @author keit (@keitEngineer)
/// @dev This is an interface of PromptMonstersExtension.
interface IPromptMonstersExtension {
  // --------------------------------------------------------------------------------
  // Struct
  // --------------------------------------------------------------------------------

  struct MonsterExtension {
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
    uint32[] skillTypes;
    address resurrectionPrompt;
  }

  // --------------------------------------------------------------------------------
  // Event
  // --------------------------------------------------------------------------------

  event SetBatchSkillTypes(
    address indexed publisher,
    address[] indexed rps,
    string[][] indexed skills,
    uint32[][] oldState,
    uint32[][] newState
  );

  // --------------------------------------------------------------------------------
  // Initialize
  // --------------------------------------------------------------------------------

  /// @dev Initialize
  function initialize() external;

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
  ) external view returns (uint32[][] memory returnState);

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
  ) external;

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
  ) external view returns (MonsterExtension memory monsterExtension);
}
