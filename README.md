# PromptMonsters-contract

![title](/images/title.png)

PromptMonsters is a blockchain game using Gen-AI as the game engine.

[Play now](https://prompt-monsters.com/)  
[NFT Marketplace](https://tofunft.com/ja/collection/promptmonsters/items)

## Getting started

```shell
npm i
npm run test
```

## Architecture

![architecture](/images/architecture.png)

### PromptMonsters
- Monster NFT (ERC721) contract
- Contains metadata of the monster
```solidity
struct Monster {
	string feature;   // feature（ex: fire, dragon, etc...）
	string name;      // name
	string flavor;    // flavor text
	string[] skills;  // skill names
	uint32 lv;        // level
	uint32 hp;        // hit point
	uint32 atk;       // attack
	uint32 def;       // defense
	uint32 inte;      // intelligence
	uint32 mgr;       // magic resistance
	uint32 agl;       // agility
}
```

### PromptMonstersExtension
- Monster's metadata is extended in this contract.
```solidity
struct MonsterExtension {
	string feature;   // feature（ex: fire, dragon, etc...）
	string name;      // name
	string flavor;    // flavor text
	string[] skills;  // skill names
	uint32 lv;        // level
	uint32 hp;        // hit point
	uint32 atk;       // attack
	uint32 def;       // defense
	uint32 inte;      // intelligence
	uint32 mgr;       // magic resistance
	uint32 agl;       // agility
	// ↓Extension
	uint32[] skillTypes;        // skill types
	address resurrectionPrompt; // monster ID
}

// Skill Types
// 1            → Other
// 100          → Physical Attack
// 101          → Special Attack
// 200          → Healing
// other number → Unknown

```
### PromptMonstersImage
- Monster's images are saved in this contract.
- [Ex: Holy Angel Maria](https://tofunft.com/ja/nft/mch-verse/0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238/386)

## [MCH Verse](https://explorer.oasys.mycryptoheroes.net/)
|contract|address|
|---|---|
|PromptMonsters (ERC721)|[0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238](https://explorer.oasys.mycryptoheroes.net/address/0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238)|
|PromptMonstersExtension|[0x7EA9BF1D136A9F38680B25A1072F4EdF94A62BF7](https://explorer.oasys.mycryptoheroes.net/address/0x7EA9BF1D136A9F38680B25A1072F4EdF94A62BF7)|
|PromptMonstersImage|[0xfCe6237F5CBB539bd3a116Dd9b949920aE01Df58](https://explorer.oasys.mycryptoheroes.net/address/0xfCe6237F5CBB539bd3a116Dd9b949920aE01Df58)|

## [MCH Verse Testnet](https://explorer.oasys.sand.mchdfgh.xyz/)
|contract|address|
|---|---|
|PromptMonsters (ERC721)|[0x0ed094ac867F77e56777524B59C640157BEedF84](https://explorer.oasys.sand.mchdfgh.xyz/token/0x0ed094ac867F77e56777524B59C640157BEedF84)|
|PromptMonstersExtension|[0xb67a019b7D1871401132badc51571049149fB513](https://explorer.oasys.sand.mchdfgh.xyz/token/0xb67a019b7D1871401132badc51571049149fB513)|
|PromptMonstersImage|[0x757731511815ddfd3c5e43DB29C33B22C43d431e](https://explorer.oasys.sand.mchdfgh.xyz/token/0x757731511815ddfd3c5e43DB29C33B22C43d431e)|
