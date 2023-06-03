--!strict
--services
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

--packages
--modules
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local PlayerDataType = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))
--constants
local CURRENT_GAME_VERSION = "v1.02"
--types
type PlayerSaveData = {
	GameData : MainSysUtil.MainSysData,
	PlayerData : PlayerDataType.PlayerDataType,
	RewardData : DailyRewards.PlayerRewardData,
	LastTimeStamp : number,
	GameVersion : string
}

--variables
local gameData1 = DataStoreService:GetDataStore("GameData1")

--local function
local function loadVanilla(player : Player, plrData: PlayerDataType.PlayerData, sysData: MainSysUtil.MainSys)
	print("Load vanilla!")
	for i = 1, 6 do
		sysData:SpawnObject()
	end
end

--change it to profileService before publishing!!!
local dataStore = {}
function dataStore.save(player: Player, plrData: PlayerDataType.PlayerData, plrSys: MainSysUtil.MainSys, rewardData : DailyRewards.RewardSys)
	assert(plrData and plrSys, "Incomplete argument!")
	--print("save attempt", player, plrSys)
	if not plrSys.isLoaded then warn("Plot has not loaded yet!"); return end
	if
		not RunService:IsStudio()
		or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == true)
	then
		--saving
		local data : PlayerSaveData = {
			GameData = plrSys:GetData(),
			PlayerData = plrData:GetData(),
			RewardData = rewardData:GetData(),
			LastTimeStamp = tick(),
			GameVersion = CURRENT_GAME_VERSION
		}

		local JSONdata = HttpService:JSONEncode(data)
		local s, e = pcall(function()
			gameData1:SetAsync("k" .. player.UserId, JSONdata)
			-- print("saving: ", JSONdata)
		end)
		if not s then
			warn("Game datasave error: ", e)
		end
	elseif
		RunService:IsStudio()
		and (
			not ServerStorage:FindFirstChild("SaveInStudio")
			or (ServerStorage:FindFirstChild("SaveInStudio") and ServerStorage.SaveInStudio.Value == false)
		)
	then
		warn("save in studio is disabled, set SaveInStudio to true, located in ServerStorage")
	end
end

function dataStore.get(player: Player)
	local s, data = pcall(function()
		return gameData1:GetAsync("k" .. player.UserId)
	end)
	if not s and data then
		warn("Game datasave error: ", data)
		return nil
	end
	return data
end

function dataStore.load(player: Player, plrData: PlayerDataType.PlayerData, sysData: MainSysUtil.MainSys, rewardData : DailyRewards.RewardSys)
	local data = dataStore.get(player)
	if not data then
		--loadVanilla(player, plrData, sysData)
		sysData.OnLoadingComplete:Fire()
		return
	end

	local convertedData :  PlayerSaveData = HttpService:JSONDecode(data) 
	print("Loading: " .. data, "Current Game Version : ", CURRENT_GAME_VERSION)
	if convertedData and convertedData.PlayerData then
		plrData:SetData(convertedData.PlayerData)
	end
	if convertedData and convertedData.GameData then
		sysData:SetData(convertedData.GameData)
	end
	if convertedData and convertedData.RewardData then
		if convertedData.GameVersion == CURRENT_GAME_VERSION then
			print("Loading Reward Data ", convertedData.RewardData)
			local playerRewardData = convertedData.RewardData :: DailyRewards.PlayerRewardData
			local startTick = playerRewardData.StartTick or tick()

			playerRewardData.StartTick = tick() - ((convertedData.LastTimeStamp or tick()) - startTick)
			rewardData:SetData(playerRewardData)
		end
	end
end
--[[function dataStore.load(player : Player, )

end]]

return dataStore
