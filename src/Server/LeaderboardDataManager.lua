--!strict
-- Services
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local HashUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("HashUtil"))
-- Gamework
-- Modules
local BuildCharacter =
	require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("BuildCharacter"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
-- Constants
-- Types
type List<V> = TableUtil.List<V>
type Dict<K, V> = TableUtil.Dict<K, V>
type Maid = Maid.Maid
type LeaderboardName = "Rebirths" | "Merges" | "LocalMerges"
export type LeaderboardEntry = {
	Text: string,
	Value: number,
	Name: string,
	UserId: number,
}
type TextFormatter = (value: number) -> string
type LeaderboardDataManager = {
	__index: LeaderboardDataManager,
	_Maid: Maid,
	_Name: LeaderboardName,
	_IsAlive: boolean,
	_IsAscending: boolean,
	_TextFormatter: TextFormatter,
	_NameCache: { [string]: string },
	_CurrentPlayers: { [number]: number },
	_ValueCache: { [string]: number },
	_LastReplication: number,
	_LastDSUpdate: number,
	_IsServerOnly: boolean,
	new: (
		name: LeaderboardName,
		textFormatter: TextFormatter,
		isAscending: boolean,
		isServerOnly: boolean,
		pedestalFolder: Folder,
		pedestalCF: CFrame,
		pedestalScale: number
	) -> LeaderboardDataManager,
	init: (maid: Maid) -> nil,
	update: (LeaderboardName: LeaderboardName, player: Player, value: number, saveToDatastore: boolean) -> nil,
	Destroy: (self: LeaderboardDataManager) -> nil,
	UpdateActivePlayer: (self: LeaderboardDataManager, player: Player, value: number) -> nil,
	_GetPlayerReplicationData: (self: LeaderboardDataManager, player: Player) -> LeaderboardEntry,
	_GetReplicationData: (self: LeaderboardDataManager) -> List<LeaderboardEntry>,
}

-- Constants
local DS_KEY_PREFIX = "key_"
local GET_DATA_KEY = "GetLeaderboardData"
local ON_DATA_UPDATE_KEY = "OnDataUpdate"
local REPLICATION_DELAY = 15
local DS_UPDATE_DELAY = 60 * 5
local LENGTH_LIMIT = 25
local ODS_PAGE_LENGTH = 50
local NAME_LOAD_DELAY = 1
local PAGE_LOAD_DELAY = 5
local LOCAL_MERGE_CF = CFrame.new(229 + 0.25, 14.209, -827) * CFrame.Angles(0, math.rad(-90), 0)
local MERGE_CF = CFrame.new(227.791 + 2, 15.409, -769.791) * CFrame.Angles(0, math.rad(-90), 0)
local REBIRTH_CF = CFrame.new(227.791 + 1, 12.274, -710.791) * CFrame.Angles(0, math.rad(-90), 0)
local LOCAL_MERGE_SCALE = 3
local MERGE_SCALE = 4
local REBIRTH_SCALE = 2.5
-- Variables
local leaderboards: Dict<string, LeaderboardDataManager> = {}

-- References
local STATUE_FOLDER = workspace:WaitForChild("Statues")
local REBIRTH_FOLDER: Folder = STATUE_FOLDER:WaitForChild("Rebirth") :: Folder
local MERGE_FOLDER: Folder = STATUE_FOLDER:WaitForChild("Merge") :: Folder
local LOCAL_MERGE_FOLDER: Folder = STATUE_FOLDER:WaitForChild("LocalMerge") :: Folder

-- Private functions

function getUserDatastoreKey(userId: number): string
	return DS_KEY_PREFIX .. tostring(userId)
end
function getUserIdFromDatastoreKey(userKey: string): number?
	return tonumber(userKey:sub(DS_KEY_PREFIX:len() + 1))
end
function updatePedestal(
	userIdValues: Dict<string, number>,
	isAscending: boolean,
	folder: Folder,
	cf: CFrame,
	scale: number
)
	local userKeys = TableUtil.keys(userIdValues)
	if #userKeys <= 0 then
		return
	end
	table.sort(userKeys, function(a: string, b: string)
		if isAscending then
			return userIdValues[a] < userIdValues[b]
		else
			return userIdValues[a] > userIdValues[b]
		end
	end)
	local userId = getUserIdFromDatastoreKey(userKeys[1])
	assert(userId)
	if not folder:FindFirstChild(tostring(userId)) then
		folder:ClearAllChildren()
		local model = BuildCharacter(userId, cf, scale)
		if model then
			model.Parent = folder
		end
	end
end
function getOrderedDatastore(leaderboardName: LeaderboardName): OrderedDataStore
	return DataStoreService:GetOrderedDataStore(leaderboardName .. "_ODS")
end
local function getHash(valueCache: Dict<string, number>): string
	return HashUtil.md5(HttpService:JSONEncode(valueCache))
end

-- Class
local LeaderboardDataManager: LeaderboardDataManager = {} :: any
LeaderboardDataManager.__index = LeaderboardDataManager

function LeaderboardDataManager:Destroy()
	if not self._IsAlive then
		return
	end
	self._IsAlive = false

	self._Maid:Destroy()
	setmetatable(self, nil)
	local tabl = self

	for k, v in pairs(tabl) do
		tabl[k] = nil
	end

	return nil
end

function LeaderboardDataManager:_GetPlayerReplicationData(player: Player)
	local playerKey: string = getUserDatastoreKey(player.UserId)
	local playerValue = self._ValueCache[playerKey]
	return {
		Text = if playerValue then self._TextFormatter(playerValue) else "",
		Value = playerValue,
		Name = player.DisplayName,
		UserId = player.UserId,
	}
end

function LeaderboardDataManager:_GetReplicationData()
	local data: List<LeaderboardEntry> = {}

	local userKeys = TableUtil.keys(self._ValueCache)
	table.sort(userKeys, function(a: string, b: string)
		local aVal: number = self._ValueCache[a] or (if self._IsAscending then math.huge else 0)
		local bVal: number = self._ValueCache[b] or (if self._IsAscending then math.huge else 0)
		if self._IsAscending then
			return aVal < bVal
		else
			return aVal > bVal
		end
	end)

	for i, key in ipairs(userKeys) do
		if LENGTH_LIMIT >= #TableUtil.values(data) then
			local name = self._NameCache[key]
			local value = self._ValueCache[key]
			local userId = getUserIdFromDatastoreKey(key)
			if name and value and userId then
				table.insert(data, {
					Text = self._TextFormatter(value),
					Value = value,
					Name = name,
					UserId = userId,
				})
			end
		end
	end

	return data
end

function LeaderboardDataManager:UpdateActivePlayer(player: Player?, value: number)
	if player then
		local userId = player.UserId
		local key = getUserDatastoreKey(userId)
		self._NameCache[key] = player.DisplayName
		self._ValueCache[key] = value
	end
	return nil
end

function LeaderboardDataManager.new(
	name: LeaderboardName,
	textFormatter: (value: number) -> string,
	isAscending: boolean,
	isServerOnly: boolean,
	pedestalFolder: Folder,
	pedestalCF: CFrame,
	pedestalScale: number
): LeaderboardDataManager
	local self: LeaderboardDataManager = setmetatable({}, LeaderboardDataManager) :: any
	self._Maid = Maid.new()
	self._IsAlive = true
	self._Name = name
	self._TextFormatter = textFormatter
	self._NameCache = {}
	self._CurrentPlayers = {}
	self._IsServerOnly = isServerOnly
	self._ValueCache = {}
	self._LastReplication = 0
	self._LastDSUpdate = 0
	self._IsAscending = isAscending

	local lastValueHash = getHash(self._ValueCache)

	local function updatePlayerCache()
		local currentCache = table.clone(self._CurrentPlayers)
		self._CurrentPlayers = {}
		for i, userId in ipairs(currentCache) do
			if not Players:GetPlayerByUserId(userId) then
				local key = getUserDatastoreKey(userId)
				self._ValueCache[key] = nil
				self._NameCache[key] = nil
			else
				table.insert(self._CurrentPlayers, userId)
			end
		end
	end

	self._Maid:GiveTask(Players.PlayerAdded:Connect(function(player: Player)
		table.insert(self._CurrentPlayers, player.UserId)
	end))

	local function getIfValueCacheChanged(updateIfDifferent: boolean): boolean
		local currentHash = getHash(self._ValueCache)
		local isDifferent = currentHash ~= lastValueHash
		if updateIfDifferent and isDifferent then
			lastValueHash = currentHash
		end
		-- print("cache is dif: ", isDifferent, self._ValueCache)
		-- print(currentHash, "vs", lastValueHash)
		return isDifferent
	end

	self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
		if tick() - self._LastReplication > REPLICATION_DELAY then
			--print(self._Name, "replication check", tick() - self._LastReplication)
			self._LastReplication = tick()
			updatePlayerCache()
			if getIfValueCacheChanged(true) then
				updatePedestal(self._ValueCache, self._IsAscending, pedestalFolder, pedestalCF, pedestalScale)
				local data = self:_GetReplicationData()
				-- print("LeaderData", data)
				for i, player: Player in ipairs(Players:GetChildren() :: any) do
					local playerData = self:_GetPlayerReplicationData(player)
					-- print("Firing", player, playerData)
					NetworkUtil.fireClient(ON_DATA_UPDATE_KEY, player, self._Name, data, playerData)
				end
			end
		end
		if not self._IsServerOnly and tick() - self._LastDSUpdate > DS_UPDATE_DELAY then
			print("loading ds ", self._Name)
			self._LastDSUpdate = tick()
			local datastore: OrderedDataStore = getOrderedDatastore(self._Name)
			local safeHugeInteger = 9 * 10 ^ 18
			local pages = datastore:GetSortedAsync(isAscending, ODS_PAGE_LENGTH, -safeHugeInteger, safeHugeInteger)
			local function getEntryCount(): number
				return #TableUtil.keys(self._ValueCache)
			end
			local function loadData()
				local currentPage = pages:GetCurrentPage()
				for rank, data in ipairs(currentPage) do
					if getEntryCount() < LENGTH_LIMIT then
						self._ValueCache[data.key] = data.value
						local userId = getUserIdFromDatastoreKey(data.key)
						if userId and not self._NameCache[data.key] then
							pcall(function()
								self._NameCache[data.key] = Players:GetNameFromUserIdAsync(userId)
							end)

							task.wait(NAME_LOAD_DELAY)
						end
					end
				end
				if getEntryCount() < LENGTH_LIMIT then
					local success = pcall(function()
						pages:AdvanceToNextPageAsync()
					end)
					if success then
						task.wait(PAGE_LOAD_DELAY)
						loadData()
					end
				end
			end
			loadData()
			-- print(self._Name, "dataload is complete")
		end
	end))

	return self
