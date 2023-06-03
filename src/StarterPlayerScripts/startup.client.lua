--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--references

--packages
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--modules
local Environments = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environments"))
local Mouse = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Mouse"))
local GuiLibrary = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"))
local LeaderboardBoot = require(
	game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Leaderboard"):WaitForChild("Boot")
)
local PlayerData = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PlayerDataClient"))
local MainSys = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"))
local Block = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Block"))
local Pet = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Pet"))

local GuiOptions = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiOptions"))
local PartButtons = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PartButtons"))

--types
type Maid = Maid.Maid

--constants
local RECIEVE_SERVER_PLOT_MODEL = "RecieveServerPlotModel"
local REQUEST_SERVER_PLOT_MODEL = "RequestServerPlotModel"

--initializing client stuff
function init(maid: Maid)
	LeaderboardBoot(maid)
	Environments.init(maid)
	Mouse.init(maid)
	GuiLibrary.init(maid)
	PartButtons.init(maid)

	PlayerData.init(maid)

	Block.init(maid)
	Pet.init(maid)

	GuiOptions.init(maid)

	local music = workspace:WaitForChild("Background Music", 10)
	if music and music:IsA("Sound") then
		task.wait()
		if game:GetService("Players").LocalPlayer.Name == "CJ_Oyer" or game:GetService("Players").LocalPlayer.Name == "aryoseno11" then --sanity protection
			music.Volume = 0
		end
	end

	local info = NetworkUtil.invokeServer(REQUEST_SERVER_PLOT_MODEL)

	--detecting plot model
	if info and info.Plot and info.ClaimedLand then
		MainSys.init(maid, info.Plot, info.ClaimedLand)
	else
		maid:GiveTask(
			NetworkUtil.onClientEvent(RECIEVE_SERVER_PLOT_MODEL, function(passedPlotModel, passedClaimedPlotModel)
				MainSys.init(maid, passedPlotModel, passedClaimedPlotModel)
			end)
		)
	end
end

if RunService:IsRunning() then
	init(Maid.new())
end
