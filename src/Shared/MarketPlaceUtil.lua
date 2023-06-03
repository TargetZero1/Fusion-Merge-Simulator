--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local PlayerDataType = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))

--types
type MainSys = MainSysUtil.MainSys
export type MarketPlaceUtil = { [number]: (MainSys, PlayerDataType.PlayerData) -> any }

local MarketPlaceUtil: MarketPlaceUtil = {
	--developer products
	--BLOCKS
	[MiscLists.DeveloperProductIds.Drop25Blocks] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData) --drop 25 blocks
		assert(mainSys)

		task.wait(1)
		mainSys:DropBlocks(25)
		return nil
	end,
	[MiscLists.DeveloperProductIds.Drop50Blocks] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		mainSys:DropBlocks(50)
		return nil
	end,
	[MiscLists.DeveloperProductIds.Drop100Blocks] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		mainSys:DropBlocks(100)
		return nil
	end,

	--GEMS
	[MiscLists.DeveloperProductIds.Add50Gems] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData) --drop 25 blocks
		assert(mainSys)

		task.wait(1)
		playerData:SetGems(playerData.Gems + 50)
		return nil
	end,
	[MiscLists.DeveloperProductIds.Add150Gems] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		playerData:SetGems(playerData.Gems + 150)
		return nil
	end,
	[MiscLists.DeveloperProductIds.Add500Gems] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		playerData:SetGems(playerData.Gems + 500)
		return nil
	end,

	--PETS
	[MiscLists.DeveloperProductIds.AddLevel5Cat] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData) --drop 25 blocks
		assert(mainSys)

		task.wait(1)
		mainSys:SpawnPet("Cat", 5)
		return nil
	end,
	[MiscLists.DeveloperProductIds.AddLevel5Dog] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		mainSys:SpawnPet("Dog", 5)
		return nil
	end,
	[MiscLists.DeveloperProductIds.AddLevel5Mouse] = function(mainSys: MainSys, playerData: PlayerDataType.PlayerData)
		assert(mainSys)

		task.wait(1)
		mainSys:SpawnPet("Mouse", 5)
		return nil
	end,
}

--process receipt functions
return MarketPlaceUtil