end

function LeaderboardDataManager.update(name: LeaderboardName, player: Player, value: number, saveToDatastore: boolean)
	-- print("update", name, player, value, saveToDatastore)
	local leaderboard = leaderboards[name]
	if leaderboard then
		leaderboard:UpdateActivePlayer(player, value)
	end
	if saveToDatastore then
		local ods = getOrderedDatastore(name)
		ods:SetAsync(getUserDatastoreKey(player.UserId), value)
	end
	return nil
end

function LeaderboardDataManager.init(maid: Maid)
	leaderboards.Rebirths = maid:GiveTask(LeaderboardDataManager.new("Rebirths", function(value: number)
		return FormatUtil.formatNumber(value)
	end, false, false, REBIRTH_FOLDER, REBIRTH_CF, REBIRTH_SCALE))

	leaderboards.Merges = maid:GiveTask(LeaderboardDataManager.new("Merges", function(value: number)
		return FormatUtil.formatNumber(value)
	end, false, false, MERGE_FOLDER, MERGE_CF, MERGE_SCALE))

	leaderboards.LocalMerges = maid:GiveTask(LeaderboardDataManager.new("LocalMerges", function(value: number)
		return FormatUtil.formatNumber(value)
	end, false, true, LOCAL_MERGE_FOLDER, LOCAL_MERGE_CF, LOCAL_MERGE_SCALE))

	NetworkUtil.getRemoteEvent(ON_DATA_UPDATE_KEY)
	NetworkUtil.onServerInvoke(
		GET_DATA_KEY,
		function(player: Player, leaderboardName: LeaderboardName): (List<LeaderboardEntry>, LeaderboardEntry?)
			local leaderboard = leaderboards[leaderboardName]
			local playerData = leaderboard:_GetPlayerReplicationData(player)
			local data = leaderboard:_GetReplicationData()
			return data, playerData
		end
	)

	return nil
end

return LeaderboardDataManager
