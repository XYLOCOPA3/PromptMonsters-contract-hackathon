# PromptMonsters-contract

![title](/images/title.png)

PromptMonsters is a blockchain game using Gen-AI as the game engine.

[Play now](https://prompt-monsters.com/)
[NFT Marketplace](https://tofunft.com/ja/collection/promptmonsters/items)

## Getting started

```shell
npm i
npm run test
# Input .env
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

### PromptMonstersImage
- The monster image is saved.
- [Ex: Holy Angel Maria](https://tofunft.com/ja/nft/mch-verse/0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238/386)

## [MCH Verse](https://explorer.oasys.mycryptoheroes.net/)
|contract|address|
|---|---|
|PromptMonsters (ERC721)|[0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238](https://explorer.oasys.mycryptoheroes.net/address/0x12C7aA85c8BE2b32bdCfC013Da08347EeE95c238)|
|PromptMonstersImage|[0xfCe6237F5CBB539bd3a116Dd9b949920aE01Df58](https://explorer.oasys.mycryptoheroes.net/address/0xfCe6237F5CBB539bd3a116Dd9b949920aE01Df58)|
