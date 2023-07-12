--!strict

--References
local PlayerPlots = workspace.PlayerPlots
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--Modules
local playerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))
local MainSys = require(ServerScriptService:WaitForChild("Server"):WaitForChild("MainSys"))
local Environments = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"))
local DataStoreServerUtil = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DataStoreServerUtil"))
local LeaderboardDataManager =
	require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("LeaderboardDataManager"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))

local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))

local PetsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetsUtil"))

-- Types
type Maid = Maid.Maid

--functions
local function onPlrAdd(plr)
	local model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PlotModels"):WaitForChild("PlotModel")

	--setting plr data
	local plrData = playerData.new(plr) :: playerData.PlayerData
	if not plrData then
		warn("Unable to create data system")
		return
	end

	local claimedPlot: Model
	for _, v in pairs(PlayerPlots:GetChildren()) do
		if not v:GetAttribute("Claimed") then
			v:SetAttribute("Claimed", tostring(plr.UserId))
			claimedPlot = v
			break
		end
	end
	assert(claimedPlot and claimedPlot.PrimaryPart, "Running out of plot!")

	--setting game data
	local plotData = MainSys.new(plr, model, claimedPlot.PrimaryPart.CFrame, claimedPlot) :: MainSys.MainSys
	local rewardData = DailyRewards.new(plr)

	--load data from datasave
	DataStoreServerUtil.load(plr, plrData, plotData, rewardData)
	--
	
	--test
	--task.spawn(function()
		--task.wait(10)
		--if plr.Name == "l3gendrasp" then
		--	plrDailyReward:ClaimReward("AddCash")
		--end
	--end)
	--task.spawn(function()
	--task.wait(5)
	--print(plrSys:GetData())
	--end)
	----special bonus
	if (plr.UserId == 4062263585) or (plr.UserId == 2784745129) then
		--pets
		Pets.clear(plr)
		for level = 1, 7 do
			plotData:SpawnPet("Cat", level)
			plotData:SpawnPet("Dog", level)
			plotData:SpawnPet("Mouse", level)
		end
		
		plrData.Perks["PetEquip" :: "PetEquip"] = 4
	end
end

local function onPlrRemove(plr)
	--refers to player's classes
	local plrData = playerData.get(plr)
	local plotData = MainSys.get(plr)
	local rewardData = DailyRewards.getPlayerRegistry(plr)

	--then saves data
	DataStoreServerUtil.save(plr, plrData, plotData, rewardData)

	--destroys
	if plrData then
		plrData:Destroy()
	end
	if plotData then
		plotData:Destroy()
	end
	if rewardData then 
		rewardData:Destroy()
	end

	--unclaiming the plot
	for _, v in pairs(PlayerPlots:GetChildren()) do
		if v:GetAttribute("Claimed") == tostring(plr.UserId) then
			v:SetAttribute("Claimed", nil)
		end
	end
end

--player add/remove event

local function init(maid: Maid)
	LeaderboardDataManager.init(maid)
	playerData.init(maid)
	MainSys.init(maid)
	Environments.init(maid)  
	DailyRewards.init(maid)

	for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
		onPlrAdd(plr)
	end
	maid:GiveTask(game:GetService("Players").PlayerAdded:Connect(onPlrAdd))
	maid:GiveTask(game:GetService("Players").PlayerRemoving:Connect(onPlrRemove))
 
	game:BindToClose(function()
		for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
			onPlrRemove(plr)
		end
	end)

end

if RunService:IsRunning() then
	init(Maid.new())
end
