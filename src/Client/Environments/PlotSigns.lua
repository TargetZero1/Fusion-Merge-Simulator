--!strict
--services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
--modules
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))

local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local CharacterUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterUtil"))
local PlotSign = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("PlotSign"))

--types
type Maid = Maid.Maid

--constants
local REQUEST_SERVER_PLOT_MODEL = "RequestServerPlotModel"

--references
local Player = Players.LocalPlayer

--local functions
local function onPlotSpawn(plot : Model)
    local plotMaid = Maid.new()

    local fuse = ColdFusion.fuse(plotMaid)
    local _Value = fuse.Value

    local owner = Players:GetPlayerByUserId(tonumber(plot:GetAttribute("UserId")))

    local data = NetworkUtil.invokeServer(REQUEST_SERVER_PLOT_MODEL, owner)
    local mergeCount = _Value("1")
	local plotSignPart = if data.ClaimedLand then data.ClaimedLand:FindFirstChild("PlotSign") else nil

    if plotSignPart then
        local newPlotSign = plotMaid:GiveTask(PlotSign.new(plot:GetAttribute("UserId"), mergeCount))
        newPlotSign.Instance.Parent = plotSignPart:FindFirstChild("SurfaceGui")
    end
    
    plotMaid:GiveTask(plot:GetAttributeChangedSignal("MergeCount"):Connect(function()
        mergeCount:Set(tostring(plot:GetAttribute("MergeCount")))
    end))

    plotMaid:GiveTask(plot.Destroying:Connect(function()
        plotMaid:Destroy()
    end))
    task.wait()
end

local function onPlotRemoved(plot : Model) 

end

return {
    init = function(maid : Maid)
        local playerPlotModels = workspace:FindFirstChild("PlayerPlotModels")

        for _,v : Model in pairs(playerPlotModels:GetChildren()) do
            onPlotSpawn(v)
        end

        maid:GiveTask(playerPlotModels.ChildAdded:Connect(function(plotModel)
            if plotModel:IsA("Model") then
                onPlotSpawn(plotModel)
            end
        end))
        maid:GiveTask(playerPlotModels.ChildRemoved:Connect(function(plotModel)
            if plotModel:IsA("Model") then
                onPlotRemoved(plotModel)
            end
        end))

        return nil
    end
}