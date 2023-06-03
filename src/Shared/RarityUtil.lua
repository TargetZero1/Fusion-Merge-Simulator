--!strict

--types
export type RarityName = "ExtremelyRare" | "Rare" | "Common" | "ExtremelyCommon"

export type Rarity<Name> = {
	RarityPoint: number,
	Name: Name,
	Value: number,
}

export type RarityDict = {
	ExtremelyRare: Rarity<RarityName>,
	Rare: Rarity<RarityName>,
	Common: Rarity<RarityName>,
	ExtremelyCommon: Rarity<RarityName>,
}

local Rarity = {
	["ExtremelyCommon" :: RarityName] = {
		RarityPoint = 80,
		Name = "Extremely Common",
		Value = 4,
	},
	["Common" :: RarityName] = {
		RarityPoint = 15,
		Name = "Common",
		Value = 3,
	},
	["Rare" :: RarityName] = {
		RarityPoint = 5,
		Name = "Rare",
		Value = 2,
	},
	["ExtremelyRare" :: RarityName] = {
		RarityPoint = 1,
		Name = "Extremely Rare",
		Value = 1,
	},
} :: RarityDict

return Rarity
