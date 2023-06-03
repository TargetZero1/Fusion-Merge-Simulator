--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--types
type Maid = Maid.Maid

export type PerkType = "Cash" | "Gems" | "PetEquip" | "KickPower" | "BonusBlock"

export type PlayerDataType = {
	Cash: number,
	Gems: number,
	Energy: number,
	Rebirth: number,
	Index: {
		Object: { number },
		Pet: { string },
	},
	MergeCount: number,
	Perks: {
		[PerkType]: number,
	},
}
export type PlayerDataProperties = {
	__index: PlayerDataProperties,
	Player: Player,
	Cash: number,
	Gems: number,
	Energy: number,
	Rebirth: number,
	MergeCount: number,
	_Maid: Maid,
	_isActive: boolean,

	DiscoveredPets: { string },
	DiscoveredBlockLevels: { number },

	--block bonuses
	ProfitMultiplier: number,
	GemsProfitMultiplier: number,
	SpawnRateMultiplier: number,
	PetSpeedMultiplier: number,
	PetInfiniteEnergy: boolean,
	InstantPetAction: boolean,

	Perks: {
		[PerkType]: number,
	},

	RarityMultiplier: number,
	AutoClicker: boolean,
	AutoHatch: boolean,
	TripleHatch: boolean,
}
export type PlayerDataFunctions<Self> = {
	new: (player: Player) -> Self,
	SetCash: (Self, cashAmount: number) -> nil,
	SetGems: (Self, gemsAmount: number) -> nil,
	SetEnergy: (Self, energyAmount: number) -> nil,
	SetRebirth: (Self, rebirthAmount: number) -> nil,
	SetMergeCount: (Self, mergeCount: number) -> nil,
	SaveData: (Self) -> nil,
	Destroy: (Self) -> nil,
	Reset: (Self, isLoadMode: boolean) -> nil,
	RebirthAction: (Self) -> nil,
	SetData: (Self, PlayerDataType) -> nil,
	GetData: (Self) -> PlayerDataType,
	GetAdjustedPerkAmount: (Self, perk: PerkType, amount: number) -> number,
	GetAdjustedGamepassAmount: (Self, gamepass: number, amount: number) -> number,
	AddIndexHistory: (Self, instType: string, ...any) -> nil,
	get: (player: Player) -> Self,
	init: (maid: Maid) -> nil,
}
type EmptyPlayerData<Self> = PlayerDataProperties & PlayerDataFunctions<Self>
export type PlayerData = EmptyPlayerData<EmptyPlayerData<any>>

return {}
