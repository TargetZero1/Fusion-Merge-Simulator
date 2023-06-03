--!strict
-- Services
local HttpService = game:GetService("HttpService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local HashUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("HashUtil"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
-- Modules
local Leaderboard = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Leaderboard"))

-- Types
type Maid = Maid.Maid
type LeaderboardName = "Rebirths" | "Merges" | "LocalMerges"
type LeaderboardEntry = Leaderboard.LeaderboardEntry
type List<V> = TableUtil.List<V>
type Dict<K,V> = TableUtil.Dict<K,V>
type ValueState<T> = ColdFusion.ValueState<T>
-- Constants
local GET_DATA_KEY = "GetLeaderboardData"
local ON_DATA_UPDATE_KEY = "OnDataUpdate"

-- Variables
-- References
local Player = game:GetService("Players").LocalPlayer
-- Class
return function(maid: Maid): nil
	local _fuse = ColdFusion.fuse(maid)
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	-- leaderboards
	local function getEmptyPlayerLeaderboardEntry(): LeaderboardEntry
		return {
			UserId = Player.UserId,
			Name = Player.DisplayName,
			Value = 0,
			Rank = 0,
			Text = "",
		}
	end

	local LocalMergeData: ValueState<Dict<string, LeaderboardEntry>> = _Value({})
	local MergeData: ValueState<Dict<string, LeaderboardEntry>> = _Value({})
	local RebirthData: ValueState<Dict<string, LeaderboardEntry>> = _Value({})

	local PlayerLocalMergeData = _Value(getEmptyPlayerLeaderboardEntry())
	local PlayerMergeData = _Value(getEmptyPlayerLeaderboardEntry())
	local PlayerRebirthData = _Value(getEmptyPlayerLeaderboardEntry())

	local function appendNewData(newData: { [number]: LeaderboardEntry }, oldData: { [string]: LeaderboardEntry }, isAscending: boolean): { [string]: LeaderboardEntry }
		local registry: { [number]: LeaderboardEntry } = {}
		for k, v in pairs(oldData) do
			registry[v.UserId] = v
		end
		for k, v in pairs(newData) do
			registry[v.UserId] = v
		end

		local userIds = TableUtil.keys(registry)
		table.sort(userIds, function(a: number, b: number)
			local aVal = registry[a].Value
			local bVal = registry[b].Value
			if isAscending then
				return aVal < bVal
			else
				return aVal > bVal
			end
		end)
		for i, userId in ipairs(userIds) do
			registry[userId].Rank = i
		end

		for k, v in pairs(oldData) do
			oldData[k] = nil
		end

		local finalRegistry = oldData
		for i, v in pairs(registry) do
			finalRegistry[HashUtil.md5(HttpService:JSONEncode(v))] = v
		end

		return finalRegistry
	end

	local function updateData(
		leaderboardName: LeaderboardName,
		data: { [number]: LeaderboardEntry },
		playerData: LeaderboardEntry?
	)
		print(leaderboardName--[[, "data received: ", string.len(HttpService:JSONEncode(data)), "bytes", data]])
		if leaderboardName == "LocalMerges" then
			LocalMergeData:Set(appendNewData(data, LocalMergeData:Get(), false))
			PlayerLocalMergeData:Set(playerData or getEmptyPlayerLeaderboardEntry())
		elseif leaderboardName == "Merges" then
			MergeData:Set(appendNewData(data, MergeData:Get(), false))
			PlayerMergeData:Set(playerData or getEmptyPlayerLeaderboardEntry())
		elseif leaderboardName == "Rebirths" then
			RebirthData:Set(appendNewData(data, RebirthData:Get(), false))
			PlayerRebirthData:Set(playerData or getEmptyPlayerLeaderboardEntry())
		end
	end

	local function setData(leaderboardName: LeaderboardName)
		updateData(leaderboardName, NetworkUtil.invokeServer(GET_DATA_KEY, leaderboardName))
	end
	local mergeBoard = workspace:WaitForChild("Leaderboards"):WaitForChild("MergeBoard")
	local mergeFrame =
		maid:GiveTask(Leaderboard("Game Merges", Color3.fromRGB(143, 108, 53), MergeData, PlayerMergeData))
	local mergeGui = mergeBoard:WaitForChild("SurfaceGui") :: SurfaceGui
	mergeGui.Name = "MergeLeaderboard"
	mergeFrame.Parent = mergeGui
	mergeGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	mergeGui.Adornee = mergeBoard
	mergeGui.ResetOnSpawn = false

	local localMergeBoard = workspace:WaitForChild("Leaderboards"):WaitForChild("LocalMergeBoard")
	local localMergeFrame =
		maid:GiveTask(Leaderboard("Server Merges", Color3.fromRGB(125, 113, 82), LocalMergeData, PlayerLocalMergeData))
	local localMergeGui = localMergeBoard:WaitForChild("SurfaceGui") :: SurfaceGui
	localMergeGui.Name = "LocalMergeLeaderboard"
	localMergeFrame.Parent = localMergeGui
	localMergeGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	localMergeGui.Adornee = localMergeBoard
	localMergeGui.ResetOnSpawn = false

	local rebirthBoard = workspace:WaitForChild("Leaderboards"):WaitForChild("RebirthBoard")
	local rebirthFrame =
		maid:GiveTask(Leaderboard("Rebirths", Color3.fromRGB(136, 145, 161), RebirthData, PlayerRebirthData))
	local rebirthGui = rebirthBoard:WaitForChild("SurfaceGui") :: SurfaceGui
	rebirthGui.Name = "RebirthLeaderboard"
	rebirthFrame.Parent = rebirthGui
	rebirthGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	rebirthGui.Adornee = rebirthBoard
	rebirthGui.ResetOnSpawn = false

	maid:GiveTask(NetworkUtil.onClientEvent(ON_DATA_UPDATE_KEY, updateData))
	task.spawn(function()
		setData("Rebirths")
		setData("Merges")
		setData("LocalMerges")
	end)
	return nil
end
