--!strict
--Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
--Modules
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))

--Types
type Maid = Maid.Maid
type Signal = Signal.Signal

export type KickMode = "Tap" | "Kick" | "Punt"

export type MainSysTag = "Plot"

export type MainSysData = {
	BaseLevel: number,
	AutoSpawnerInterval: number,
	MaximumObjectCount: number,

	PlotId: string,
	UserId: string,
}

export type MainSysProperties = {
	__index: MainSysProperties,
	Player: Player,
	Plot: Model,
	ClaimedLand: Model,
	KickPower: number,
	KickArc: number,
	BaseLevel: number,
	MaximumObjectCount: number,
	AutoSpawnerInterval: number,
	AutoSpawnEnabled: { [PetsUtil.PetClass]: boolean },
	KickMode: KickMode,
	Public: boolean,
	isLoaded : boolean,
	OnLoadingComplete: Signal,
	_Maid: Maid,
}

export type MainSysFunctions<Self> = {
	new: (player: Player, plot: Model, cframe: CFrame, claimedPlot: Model) -> Self,
	SetObjectSpawnLoop: (Self) -> nil,
	SpawnObject: (Self, info: BlocksUtil.BlockData?, force: boolean?) -> any,
	SpawnPet: (Self, petName: string, level: number?, equipped: boolean?) -> any,
	Update: (Self) -> any,
	SetData: (Self, info: { [any]: any }) -> nil,
	GetData: (Self) -> MainSysData,
	Hatch: (Self, petClass: PetsUtil.PetClass, isPremium: boolean, isLucky: boolean, isSuperLucky: boolean) -> string?,
	SetCharacter: (Self, BlockInteractMode) -> nil,
	Reset: (Self, clean: boolean) -> nil,
	Destroy: (Self) -> nil,
	UpgradeBaseLevel: (Self) -> number?,
	UpgradeLimitCount: (Self) -> number?,
	UpgradeSpawnRate: (Self) -> number?,
	KickBlocks: (Self, strength: number) -> nil,
	DropBlocks: (Self, count: number) -> nil,
	SwitchKickMode: (Self, KickMode) -> nil,
	SwitchPlotPublic: (Self, boolean) -> nil,
	get: (player: Player) -> Self,
	init: (maid: Maid) -> nil,
}

export type EmptyMainSys<self> = MainSysProperties & MainSysFunctions<self>

export type MainSys = EmptyMainSys<EmptyMainSys<any>>

export type BlockInteractMode = "Bounce" | "Weld"

local MainSysUtil = {}

function MainSysUtil.newMainSysData(
	userId: string,
	baseLevel: number?,
	AutoSpawnerInterval: number?,
	MaximumObjectCount: number?
): MainSysData
	return {
		PlotId = game:GetService("HttpService"):GenerateGUID(false),
		UserId = userId,
		BaseLevel = baseLevel or 1,
		AutoSpawnerInterval = AutoSpawnerInterval or MiscLists.Limits.AutoSpawnerInterval,
		MaximumObjectCount = MaximumObjectCount or MiscLists.Limits.MaximumObjectCount,
	}
end

function MainSysUtil.applyMainSysData(plotModel: Model, MainSysData: MainSysData)
	plotModel:SetAttribute("BaseLevel", MainSysData.BaseLevel)
	plotModel:SetAttribute("AutoSpawnerInterval", MainSysData.AutoSpawnerInterval)
	plotModel:SetAttribute("MaximumObjectCount", MainSysData.MaximumObjectCount)

	plotModel:SetAttribute("PlotId", MainSysData.PlotId)
	plotModel:SetAttribute("UserId", MainSysData.UserId)

	return nil
end

function MainSysUtil.getMainSysData(plotModel: Model): MainSysData
	return {
		BaseLevel = plotModel:GetAttribute("BaseLevel"),
		AutoSpawnerInterval = plotModel:GetAttribute("AutoSpawnerInterval"),
		MaximumObjectCount = plotModel:GetAttribute("MaximumObjectCount"),

		PlotId = plotModel:GetAttribute("PlotId"),
		UserId = plotModel:GetAttribute("UserId"),
	}
end

function MainSysUtil.getPlotModelById(id: string): Model?
	for _, plotModel: Model in pairs(CollectionService:GetTagged("Plot" :: MainSysTag)) do
		local plotData = MainSysUtil.getMainSysData(plotModel)
		if plotData.PlotId == id then
			return plotModel
		end
	end
	return nil
end

return MainSysUtil
