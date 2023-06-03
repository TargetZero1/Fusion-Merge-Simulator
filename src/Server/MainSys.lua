-- INFO: This is plot system for players

--!strict
--Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--References
local Assets = ReplicatedStorage:WaitForChild("Assets")

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

--Dependancies
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local PetsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetsUtil"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local MarketPlaceUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MarketPlaceUtil"))
local CharacterUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterUtil"))
local EffectsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EffectsUtil"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))
local Pets = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"))
local DatastoreServerUtil = require(ServerScriptService:WaitForChild("Server"):WaitForChild("DataStoreServerUtil"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))

--variables
local Registry = {}

--constants
local DEFAULT_BASE_LEVEL = 1
local HATCH_COST = 750000

local GROUP_ID = 11827920
local BLOCK_PROFIT_CLICK_BONUS = 2
local BLOCK_MERGE_BONUS_CASH = 10
local BLOCK_PROFIT_INTERVAL = 5

local MAX_PET_COUNT = 50
local MAX_OBJECT_LEVEL = MiscLists.Limits.MaxObjectLevel
local MAX_OBJECT_COUNT_ON_PLOT= 20

local MIN_OBJECT_HEIGHT: number = -50
local MAX_OBJECT_HEIGHT: number = 10

local SAVE_DATA_INTERVAL = 2*60

local HATCH_KEY = "Hatch"
local AUTO_HATCH_KEY = "AutoHatch"
local TRIPLE_HATCH_KEY = "TripleHatch"
local ON_AUTO_FAIL = "OnAutoFail"
local AUTO_GAMEPASS_ID = MiscLists.GamePassIds.AutoHatch
local LUCKY_GAMEPASS_ID = MiscLists.GamePassIds.Lucky
local SUPER_LUCKY_GAMEPASS_ID = MiscLists.GamePassIds.SuperLucky
local GET_PET_DATA = "GetPetData"
local ON_PET_DATA_UPDATE = "OnPetDataUpdate"
local ON_KICK_MODE_UPDATE = "OnKickModeUpdate"
local FIRE_PREMIUM_HATCH_SEQUENCE = "FirePremiumHatchSequence"

local RECIEVE_SERVER_PLOT_MODEL = "RecieveServerPlotModel"
local REQUEST_SERVER_PLOT_MODEL = "RequestServerPlotModel"

local ON_PROFIT = "OnProfitFx"
local ON_MERGE = "OnMergeFx"
local HARD_RESET = "HardReset"

local PREMIUM_CAT_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Cat
local PREMIUM_DOG_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Dog
local PREMIUM_MOUSE_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Mouse

--Remotes
local ON_BLOCK_CLICKED = "OnBlockClicked"
local ON_KICK_MODE_SWITCH = "OnKickModeSwitch"
local ON_PUBLIC_PLOT_SWITCH = "OnPublicPlotSwitch"
local ON_BONUS_BLOCK_INTERACT = "OnBonusBlockInteract"
--local ON_BLOCK_KICK = "OnBlockKick"

local ON_PERKS_UPDATE = "OnPerksUpdate"

local TRIGGER_HATCH_ANIMATION_KEY = "TriggerHatchAnimationKey"

local UTC_TIMEZONE_DIFF = 1 -- in hour

--types
type Maid = Maid.Maid

type KickMode = MainSysUtil.KickMode
type Signal = Signal.Signal
export type SysData = {
	BaseLevel: number,
	MaximumObjectCount: number,
	AutoSpawnerInterval: number,
	KickMode: MainSysUtil.KickMode,

	Objects: { BlocksUtil.BlockData },
	Pets: { Pets.PetData },
}

export type MainSys = MainSysUtil.MainSys

export type BlockInteractMode = MainSysUtil.BlockInteractMode

--private functions
local function getRandomPositionInPlot(plotPart: BasePart)
	local size = plotPart.Size * 0.9
	local xPos = plotPart.CFrame.RightVector * (math.random(-size.X * 0.4, size.X * 0.4))
	local yPos = plotPart.CFrame.LookVector * (math.random(-size.Z * 0.4, size.Z * 0.4))
	return (plotPart.CFrame + xPos + yPos)
		+ Vector3.fromAxis(Enum.Axis.Y) * Assets.ObjectModels.TypeA.PrimaryPart.Size.Y * 3
end

local function getBlockProfit(blockModel: Model)
	local blockData = BlocksUtil.getBlockData(blockModel)
	return MiscLists.Limits.BlockIncomeOnLevel[blockData.Level] or 0 --BLOCK_PROFIT_MULTIPLIER*NumberUtil.BaseMultiplier(1, blockData.Level)
end

local function setBlockData(blockModel: Model, setBlockData: BlocksUtil.BlockData)
	BlocksUtil.applyBlockData(blockModel, table.clone(setBlockData))
	BlocksUtil.BlockLeveLVisualUpdate(blockModel)
end

local function _MergeBlock(blockModel: Model, blocksArray)
	local blockData = BlocksUtil.getBlockData(blockModel)
	for _, mergeableBlock: Model in pairs(blocksArray) do
		local mergeableBlockData = BlocksUtil.getBlockData(mergeableBlock)
		if (mergeableBlockData.Level == blockData.Level) and blockModel.PrimaryPart and mergeableBlock.PrimaryPart then
			local cfOrigin = blockModel.PrimaryPart.CFrame :: CFrame
			local cfGoal = mergeableBlock.PrimaryPart.CFrame :: CFrame
			for i = 0, 1, 0.025 do
				task.wait()
				if blockModel.PrimaryPart and mergeableBlock.PrimaryPart then
					blockModel:PivotTo(cfOrigin:Lerp(cfGoal, math.sin(math.rad(i * 90))))
				else
					break
				end
			end
			if blockModel.PrimaryPart then
				blockModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
			elseif mergeableBlock.PrimaryPart then
				mergeableBlock.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
			end
		end
	end
end

local function _MergeBlocks(blocksArray)
	for _, blockModel: Model in pairs(blocksArray) do
		--selects any blocks that can merge with
		task.spawn(function()
			_MergeBlock(blockModel, blocksArray)
		end)
		task.wait(30)
	end
end

local function blockPulseOnMerge(mergedBlock: Model, ChainReactionVal: number?, blackList: { Model }?)
	assert(mergedBlock.PrimaryPart, "Block has no primary part!")
	local ChainReactionValue = math.clamp(ChainReactionVal or 0, 0, 65)

	local Radius = math.random(5, 15) + ChainReactionValue
	local FORCE_QUANTITY = 1

	local mergedBlockData = BlocksUtil.getBlockData(mergedBlock)
	if mergedBlockData.Level then
		local blocksData = BlocksUtil.getBlocks()
		local taggedBlocks = {} :: { any }

		for _, data in pairs(blocksData) do
			local blockModel = BlocksUtil.getBlockModelById(data.BlockId)
			if
				blockModel
				and blockModel.PrimaryPart
				and (blockModel ~= mergedBlock)
				and mergedBlock.PrimaryPart
				and (not blackList or (blackList and not table.find(blackList, blockModel)))
			then
				--define radius
				local dist = (blockModel.PrimaryPart.Position - mergedBlock.PrimaryPart.Position).Magnitude
				if dist <= Radius then
					--tag the blocks
					local newBlockData: any = table.clone(data)
					newBlockData.Group = if not blockModel:GetAttribute("OnHold") then math.random(1, 3) else 3
					table.insert(taggedBlocks, newBlockData)
				end
			end
		end

		--get pets
		local pets = Pets.getPets()
		for _, petInfo in pairs(pets) do
			if petInfo.PetModel.PrimaryPart then
				local dist = (petInfo.PetModel.PrimaryPart.Position - mergedBlock.PrimaryPart.Position).Magnitude
				if dist <= Radius then
					petInfo:Detach()
				end
			end
		end

		for _, taggedBlockData in pairs(taggedBlocks) do
			local taggedBlockModel = if taggedBlockData.BlockId
				then BlocksUtil.getBlockModelById(taggedBlockData.BlockId)
				else nil
			if
				taggedBlockModel
				and taggedBlockModel.PrimaryPart
				and mergedBlock.PrimaryPart
				and (taggedBlockModel ~= mergedBlock)
			then
				local force1: Vector3 = -(mergedBlock.PrimaryPart.Position - taggedBlockModel.PrimaryPart.Position)
					* FORCE_QUANTITY
					* 0.08
					* taggedBlockModel.PrimaryPart:GetMass()
				local force2: Vector3 = taggedBlockModel.PrimaryPart.AssemblyLinearVelocity
					+ Vector3.new(0, FORCE_QUANTITY * 1, 0) * taggedBlockModel.PrimaryPart:GetMass()

				--print(taggedBlockData, taggedBlockData.Group, " ganjar")
				if taggedBlockData.Group == 1 then
					taggedBlockModel.PrimaryPart.AssemblyLinearVelocity = force1
				elseif taggedBlockData.Group == 2 then
					taggedBlockModel.PrimaryPart.AssemblyLinearVelocity = force2
				elseif taggedBlockData.Group == 3 then
					taggedBlockModel.PrimaryPart.AssemblyLinearVelocity = force1 + force2
				end
			end
		end

		--set chain reaction
		local newBlackList = blackList or {}
		for _, taggedBlockData in pairs(taggedBlocks) do
			local model: Model? = BlocksUtil.getBlockModelById(taggedBlockData.BlockId)

			if model then
				table.insert(newBlackList, model)
			end
		end
		if #taggedBlocks > 0 then
			ChainReactionValue += Radius
			task.wait()
			blockPulseOnMerge(mergedBlock, ChainReactionValue, newBlackList)
		end
	end

	return nil
end

--class
local MainSys = {} :: MainSys
MainSys.__index = MainSys

--constructor
function MainSys.new(player: Player, plot: Model, cframe: CFrame, claimedPlot: Model): MainSys
	local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _import = _fuse.import
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local self: MainSys = setmetatable({}, MainSys) :: any
	--Main player data
	self._Maid = maid :: Maid
	self.Player = player :: Player
	self.Plot = self._Maid:GiveTask(plot:Clone()) :: Model
	self.ClaimedLand = claimedPlot
	self.BaseLevel = 1 :: number
	self.MaximumObjectCount = MiscLists.Limits.MaximumObjectCount --MAX_OBJECT_COUNT
	self.Public = true :: boolean
	self.isLoaded = false :: boolean
	self.AutoSpawnerInterval = MiscLists.Limits.AutoSpawnerInterval
	self.OnLoadingComplete = self._Maid:GiveTask(Signal.new())
	self.AutoSpawnEnabled = {
		Mouse = false,
		Dog = false,
		Cat = false,
		Premium = false,
	}
	self.KickMode = "Kick"
	self.KickPower = MiscLists.Limits.KickPower :: number
	self.KickArc = MiscLists.Limits.KickArc :: number
	--init
	local mainSysData = MainSysUtil.newMainSysData(tostring(self.Player.UserId), self.BaseLevel)
	MainSysUtil.applyMainSysData(self.Plot, mainSysData)
	--declaring
	--spawning plot
	self.Plot:PivotTo(cframe)
	self.Plot:SetAttribute("UserId", self.Player.UserId)
	self.Plot.Parent = workspace:FindFirstChild("PlayerPlotModels")
	--seting tag
	CollectionService:AddTag(self.Plot, "Plot")
	--self.MaximumObjectCount  =   micsLists.Limits.MaximumObjectCount :: number
	--self.AutoSpawnerInterval =   micsLists.Limits.AutoSpawnerInterval :: number
	Registry[self.Player] = self
	--running object
	self:SetObjectSpawnLoop()
	self:SetCharacter("Bounce")
	--detects whenever players are resetted
	self.Player.CharacterAdded:Connect(function()
		self:SetCharacter("Bounce")
	end)
	--setting the collision group
	local separators = self.Plot:WaitForChild("Separators") :: Model
	for _, v: BasePart in pairs(separators and separators:GetDescendants() or {}) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Separator"
		end
	end

	self:Update()

	--test drop blocks
	--[[ task.spawn(function()
        task.wait(5)
        self:DropBlocks(25)
    end)]]
	--testing pet
	--self:SpawnPet("Cat")

	local plrData = PlayerData.get(player)

	local lastUpdate = {
		Premium = tick(),
		Dog = tick(),
		Cat = tick(),
		Mouse = tick(),
	}
	self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
		for i, petClass: PetsUtil.PetClass in ipairs({ "Premium", "Dog", "Cat", "Mouse" } :: any) do
			if self.AutoSpawnEnabled[petClass] and self.AutoSpawnerInterval < tick() - lastUpdate[petClass] then
				lastUpdate[petClass] = tick()
				local petName = self:Hatch(
					petClass,
					false,
					MarketplaceService:PlayerOwnsAsset(player, LUCKY_GAMEPASS_ID),
					MarketplaceService:PlayerOwnsAsset(player, SUPER_LUCKY_GAMEPASS_ID)
				)

				if not petName then
					self.AutoSpawnEnabled[petClass] = false
					NetworkUtil.fireClient(
						ON_AUTO_FAIL,
						self.Player,
						"Auto-spawner failed, you may be out of money or storage space."
					)
				end
			end
		end
	end))

	
	--pet update client gui
	--[[local function petGuiClientUpdate()
		local data = self:GetData(true) :: SysData
		if data then NetworkUtil.fireClient(ON_PET_DATA_UPDATE, self.Player, data.Pets) end
	end
	local PetModels = self.Plot:WaitForChild("Pets")
	if PetModels then
		PetModels.ChildAdded:Connect(function()
			petGuiClientUpdate()
		end)
		PetModels.ChildRemoved:Connect(function()
			petGuiClientUpdate()
		end)
	end
	local Storages = Assets:FindFirstChild("Storages")
	if Storages then
		Storages.ChildAdded:Connect(function()
			petGuiClientUpdate()
		end)
		Storages.ChildRemoved:Connect(function()
			petGuiClientUpdate()
		end)
	end

	petGuiClientUpdate()]]
	--merge count
	local mergeCount = _Value(tostring(plrData.MergeCount))

	--updates block plinth
	local blockPlinthModel = claimedPlot:FindFirstChild("BlockPlinth") :: Model
	local blockDisplay = if blockPlinthModel then blockPlinthModel:FindFirstChild("Block") :: Model else nil

	local distributers = self.Plot:FindFirstChild("Distributers")

	if blockDisplay and blockDisplay.PrimaryPart then
		local intTick = tick()
		self._Maid:GiveTask(RunService.Stepped:Connect(function()
			if (tick() - intTick) > 1 then
				intTick = tick()
				local blocks = plrData.DiscoveredBlockLevels
				table.sort(blocks, function(a, b)
					return a > b
				end)
				local highestBlockData = if blocks[1]
					then BlocksUtil.newBlockData(self.Player.UserId, blocks[1], false)
					else nil
				if highestBlockData then
					BlocksUtil.BlockLeveLVisualUpdate(blockDisplay, highestBlockData)
				end
			end

			--rotates
			--[[blockDisplay:PivotTo(blockDisplay.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(0.3), 0))

			--rotates eggs as well
			if distributers then
				for _, model: Model in pairs(distributers:GetChildren() :: any) do
					local egg = model:FindFirstChild("Egg") :: Model
					if egg and egg:IsA("Model") and egg.PrimaryPart then
						egg:PivotTo(
							egg.PrimaryPart.CFrame
								* CFrame.Angles(0, math.rad(0.3) * (model:GetAttribute("Direction") or 1), 0)
						)
					end
				end
			end]]
			--updates merge count
			self.Plot:SetAttribute("MergeCount", plrData.MergeCount)
			claimedPlot:SetAttribute("MergeCount", plrData.MergeCount)
			--mergeCount:Set(tostring(plrData.MergeCount))
		end))
	end

	--confirms plot is added to client
	NetworkUtil.fireClient(RECIEVE_SERVER_PLOT_MODEL, self.Player, self.Plot, self.ClaimedLand)

	--plot sign
	--[[local plotSignPart = claimedPlot:FindFirstChild("PlotSign")
	if plotSignPart and plotSignPart:FindFirstChild("SurfaceGui") then
		local PlotSign =
			require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("PlotSign"))
		local newPlotSign = self._Maid:GiveTask(PlotSign.new(self.Player.UserId, mergeCount))
		newPlotSign.Instance.Parent = plotSignPart:FindFirstChild("SurfaceGui")
	end]]

	self.Player:SetAttribute("KickMode", self.KickMode)

	-- 
	local intTick = tick()
	self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
		if (tick() - intTick) >= SAVE_DATA_INTERVAL then
			intTick = tick()
			local rewardData = DailyRewards.getPlayerRegistry(self.Player)

			DatastoreServerUtil.save(player, plrData, self, rewardData)
		end
		return nil
	end))
	self._Maid:GiveTask(self.OnLoadingComplete:Connect(function()
		self.isLoaded = true
	end))
	--load 6 blocks as default
	--for i = 1, 6 do
	--	self:SpawnObject()
	--end

	
	return self
end

function MainSys:SetObjectSpawnLoop()
	local plrData = PlayerData.get(self.Player)
	local intTick = tick()
	self._Maid.ObjectSpawn = RunService.Stepped:Connect(function()
		if (tick() - intTick) >= (self.AutoSpawnerInterval / plrData.SpawnRateMultiplier) then
			--refreshing tick
			intTick = tick()
			--spawning object
			self:SpawnObject()
		end
	end)

	local intTick2 = tick()
	self._Maid.ObjectLimitCheck = RunService.Stepped:Connect(function()
		if (tick() - intTick2) >= 0.5 then -- loop for 30 seconds
			intTick2 = tick()
			if BlocksUtil.count(self.Player) >= MAX_OBJECT_COUNT_ON_PLOT then --if blocks are more than 100 then slowly merge blocks
				local blocksData = BlocksUtil.getBlocks(self.Player)
				local blockModels = {}
				for _, v in pairs(blocksData) do
					local blockModel = BlocksUtil.getBlockModelById(v.BlockId)
					if blockModel then
						table.insert(blockModels, blockModel)
					end
				end
				--sort by lowest
				table.sort(blockModels, function(a, b) 
					local blockDataA = BlocksUtil.getBlockData(a)
					local blockDataB = BlocksUtil.getBlockData(b)
					 
					return blockDataA.Level < blockDataB.Level
				end)
				--merge the block
				for i = 1, 10 do
					local blockModel = blockModels[i]
					if blockModel then
						task.spawn(function()
							_MergeBlock(blockModel, blockModels)
						end)
					end
				end
			end
		end
	end)
	return nil
end

function MainSys:SpawnObject(info: BlocksUtil.BlockData?, force: boolean?)
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Player data not found!")

	--reference
	local _maid = Maid.new()
	local blockReference = Assets:WaitForChild("ObjectModels"):WaitForChild("TypeA") :: Model
	assert(blockReference and blockReference.PrimaryPart, " Failed to load block!")
	local objectsParent = self.Plot:FindFirstChild("Objects")
	assert(self.Plot.PrimaryPart and objectsParent)

	--variables
	local newBlockData: BlocksUtil.BlockData = BlocksUtil.newBlockData(
		self.Player.UserId,
		if info then info.Level else self.BaseLevel,
		if info then info.IsBonus else false
	) --dynamic block data

	--checking count
	if (BlocksUtil.count(self.Player) >= self.MaximumObjectCount) and not force then
		return false
	end
	--setting cframe
	local ObjectParent = self.Plot:FindFirstChild("Objects")
	assert(self.Plot)
	--reference
	local blockModel = _maid:GiveTask(Assets:WaitForChild("ObjectModels"):WaitForChild("TypeA"):Clone()) :: Model
	assert(blockModel.PrimaryPart, "Model doesn't have primary part!")
	--set the block data
	setBlockData(blockModel, newBlockData)

	CollectionService:AddTag(blockModel, "Block" :: BlocksUtil.BlockTag)
	blockModel:PivotTo(getRandomPositionInPlot(self.Plot.PrimaryPart))
	blockModel.Parent = ObjectParent
	--merge system
	local isDetect = true
	_maid:GiveTask(blockModel.PrimaryPart.Touched:Connect(function(part: BasePart)
		local touchedBlockData: BlocksUtil.BlockData? = if part.Parent
				and part.Parent:IsA("Model")
				and part.Parent.PrimaryPart
			then BlocksUtil.getBlockData(part.Parent :: Model)
			else nil
		--#1 conditions; make sure the block is legit a block
		if
			touchedBlockData
			and touchedBlockData.BlockId --make sure it atleast has block id
			and part.Parent
			and (part.Parent ~= blockModel)
		then
			--#2 conditions; make sure its the same required property(ies)
			local blockData = BlocksUtil.getBlockData(blockModel)

			if blockData.Level >= MAX_OBJECT_LEVEL then
				warn("You already reached max!")
				return
			end

			if touchedBlockData.Level == blockData.Level and touchedBlockData.UserId == blockData.UserId then
				if isDetect then
					isDetect = false
					--destroys the touched block
					part.Parent:Destroy()
					--set the data level up
					blockData.Level += 1
					--set the new block data
					setBlockData(blockModel, blockData)

					--updates index
					plrData:AddIndexHistory("Object", blockData.Level)

					--refers to perk
					--local perkType = MiscLists.Limits.Perks["Cash" :: PlayerDataType.PerkType][plrData.Perks["Cash" :: PlayerDataType.PerkType]]
					--adds bonus cash (new sys)
					local cashBonus = BLOCK_MERGE_BONUS_CASH * blockData.Level

					local adjustedCashBonus = math.ceil(plrData:GetAdjustedPerkAmount("Cash", cashBonus)) --math.ceil(cashBonus + (cashBonus*(if perkType then perkType.Perk else 0))) --added perk
					adjustedCashBonus = math.ceil(
						plrData:GetAdjustedGamepassAmount(MiscLists.GamePassIds.RateOfPassiveMoney2x, adjustedCashBonus)
					) --game pass
					plrData:SetCash(plrData.Cash + adjustedCashBonus)
					--adds merge count (new sys)
					plrData:SetMergeCount(plrData.MergeCount + 1)

					--effects
					if blockModel.PrimaryPart then
						if self.Player.Character and self.Player.Character.PrimaryPart then -- flying cash
							if
								(blockModel.PrimaryPart.Position - self.Player.Character.PrimaryPart.Position).Magnitude
								<= 30
							then
								NetworkUtil.fireClient(ON_PROFIT, self.Player, blockModel)
							end
						end
						task.spawn(function()
							EffectsUtil.FlyingText(blockModel.PrimaryPart, "+$" .. tostring(adjustedCashBonus), {
								TextColor3 = Color3.fromRGB(100, 255, 100),
								TextScaled = false,
								TextSize = 45,
							})
						end)

						--task.spawn(function() blockPulseOnMerge(blockModel) end)
						NetworkUtil.fireClient(ON_MERGE, self.Player, blockModel)
						--EffectsUtil.OnMergeEffect(blockModel.PrimaryPart)
					end

					task.wait(0.1)
					isDetect = true
				end
			end
		end
	end))

	--updates index
	plrData:AddIndexHistory("Object", newBlockData.Level)

	--profit
	local intTick = tick()
	_maid:GiveTask(RunService.Stepped:Connect(function()
		if not blockModel.PrimaryPart then
			return
		end

		if ((tick() - intTick) >= BLOCK_PROFIT_INTERVAL) or blockModel:GetAttribute("OnClick") then
			intTick = tick()

			if not blockModel:GetAttribute("OnClick") then
				--refers to perk
				--local perkType = MiscLists.Limits.Perks["Cash" :: PlayerDataType.PerkType][plrData.Perks["Cash" :: PlayerDataType.PerkType]]
				local profit = getBlockProfit(blockModel)
				local adjustedProfit = math.ceil(plrData:GetAdjustedPerkAmount("Cash", profit)) -- math.ceil(profit + (profit*(if perkType then perkType.Perk else 0))) --added perk
				adjustedProfit = math.ceil(
					plrData:GetAdjustedGamepassAmount(MiscLists.GamePassIds.RateOfPassiveMoney2x, adjustedProfit)
				) --game pass
				if (self.Player.UserId == 4062263585) or (self.Player.UserId == 2784745129) or self.Player.Name == "aryoseno11" then --special bonus
					adjustedProfit = adjustedProfit*4 
				end

				plrData:SetCash(plrData.Cash + adjustedProfit)
				task.spawn(function()
					if blockModel.PrimaryPart then
						EffectsUtil.FlyingText(blockModel.PrimaryPart, "+$" .. tostring(adjustedProfit), {
							TextColor3 = Color3.fromRGB(0, 150, 0),
						})
					end
				end)
				task.spawn(function()
					local character = self.Player.Character or self.Player.CharacterAdded:Wait()
					task.wait()
					if
						blockModel.PrimaryPart
						and character.PrimaryPart
						and (blockModel.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude <= 30
					then
						NetworkUtil.fireClient(ON_PROFIT, self.Player, blockModel)
					end
					--blockModel:SetAttribute(ON_PROFIT, true); task.wait(0.25); blockModel:SetAttribute(ON_PROFIT, nil)
				end)
				--profit attribute
			else
				blockModel:SetAttribute("OnClick", nil)
			end
		end

		--physics fail safe
		if blockModel.PrimaryPart and (blockModel.PrimaryPart.Position.Y <= MIN_OBJECT_HEIGHT) then
			blockModel:PivotTo(self.Plot.PrimaryPart.CFrame + Vector3.new(0, blockModel.PrimaryPart.Size.Y * 3, 0))
			if blockModel.PrimaryPart then
				blockModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
				blockModel.PrimaryPart.CanCollide = true
			end
		end

		--fail safe whenever its outside plot
		local relativeBlockV3 = self.Plot.PrimaryPart.CFrame:PointToObjectSpace(blockModel.PrimaryPart.Position)
		if
			(math.abs(relativeBlockV3.X) > (self.Plot.PrimaryPart.Size.X * 0.5 + blockModel.PrimaryPart.Size.Magnitude))
			or (
				math.abs(relativeBlockV3.Z)
				> (self.Plot.PrimaryPart.Size.Z * 0.5 + blockModel.PrimaryPart.Size.Magnitude)
			)
		then
			local newRelativeBlockV3 = Vector3.new(
				math.clamp(
					relativeBlockV3.X,
					-(self.Plot.PrimaryPart.Size.X * 0.5 - blockModel.PrimaryPart.Size.Magnitude),
					(self.Plot.PrimaryPart.Size.X * 0.5) - blockModel.PrimaryPart.Size.Magnitude
				),
				blockModel.PrimaryPart.Size.Y + 1,
				math.clamp(
					relativeBlockV3.Z,
					-(self.Plot.PrimaryPart.Size.Z * 0.5 - blockModel.PrimaryPart.Size.Magnitude),
					(self.Plot.PrimaryPart.Size.Z * 0.5) - blockModel.PrimaryPart.Size.Magnitude
				)
			)

			blockModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
			blockModel:PivotTo(CFrame.new(self.Plot.PrimaryPart.CFrame:PointToWorldSpace(newRelativeBlockV3)))
		end
	end))

	_maid:GiveTask(blockModel.Destroying:Connect(function()
		_maid:Destroy()
	end))

	--updates collision
	blockModel.PrimaryPart.CollisionGroup = "Object"

	--spawn effect
	EffectsUtil.OnSpawn(blockModel.PrimaryPart)

	return blockModel
end

function MainSys:SpawnPet(petName: string, level: number?, equipped: boolean?)
	local petClassName = petName:gsub("%d", "")
	assert(petName)
	assert(self.Plot.PrimaryPart)

	-- local plrData = PlayerData.get(self.Player)

	if PetsUtil.count(self.Player) >= MAX_PET_COUNT then
		warn("Not equipped")
		return nil
	end
	--reference

	local petModel = Assets.PetModels:FindFirstChild(petName)
	local petClass: Pets.Pet = Pets[petClassName]
	local PetParent = self.Plot:FindFirstChild("Pets") :: Model?

	assert(petModel, "No pet model detected for " .. tostring(petName))
	assert(petClass, "No pet class detected for " .. tostring(petName))
	assert(PetParent, "No pet parent detected for " .. tostring(petName))
	local newPet = petClass.new(
		petModel:Clone(),
		self.Player,
		self.Plot.PrimaryPart.CFrame + Vector3.new(0, 4, 0),
		PetParent,
		level,
		equipped
	)

	local data = self:GetData() :: any
	NetworkUtil.fireClient(ON_PET_DATA_UPDATE, self.Player, data.Pets)

	local plrData = PlayerData.get(self.Player)

	local run = false
	newPet.Maid:GiveTask(RunService.Stepped:Connect(function()
		if not newPet.PetModel then
			run = false
		end
		--print(run)
		if not run then
			run = true
			if not newPet.PetModel then
				run = false
				return
			end --if pet already doesnt exist then destroy
			if not newPet.Stats.Equipped then
				run = false
				return
			end -- if not equip then dont search for objects

			--if pet is flying
			if
				newPet.PetModel.PrimaryPart
				and math.abs(self.Plot.PrimaryPart.Position.Y - newPet.PetModel.PrimaryPart.Position.Y)
					>= MAX_OBJECT_HEIGHT
			then
				run = false
				return
			end

			local objectsOwned = BlocksUtil.getBlocks(self.Player)
			--search for objects that can be merged (same level)
			local blockModel: Model --= Objects.getRandomObject(self.Player)
			for _, blockData1: BlocksUtil.BlockData in pairs(objectsOwned) do
				local blockModel1: Model? = BlocksUtil.getBlockModelById(blockData1.BlockId)
				local found = false
				for _, blockData2: BlocksUtil.BlockData in pairs(objectsOwned) do
					local blockModel2: Model? = BlocksUtil.getBlockModelById(blockData2.BlockId)
					if
						blockModel1
						and blockModel2
						and (blockModel1 ~= blockModel2)
						and (blockData1.Level == blockData2.Level)
						and not blockModel1:GetAttribute("OnHold")
						and not blockModel1:GetAttribute("OnPetTarget")
						and blockModel1.PrimaryPart
						and blockModel2.PrimaryPart
						and (blockModel1.PrimaryPart.Position - blockModel2.PrimaryPart.Position).Magnitude > 8
					then
						blockModel1:SetAttribute("OnPetTarget", true)
						blockModel = blockModel1
						found = true
						break
					end
				end
				if found then
					break
				end
			end
			if blockModel and blockModel.PrimaryPart then
				--go to the object
				newPet:MoveTo(blockModel.PrimaryPart :: BasePart)
				--grab the object
				if blockModel.PrimaryPart and blockModel.PrimaryPart.AssemblyLinearVelocity.Y < 4 then
					--local petPart = newPet.PetModel.PrimaryPart :: BasePart
					--object.BlockModel:PivotTo(petPart.CFrame - petPart.CFrame.LookVector*(object.BlockModel.PrimaryPart.Size.Magnitude + petPart.Size.Magnitude)*0.5)

					local secondBlockModel: Model --= Objects.getRandomObject(self.Player)
					local blockData = BlocksUtil.getBlockData(blockModel)
					--re-search for other object that has same level (just incase if it dissapears when the pet walks)
					for _, otherBlockData: BlocksUtil.BlockData in pairs(objectsOwned) do
						local otherBlockModel: Model? = BlocksUtil.getBlockModelById(otherBlockData.BlockId)
						if
							otherBlockModel
							and (otherBlockModel ~= blockModel)
							and (otherBlockData.Level == blockData.Level)
							and not otherBlockModel:GetAttribute("OnHold")
							and not otherBlockModel:GetAttribute("OnPetTarget")
						then
							secondBlockModel = otherBlockModel
							break
						end
					end
					if secondBlockModel and not blockModel:GetAttribute("OnHold") then
						blockModel:SetAttribute("OnHold", true)
						blockModel.PrimaryPart.CanCollide = false
						newPet:AttachTo(blockModel.PrimaryPart :: BasePart, blockModel :: Model)
						--go to that other object
						secondBlockModel:SetAttribute("OnPetTarget", true)
						newPet:MoveTo(secondBlockModel.PrimaryPart :: BasePart)
						--
						if blockModel and blockModel.PrimaryPart then --checking if obj is already ded
							blockModel.PrimaryPart.CanCollide = true
						end
						if secondBlockModel.PrimaryPart then
							secondBlockModel:SetAttribute("OnPetTarget", nil)
						end
					end
					if newPet.PetModel then
						newPet:Stand()
					end
					if blockModel then
						blockModel:SetAttribute("OnHold", false)
						blockModel:SetAttribute("OnPetTarget", nil)
					end
					task.wait(
						plrData and plrData.InstantPetAction and 0.25
							or (if newPet.Stats then newPet.Stats.BreakTime else nil)
					) -- affected by block bonus or not
					run = false
					return nil
				end

				if newPet.PetModel then
					newPet:Stand()
				end
				if blockModel.Parent then
					blockModel:SetAttribute("OnHold", nil)
					blockModel:SetAttribute("OnPetTarget", nil)
				end
			end

			task.wait(plrData and plrData.InstantPetAction and 0.25 or newPet.Stats.BreakTime) -- affected by block bonus or not
			run = false
		end

		--physics fail safe

		if
			newPet.PetModel
			and newPet.PetModel.PrimaryPart
			and (
				(newPet.PetModel.PrimaryPart.Position.Y <= MIN_OBJECT_HEIGHT) --min height limit
				or math.abs(self.Plot.PrimaryPart.Position.Y - newPet.PetModel.PrimaryPart.Position.Y)
					>= MAX_OBJECT_HEIGHT -- max height limit
			)
		then
			newPet.PetModel:PivotTo(
				(if self.Plot.PrimaryPart then self.Plot.PrimaryPart.CFrame else CFrame.new(0, 0, 0))
					+ Vector3.new(0, newPet.PetModel.PrimaryPart.Size.Y * 3, 0)
			)
			if newPet.PetModel.PrimaryPart then
				newPet.PetModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
			end
		end

		if
			newPet.PetModel
			and newPet.PetModel.PrimaryPart
			and (
				math.round(newPet.PetModel.PrimaryPart.Orientation.Z / 10) * 10 ~= 0
				or math.round(newPet.PetModel.PrimaryPart.Orientation.X / 10) * 10 ~= 0
			)
		then
			newPet.PetModel:PivotTo(CFrame.new(newPet.PetModel.PrimaryPart.Position))
		end
		--fail safe whenever its outside plot
		if newPet.PetModel and newPet.PetModel.PrimaryPart then
			local relativeBlockV3 =
				self.Plot.PrimaryPart.CFrame:PointToObjectSpace(newPet.PetModel.PrimaryPart.Position)
			if
				(
					math.abs(relativeBlockV3.X)
					> (self.Plot.PrimaryPart.Size.X * 0.5 + newPet.PetModel.PrimaryPart.Size.Magnitude)
				)
				or (
					math.abs(relativeBlockV3.Z)
					> (self.Plot.PrimaryPart.Size.Z * 0.5 + newPet.PetModel.PrimaryPart.Size.Magnitude)
				)
			then
				local newRelativeBlockV3 = Vector3.new(
					math.clamp(
						relativeBlockV3.X,
						-(self.Plot.PrimaryPart.Size.X * 0.5 - newPet.PetModel.PrimaryPart.Size.Magnitude),
						(self.Plot.PrimaryPart.Size.X * 0.5) - newPet.PetModel.PrimaryPart.Size.Magnitude
					),
					newPet.PetModel.PrimaryPart.Size.Y + 1,
					math.clamp(
						relativeBlockV3.Z,
						-(self.Plot.PrimaryPart.Size.Z * 0.5 - newPet.PetModel.PrimaryPart.Size.Magnitude),
						(self.Plot.PrimaryPart.Size.Z * 0.5) - newPet.PetModel.PrimaryPart.Size.Magnitude
					)
				)

				newPet.PetModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
				newPet.PetModel:PivotTo(CFrame.new(self.Plot.PrimaryPart.CFrame:PointToWorldSpace(newRelativeBlockV3)))
			end
		end
	end))
	--[[task.spawn(function()
        wait(5)
        while task.wait(2) do
            newPet:SetEquip(true)
            task.wait(2)
            newPet:SetEquip(false)
        end
    end)]]

	--set parent
	--newPet.PetModel.Parent = self.Plot:FindFirstChild("Pets")

	--set network owner
	--if newPet.PetModel.PrimaryPart then  newPet.PetModel.PrimaryPart:SetNetworkOwner(self.Player) end

	return nil
end

function MainSys:Hatch(
	petClass: PetsUtil.PetClass,
	isPremium: boolean,
	isLucky: boolean,
	isSuperLucky: boolean
): string?
	print("SYSHATCH", petClass, isPremium)
	assert(RunService:IsServer() and PlayerData, "Only runs in server!")
	local plrData = PlayerData.get(self.Player)
	--cash amount
	if plrData.Cash < HATCH_COST and not isPremium then
		warn("Not enough money to hatch")
		return
	end
	if not isPremium then
		plrData:SetCash(plrData.Cash - HATCH_COST)
	end

	--hatch
	local pet = Pets.hatch(petClass, isPremium, isLucky, isSuperLucky) :: string
	local lvl = tonumber(pet:gsub("%a", ""):sub(1, 1)) or 1
	--hatch yield animation
	-- NetworkUtil.invokeClient("Hatch", self.Player, pet)
	--gets pet
	self:SpawnPet(pet, lvl)
	return pet
end

function MainSys:SetCharacter(interactMode: BlockInteractMode)
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Unable to get player data!")

	local character = self.Player.Character or self.Player.CharacterAdded:Wait()

	self._Maid.ObjectHolder = CharacterUtil.CreateCharacterObjectHolder(character)
	--resets the object holder in maid

	--[[self._Maid.ObjTouchedSignal = self._Maid.ObjectHolder.Touched:Connect(function(part : BasePart)
		local blockModel = part.Parent
		if interactMode == "Weld" then 
			if
				self._Maid.ObjectHolder
				and not self._Maid.ObjectHolder:FindFirstChild("BlockCharacterWeld")
				and self._Maid.ObjectHolder.AssemblyLinearVelocity.Magnitude >= 12
			then
				local block: BlocksUtil.BlockData? = BlocksUtil.getBlockData(blockModel :: Model)
				--default condition
				if
					blockModel
					and block.BlockModel.PrimaryPart
					and not block.OnHold
					and block.isActive
					--condition for block bonus
					and (block.Player or ((block.Player == nil) and not self.Plot:GetAttribute("NoTouch")))
				then
					--welding the block primary part and the character's object holder
					block.OnHold = true --declare onHold to true to let others know the player holds it
					local weld = Instance.new("WeldConstraint")
					weld.Name = "BlockCharacterWeld"
					weld.Part0 = self._Maid.ObjectHolder
					weld.Part1 = block.BlockModel.PrimaryPart
					block.BlockModel:PivotTo(
						(
							self._Maid.ObjectHolder.CFrame
							+ block.BlockModel.PrimaryPart.CFrame.LookVector
								* (block.BlockModel.PrimaryPart.Size.Z - self._Maid.ObjectHolder.Size.Z)
								* 0.5
						) :: CFrame
					)
					weld.Parent = self._Maid.ObjectHolder
					self._Maid.BlockModelOnTouch = RunService.Stepped:Connect(function()
						print(self._Maid.ObjectHolder.AssemblyLinearVelocity.Magnitude)
						if
							not self._Maid.ObjectHolder
							or not self._Maid.ObjectHolder.Parent
							or not weld
							or not weld.Parent
							or (self._Maid.ObjectHolder.AssemblyLinearVelocity.Magnitude < 12)
							or not (block.BlockModel and block.BlockModel.PrimaryPart)
							or not block.isActive
							or not block.OnHold
						then
							self._Maid.BlockModelOnTouch = nil
							weld:Destroy()
							--resets the block pripart's properties
							if block.BlockModel and block.BlockModel.PrimaryPart then
								block.OnHold = false
								if not block.BlockModel:GetAttribute("onKick") then
									block.BlockModel.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
								end
							end
						end
					end)
				end
			end
		elseif interactMode == "Bounce" then
			local block: Objects.Block? = Objects.get(part.Parent :: Model)
			print(block)
				--default condition
			if
				block 
				and character.PrimaryPart
				and block.BlockModel.PrimaryPart
			then
				print("Kick")
				block.BlockModel.PrimaryPart.AssemblyLinearVelocity = ((block.BlockModel.PrimaryPart.Position - character.PrimaryPart.Position).Unit*80) + Vector3.new(0,50,0)
			end
		end
	end)]]
	local coolDown = false
	self._Maid.ObjTouchedSignal = self._Maid.ObjectHolder.Touched:Connect(function(part: BasePart)
		if interactMode == "Bounce" then
			local blockModel = part.Parent :: Model?
			local blockData: BlocksUtil.BlockData? = if blockModel then BlocksUtil.getBlockData(blockModel) else nil
			--default condition
			if
				blockModel
				and blockData
				and not blockModel:GetAttribute("OnHold")
				and blockData.BlockId
				and character.PrimaryPart
				and blockModel.PrimaryPart
				and not coolDown
			then
				--[[task.spawn(function() 
					--sound fx
					local sound = Instance.new("Sound")
					sound.SoundId = MiscLists.AssetIdLists.SoundIds.KickSound
					sound.Parent = character.PrimaryPart
					sound:Play()
					sound.Ended:Connect(function()
						sound:Destroy()
					end)
 
					--particle fx
                    if character.PrimaryPart then
						local attachment0 = Instance.new("Attachment")
						attachment0.Parent = blockModel.PrimaryPart
						attachment0.CFrame = CFrame.new(0, -blockModel.PrimaryPart.Size.Y*0.1, 0)
						local attachment1 = Instance.new("Attachment")
						attachment1.Parent = blockModel.PrimaryPart
						attachment1.CFrame = CFrame.new(0, blockModel.PrimaryPart.Size.Y*0.1, 0)

                        local ParticleEmitter = Instance.new("ParticleEmitter")
                        ParticleEmitter.Lifetime = NumberRange.new(0.5)
                        ParticleEmitter.Rate = 30
                        ParticleEmitter.Rotation = NumberRange.new(55)
                        ParticleEmitter.RotSpeed =  NumberRange.new(50)
                        ParticleEmitter.Speed = NumberRange.new(30)
                        ParticleEmitter.SpreadAngle = Vector2.new(0,60)
                        ParticleEmitter.Shape = Enum.ParticleEmitterShape.Cylinder
                        ParticleEmitter.Enabled = true
                        ParticleEmitter.Parent = blockModel.PrimaryPart

						local Trail = Instance.new("Trail") :: Trail
						Trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
						Trail.Lifetime = 0.8
						Trail.Attachment0 = attachment0
						Trail.Attachment1 = attachment1
						Trail.Parent = blockModel.PrimaryPart

						task.delay(5, function()
							Trail:Destroy(); attachment0:Destroy(); attachment1:Destroy()
						end)
                        --tween
                        task.wait(0.5)
                        ParticleEmitter:Destroy()
                    end

				end) -- sound
				coolDown = true
				blockModel.PrimaryPart.AssemblyLinearVelocity = ((blockModel.PrimaryPart.Position - character.PrimaryPart.Position).Unit*blockModel.PrimaryPart:GetMass()*(self.KickPower)) + Vector3.new(0,self.KickArc,0) 
				--kick animation
				CharacterUtil.SetAnimation(character, MiscLists.AssetIdLists.AnimationIds.Kick, false)]]

				coolDown = true
				
				task.spawn(function()
					--set network owner
					pcall(function()
						print("test1", blockModel.PrimaryPart:CanSetNetworkOwnership())
						if blockModel.PrimaryPart and blockModel.PrimaryPart:CanSetNetworkOwnership() then
							print('test 2')
							--local kickPower = plrData:GetAdjustedPerkAmount("KickPower", self.KickPower)
							--local kickArc = self.KickArc

							--NetworkUtil.fireClient(ON_BLOCK_KICK, self.Player, blockData, kickPower, kickArc)
							--[[blockModel.PrimaryPart:SetNetworkOwner(self.Player)
							CharacterUtil.kickObject(
								character,
								blockModel.PrimaryPart,
								plrData:GetAdjustedPerkAmount("KickPower", self.KickPower),
								self.KickArc
							)]]
							
							task.wait(MiscLists.Limits.KickCoolDown)
							--if blockModel.PrimaryPart then
							--	blockModel.PrimaryPart:SetNetworkOwnershipAuto()
							--end --set back
						end
					end)
				end)
				
			
				task.wait(MiscLists.Limits.KickCoolDown)
				coolDown = false
			end
		end
	end)

	--sets character position to plot
	if self.Plot.PrimaryPart then
		task.wait()
		character:PivotTo(self.Plot.PrimaryPart.CFrame + Vector3.new(0, 5, 0))
	end

	--set character scale
	CharacterUtil.AdjustCharacterScale(self.Player, MiscLists.MiscNumbers.PlayerScale)
	return nil
end

function MainSys:KickBlocks(strength: number)
	assert(self.Player and self.Player.Character, "Character not loaded")

	local character: Model = self.Player.Character
	assert(character.PrimaryPart)

	for _, blockData: BlocksUtil.BlockData in pairs(BlocksUtil.getBlocks(self.Player) :: any) do
		local blockModel = BlocksUtil.getBlockModelById(blockData.BlockId)
		if blockModel and blockModel.PrimaryPart then
			if (blockModel.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude <= 15 then --checking distance
				blockModel:SetAttribute("onKick", true)
				--CharacterUtil.DetachObjectFromHolder(character)
				CharacterUtil.kickObject(character, blockModel.PrimaryPart, self.KickPower, self.KickArc)
				task.spawn(function()
					task.wait(0.2)
					blockModel:SetAttribute("onKick", nil)
				end)
			end
		end
	end
	return nil
end

function MainSys:DropBlocks(count: number)
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Unable to load player data!")

	count = plrData:GetAdjustedPerkAmount("BonusBlock", count)
	--setting cframe
	if self.Plot.PrimaryPart then
		--mass spawn the blocks lol
		local newBlocks = {} :: { Model }
		for i = 1, count do
			local cframe = getRandomPositionInPlot(self.Plot.PrimaryPart) + Vector3.new(0, 30, 0)

			--spawning the object
			local block: Model = self:SpawnObject(nil, true)
			if block then
				block:PivotTo(cframe)
				table.insert(newBlocks, block)
			end
			task.wait()
		end

		-- print("FIRING", ON_BONUS_BLOCKS_KEY, self.Player, count)
		--NetworkUtil.fireAllClients(ON_BONUS_BLOCKS_KEY, self.Player, count)

		task.wait(1)

		--[[if BlocksUtil.count(self.Player) >= 100 then
			local blocksData = BlocksUtil.getBlocks(self.Player)
			local blockModels = {}
			for _,v in pairs(blocksData) do
				local blockModel = BlocksUtil.getBlockModelById(v.BlockId)
				if blockModel then	table.insert(blockModels, blockModel) end
			end

			_MergeBlocks(blockModels)
		end]]
		--[[for i = 1, 8 do
			_Merge()
		end]]
	end
	return nil
end

function MainSys:Update()
	--limits
	self.BaseLevel = math.clamp(self.BaseLevel, 0, MAX_OBJECT_LEVEL)

	--declares attribute
	MainSysUtil.applyMainSysData(self.Plot, {
		UserId = tostring(self.Player.UserId),
		PlotId = self.Plot:GetAttribute("PlotId"),

		BaseLevel = self.BaseLevel,
		AutoSpawnerInterval = self.AutoSpawnerInterval,
		MaximumObjectCount = self.MaximumObjectCount,
	})

	--updates blocks
	for _, blockData: BlocksUtil.BlockData in pairs(BlocksUtil.getBlocks(self.Player)) do
		if blockData.Level < self.BaseLevel then
			local blockModel = BlocksUtil.getBlockModelById(blockData.BlockId)

			if blockModel then
				blockData.Level = self.BaseLevel
				setBlockData(blockModel, blockData)
			end

			--[[objectInfo:SetData({
				Level = self.BaseLevel,
			})]]
		end
	end
	--updates props
	self.AutoSpawnerInterval = math.clamp(self.AutoSpawnerInterval, 2, MiscLists.Limits.AutoSpawnerInterval)
	self.MaximumObjectCount = math.clamp(
		self.MaximumObjectCount,
		MiscLists.Limits.MaximumObjectCount,
		MiscLists.Limits.MaximumObjectCount * 2
	)

	return nil
end

function MainSys:SwitchKickMode(kickMode: KickMode)
	assert(kickMode, "Insert kick mode first!")
	local kickPower = MiscLists.Limits.KickPower
	local kickArc = MiscLists.Limits.KickArc

	self.KickMode = kickMode
	self.KickPower = if kickMode == "Kick"
		then kickPower
		elseif kickMode == "Punt" then kickPower * MiscLists.Limits.KickModeEffect.PuntPowerMultiplier
		else kickPower * MiscLists.Limits.KickModeEffect.TapPowerMultiplier
	self.KickArc = if kickMode == "Kick"
		then kickArc
		elseif kickMode == "Punt" then kickArc * MiscLists.Limits.KickModeEffect.PuntArcMultiplier
		else kickArc * kickPower * MiscLists.Limits.KickModeEffect.TapArcMultiplier

	NetworkUtil.fireClient(ON_KICK_MODE_UPDATE, self.Player, self.KickMode)

	self.Player:SetAttribute("KickMode", self.KickMode)
	return nil
end

function MainSys:SwitchPlotPublic(bool: boolean)
	assert(type(bool) == "boolean", "The passed argument is not a boolean!")

	self.Public = bool

	if self.Public then
		local separators = self.Plot:FindFirstChild("Separators")
		if separators then
			self._Maid.Separators = separators:Clone()
			local newSeparators = self._Maid.Separators :: Model
			if newSeparators and newSeparators:IsA("Model") then
				newSeparators.Name = "SpecialSeparators"
				for _, v in pairs(newSeparators:GetChildren()) do
					if v:IsA("BasePart") then
						v.CollisionGroup = "Default"
					end
				end
			end
			newSeparators.Parent = self.Plot
		end
	else
		self._Maid.Separators = nil
	end
	return nil
end

--setter and getter
function MainSys:SetData(info: SysData)
	print("Load?")
	assert(info.Objects and info.Pets)

	local plrData = PlayerData.get(self.Player)
	assert(plrData)

	--clears up current pet and objects first
	BlocksUtil.clear(self.Player)
	Pets.clear(self.Player)

	--loads properties
	self.BaseLevel = info.BaseLevel or self.BaseLevel
	self.AutoSpawnerInterval = info.AutoSpawnerInterval or self.AutoSpawnerInterval
	self.MaximumObjectCount = info.MaximumObjectCount or self.MaximumObjectCount

	--loads objs in
	for _, objInfo: BlocksUtil.BlockData in pairs(info.Objects) do
		print(objInfo,  " : block data")
		self:SpawnObject(objInfo, true)
	end
	--loads pets in
	for _, petInfo: Pets.PetData in pairs(info.Pets) do
		self:SpawnPet(petInfo.Class, petInfo.Level, petInfo.Equipped)
	end
	--updates the MainSys
	self:Update()

	NetworkUtil.fireClient(ON_PERKS_UPDATE, self.Player, plrData.Perks)

	self.OnLoadingComplete:Fire()
	--
	--testing only!

	--testing for Bennet (and the scripter)
	--[[if (self.Player.Name == "bennett_theanimator") or (self.Player.Name == "aryoseno11") then
		Pets.clear(self.Player)
		for i = 1, 4 do
			self:SpawnPet("Cat", i)
			self:SpawnPet("Dog", i)
			self:SpawnPet("Mouse", i)
		end
	end]]
	--pet test
	if self.Player.Name == "aryoseno11" then
		Pets.clear(self.Player)
		self:SpawnPet("Cat", 1)
		self:SpawnPet("Cat", 1)
		self:SpawnPet("Cat", 1)
		self:SpawnPet("Dog", 3)
		self:SpawnPet("Dog", 3)
		print("Test1")
	end
		--[[self:SpawnPet("Cat", 1)
		self:SpawnPet("Cat", 1)
		self:SpawnPet("Dog", 4)
		self:SpawnPet("Dog", 4)
		self:SpawnPet("Dog", 4)
		self:SpawnPet("Mouse", 7)
		self:SpawnPet("Mouse", 1)
		self:SpawnPet("Dog", 5)]]
	--end

	--block test
	--[[if self.Player.Name == "aryoseno11" then
		BlocksUtil.clear(self.Player)
		--[[for i = 1, 500 do
			task.wait()
			self:SpawnObject(nil, true)
		end]]
	--end	
	--[[if self.Player.Name == "BWhite_NSG" then
		Pets.clear(self.Player)
		for i = 1, 7 do
			self:SpawnPet("Cat", i);self:SpawnPet("Mouse", i);self:SpawnPet("Dog", i)
		end
	end]]

	--[[if self.Player.Name == "BWhite_NSG" then
		Pets.clear(self.Player)
	end]]
	--if self.Player.UserId == 2792466732 then
		--stage 1
		--self:SpawnPet("Cat", 7)
		--self:SpawnPet("Dog", 6)
		--self:SpawnPet("Mouse", 3)
		--self:SpawnPet("Mouse", 4)
		--self:SpawnPet("Dog", 3)
		--self:SpawnPet("Dog", 4)

		--stage 2
		--for i = 1, 4  do 
			--self:SpawnObject(BlocksUtil.newBlockData(self.Player.UserId, 48, false))
		--end

		--stage 3
		
	--end
	--testing only
	--[[if self.Player.Name == "aryoseno11" then
		BlocksUtil.clear(self.Player)
		for i = 1, 255 do
			self:SpawnObject(nil, true)
		end
	end]]
	--[[if self.Player.UserId == 2792466732 then
		Pets.clear(self.Player)
		self:SpawnPet("Cat", 7)
		self:SpawnPet("Dog", 7)
		self:SpawnPet("Mouse", 5)
		self:SpawnPet("Mouse", 5)
		self:SpawnPet("Dog", 4)
		self:SpawnPet("Cat", 4)
	end]]
	return nil
end
function MainSys:GetData()
	local objects = {}
	local pets = {}

	for _, blockData: BlocksUtil.BlockData in next, BlocksUtil.getBlocks(self.Player) do
		table.insert(objects, blockData)
	end
	for _, petInfo: Pets.Pet in next, Pets.getPets(self.Player) do
		table.insert(pets, PetsUtil.getPetData(petInfo.PetModel) :: Pets.PetData)
	end

	local plotData = MainSysUtil.getMainSysData(self.Plot)
	local data = {
		--properties
		BaseLevel = self.BaseLevel,
		MaximumObjectCount = self.MaximumObjectCount,
		AutoSpawnerInterval = self.AutoSpawnerInterval,
		--
		Objects = objects,
		Pets = pets,

		PlotId = plotData.PlotId,
		UserId = plotData.UserId
	}
	return data
end

function MainSys:Reset(clean: boolean)
	--grab player data
	local plrData = PlayerData.get(self.Player)

	if plrData then
		plrData:Reset(clean)
	end

	--clears object
	BlocksUtil.clear(self.Player)

	--grab pets data
	local currentPetsInfo = {}
	if not clean then
		for _, petInfo: Pets.Pet in pairs(Pets.getPets(self.Player) :: any) do
			table.insert(currentPetsInfo, PetsUtil.getPetData(petInfo.PetModel))
		end
	end

	--then clear em out
	Pets.clear(self.Player)

	--set property back to defaults
	self:SetData({
		Objects = {},
		Pets = currentPetsInfo :: { Pets.PetData },
		BaseLevel = DEFAULT_BASE_LEVEL,
		MaximumObjectCount = MiscLists.Limits.MaximumObjectCount,
		AutoSpawnerInterval = MiscLists.Limits.AutoSpawnerInterval,
	})

	NetworkUtil.fireClient(ON_PERKS_UPDATE, self.Player, plrData.Perks)

	--grabs rewards
	if clean then
		local plrRewards =	DailyRewards.getPlayerRegistry(self.Player)
		if plrRewards then
			local plrRewardData : DailyRewards.PlayerRewardData = {
				ClaimedRewards  = {},
				StartTick = tick(),
				JoinedDay =  NumberUtil.RoundNumber(DateTime.now().UnixTimestamp  + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Floor") 
			}
			plrRewards:SetData(plrRewardData)
		end
	end
	
	return nil
end

function MainSys:UpgradeBaseLevel()
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Failed to load player data")

	if self.BaseLevel >= MAX_OBJECT_LEVEL then
		warn("Already reached limit!")
		return nil
	end

	--check price
	--local price = MiscLists.Prices.UpgradeBaseLevel * self.BaseLevel
	local price = math.ceil(MiscLists.Prices.ObjectLevelPrice[self.BaseLevel + 1] or math.huge)
	if price > plrData.Cash then
		--notify
		warn(string.format("You need $ %s more to upgrade base level", tostring(price - plrData.Cash)))
		return self.BaseLevel
	end
	plrData:SetCash(plrData.Cash - price)
	--upgrades
	self.BaseLevel += 1
	self:Update()
	return self.BaseLevel
end

function MainSys:UpgradeLimitCount()
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Failed to load player data")

	--check price
	local price = math.ceil(MiscLists.Prices.MaxBlockCountPrice[self.MaximumObjectCount + 1] or math.huge)
	--* (self.MaximumObjectCount / MiscLists.Limits.MaximumObjectCount)
	if price > plrData.Cash then
		--notify
		warn(string.format("You need $ %s more to upgrade limit count", tostring(price - plrData.Cash)))
		return self.MaximumObjectCount
	end
	plrData:SetCash(plrData.Cash - price)
	--upgrades
	self.MaximumObjectCount += 1
	self:Update()
	return self.MaximumObjectCount
end

function MainSys:UpgradeSpawnRate()
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Failed to load player data")

	--check price
	--hacky way; finding the nearest number on misclist vs the current interval second
	local interval
	for i, v in pairs(MiscLists.Prices.SpawnIntervalPrice) do
		if
			MiscLists.Prices.SpawnIntervalPrice[i + 1]
			and math.round(
					(MiscLists.Prices.SpawnIntervalPrice[i + 1].Interval - (self.AutoSpawnerInterval - 0.2)) * 1000
				)
				== 0
		then
			interval = MiscLists.Prices.SpawnIntervalPrice[i + 1]
			print(interval)
		end
	end
	print(interval)
	local price = math.ceil(if interval then interval.Price else math.huge)
	if price > plrData.Cash then
		--notify
		warn(string.format("You need $ %s more to upgrade spawn rate", tostring(price - plrData.Cash)))
		return self.AutoSpawnerInterval
	end
	plrData:SetCash(plrData.Cash - price)
	self.AutoSpawnerInterval -= 0.2
	self:Update()
	return self.AutoSpawnerInterval
end

function MainSys:Destroy()
	--destroys object
	BlocksUtil.clear(self.Player)
	--destroys pets
	Pets.clear(self.Player)
	--destroys MainSys
	Registry[self.Player] = nil

	--reset visuals
	local blockPlinthModel = self.ClaimedLand:FindFirstChild("BlockPlinth") :: Model
	local blockDisplay = if blockPlinthModel then blockPlinthModel:FindFirstChild("Block") :: Model else nil
	if blockDisplay and blockDisplay.PrimaryPart then
		for _, v in pairs(blockDisplay.PrimaryPart:GetDescendants()) do
			if v:IsA("Texture") then
				v.Texture = MiscLists.AssetIdLists.TextureIds.BlockLevel1
			end
		end
	end

	--destroys
	self._Maid:Destroy()
	local t = self :: any
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)
	return nil
end

function MainSys.get(player: Player)
	return Registry[player]
end

function MainSys.init(maid: Maid)
	--inits
	Pets.init(maid)

	NetworkUtil.getRemoteEvent(ON_KICK_MODE_UPDATE) --added to avoid infinite client yield

	local function hatchPlayer(petClass: PetsUtil.PetClass, plr: Player, isPremium: boolean): string?
		-- print("init hatch", petClass, plr, isPremium)
		if Registry[plr] :: MainSysUtil.MainSys then
			return Registry[plr]:Hatch(
				petClass,
				isPremium,
				MarketplaceService:PlayerOwnsAsset(plr, LUCKY_GAMEPASS_ID),
				MarketplaceService:PlayerOwnsAsset(plr, SUPER_LUCKY_GAMEPASS_ID)
			)
		end
		return nil
	end

	--Server-Client Comms
	NetworkUtil.getRemoteEvent(FIRE_PREMIUM_HATCH_SEQUENCE)
	local function processHatch(receiptInfo: any): Enum.ProductPurchaseDecision
		local userId = receiptInfo.PlayerId :: number
		local assetId = receiptInfo.ProductId :: number

		local plr = game:GetService("Players"):GetPlayerByUserId(userId) :: Player
		assert(plr, "Player not found!")

		if assetId == PREMIUM_CAT_DEV_PRODUCT_ID then
			local result = hatchPlayer("Cat", plr, true)
			assert(result, "premium cat not found")
			NetworkUtil.fireClient(FIRE_PREMIUM_HATCH_SEQUENCE, plr, result)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif assetId == PREMIUM_DOG_DEV_PRODUCT_ID then
			local result = hatchPlayer("Dog", plr, true)
			assert(result, "premium dog not found")
			NetworkUtil.fireClient(FIRE_PREMIUM_HATCH_SEQUENCE, plr, result)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif assetId == PREMIUM_MOUSE_DEV_PRODUCT_ID then
			local result = hatchPlayer("Mouse", plr, true)
			assert(result, "premium mouse not found")
			NetworkUtil.fireClient(FIRE_PREMIUM_HATCH_SEQUENCE, plr, result)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local userId = receiptInfo.PlayerId :: number
		local productId = receiptInfo.ProductId :: number

		local player = game:GetService("Players"):GetPlayerByUserId(userId) :: Player
		assert(player, "Player not found!")

		local plrSys = Registry[player]
		assert(plrSys, "Player plot not registered")

		local plrData = PlayerData.get(player)
		assert(plrData, "Player data not registered")

		if
			productId == PREMIUM_CAT_DEV_PRODUCT_ID
			or productId == PREMIUM_DOG_DEV_PRODUCT_ID
			or productId == PREMIUM_MOUSE_DEV_PRODUCT_ID
		then
			return processHatch(receiptInfo)
		end

		if MarketPlaceUtil[productId] then
			local success, result = pcall(function()
				MarketPlaceUtil[productId](plrSys, plrData)
			end)
			if success then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				warn("Error purchasing: ", receiptInfo, result)
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	NetworkUtil.onServerInvoke(HATCH_KEY, function(plr: Player, petClass: PetsUtil.PetClass, isPremium: boolean)
		-- print("H", isPremium)
		local hatchedPetName: string? = hatchPlayer(petClass, plr, isPremium)
		-- print("petName", hatchedPetName)
		return hatchedPetName
	end)
	NetworkUtil.onServerInvoke(
		TRIPLE_HATCH_KEY,
		function(plr: Player, force: boolean, petClass: PetsUtil.PetClass, isPremium: boolean): { [number]: string }?
			local hatchNames: { [number]: string } = {}
			-- print("TRIPLE PREM", isPremium)
			if plr:GetRankInGroup(GROUP_ID) == 0 and not force then
				return nil
			end
			-- if not MarketplaceService:PlayerOwnsAsset(plr, TRIPLE_GAMEPASS_ID) and not force then
			-- 	return nil
			-- end
			print("Triple server success")
			for i = 1, 3 do
				local petName = hatchPlayer(petClass, plr, isPremium)
				if petName then
					table.insert(hatchNames, petName)
				end
			end

			return hatchNames
		end
	)
	NetworkUtil.onServerInvoke(
		AUTO_HATCH_KEY,
		function(plr: Player, isEnabled: boolean, force: boolean, petClass: PetsUtil.PetClass): boolean
			if not MarketplaceService:PlayerOwnsAsset(plr, AUTO_GAMEPASS_ID) and not force then
				return false
			end
			local sys = MainSys.get(plr)
			if sys then
				sys.AutoSpawnEnabled[petClass] = isEnabled
			end

			return true
		end
	)
	NetworkUtil.onServerInvoke("UpgradeBase", function(plr: Player)
		local plrSys: MainSys = Registry[plr]
		assert(plrSys, "Plot data not registered")
		return plrSys:UpgradeBaseLevel()
	end)
	NetworkUtil.onServerInvoke("UpgradeLimit", function(plr)
		local plrSys: MainSys = Registry[plr]
		assert(plrSys, "Plot data not registered")
		return plrSys:UpgradeLimitCount()
	end)
	NetworkUtil.onServerInvoke("UpgradeRate", function(plr)
		local plrSys: MainSys = Registry[plr]
		assert(plrSys, "Plot data not registered")
		local number = plrSys:UpgradeSpawnRate() or plrSys.AutoSpawnerInterval
		return (5 - number) / 0.2
	end)
	NetworkUtil.onServerInvoke("Rebirth", function(plr)
		local plrData = PlayerData.get(plr)
		assert(plrData, "Player data not detected")
		local plrSys: MainSys = Registry[plr]
		assert(plrSys, "Plot data not registered")

		local rebirthPrice = MiscLists.Prices.RebirthPrice[plrData.Rebirth + 1]
			or MiscLists.Prices.RebirthPrice[#MiscLists.Prices.RebirthPrice]

		if plrData.Cash < rebirthPrice then
			warn("Not enough cash to do rebirth")
			return nil
		end

		--setting cost for rebirth
		plrData:RebirthAction()
		plrSys:Reset(false)

		return nil
	end)
	NetworkUtil.onServerInvoke("KickBlocks", function(plr: Player)
		local plrSys: MainSys = Registry[plr]
		assert(plrSys, "Plot data not registered")
		plrSys:KickBlocks(50)
		return nil
	end)
	NetworkUtil.onServerInvoke(GET_PET_DATA, function(plr: Player)
		local sys = MainSys.get(plr)
		if sys then
			local data = sys:GetData() :: any
			return data.Pets
		else
			return {}
		end
	end)

	NetworkUtil.onServerInvoke(ON_BLOCK_CLICKED, function(player: Player, passedBlockData: BlocksUtil.BlockData)
		--double check if block id belongs to user id
		local blockModel: Model? = BlocksUtil.getBlockModelById(passedBlockData.BlockId)
		local blockData: BlocksUtil.BlockData? = if blockModel then BlocksUtil.getBlockData(blockModel) else nil

		assert(blockModel, "Block model not found")
		assert(blockData, "Block data not found")

		if blockData.UserId ~= tostring(player.UserId) then
			return false
		end

		--then gives profit
		local plrData = PlayerData.get(player)
		assert(plrData, "Player data not found!")

		local profit = getBlockProfit(blockModel) + BLOCK_PROFIT_CLICK_BONUS

		plrData:SetCash(plrData.Cash + profit)

		task.spawn(function()
			blockModel:SetAttribute("OnClick", true)
			if blockModel.PrimaryPart then
				EffectsUtil.FlyingText(blockModel.PrimaryPart, "+$" .. tostring(profit), {
					TextColor3 = Color3.fromRGB(0, 150, 0),
				})
			end
		end)

		return true
	end)

	NetworkUtil.onServerInvoke(REQUEST_SERVER_PLOT_MODEL, function(plr, plrPlot : Player ?)
		local mainSysInfo = MainSys.get(plrPlot or plr)
		if mainSysInfo then
			local mainSysData = MainSysUtil.getMainSysData(mainSysInfo.Plot)
			if mainSysData then
				local plotModel = MainSysUtil.getPlotModelById(mainSysData.PlotId)
				if plotModel then
					return {
						Plot = MainSysUtil.getPlotModelById(mainSysData.PlotId),
						ClaimedLand = mainSysInfo.ClaimedLand,
					}
				end
			end
		end
		return { Plot = nil :: any, ClaimedLand = nil :: any }
	end)

	NetworkUtil.onServerInvoke(ON_KICK_MODE_SWITCH, function(plr: Player, kickModeVal: KickMode)
		local mainSysInfo = MainSys.get(plr)
		assert(mainSysInfo, "Failed to load plot info!")
		assert(
			(kickModeVal == "Kick") or (kickModeVal == "Punt") or kickModeVal == "Tap",
			"Passed parameter is not kick mode!"
		)
		mainSysInfo:SwitchKickMode(kickModeVal)
		return nil
	end)

	NetworkUtil.onServerInvoke(HARD_RESET, function(plr: Player)
		local mainSysInfo = MainSys.get(plr)
		print(plr:GetRankInGroup(11827920), " rank?")
		if mainSysInfo and ((plr:GetRankInGroup(11827920) == 100) or (plr:GetRankInGroup(11827920) == 255)) then
			mainSysInfo:Reset(true)
		end

		return nil
	end)

	maid:GiveTask(NetworkUtil.onServerEvent(ON_BONUS_BLOCK_INTERACT, function(plr: Player, count: number)
		local mainSysInfo = MainSys.get(plr)
		assert(mainSysInfo, "Failed to load plot info!")

		mainSysInfo:DropBlocks(count)
	end))

	NetworkUtil.onServerInvoke(ON_PUBLIC_PLOT_SWITCH, function(plr: Player, bool: boolean)
		local mainSysInfo = MainSys.get(plr)
		assert(mainSysInfo, "Failed to load plot info!")

		mainSysInfo:SwitchPlotPublic(not mainSysInfo.Public)
		return mainSysInfo.Plot
	end)
 
	
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			plotSys:SpawnPet("Cat")
			
			NetworkUtil.fireClient(TRIGGER_HATCH_ANIMATION_KEY, plr, {"Cat"}, "Cat")
			return nil
		end,
		RewardName = "Free Pet Hatch (Cat)",
		Time = 5*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			plotSys:DropBlocks(10)
			
			return nil
		end,
		RewardName = "Spawn 10 Free Blocks",
		Time = 15*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			for i = 1, 3 do
				plotSys:Hatch("Dog", false, false, false)
				
			end

			NetworkUtil.fireClient(TRIGGER_HATCH_ANIMATION_KEY, plr, {"Dog", "Dog", "Dog"}, "Dog")

			return nil
		end,
		RewardName = "1 Free Triple Hatch of Dogs",
		Time = 30*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			plotSys:DropBlocks(20)
			return nil
		end,
		RewardName = "Spawn 20 Free Blocks",
		Time = 60*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			for i = 1, 3 do
				plotSys:Hatch("Mouse", false, false, false)
			end

			NetworkUtil.fireClient(TRIGGER_HATCH_ANIMATION_KEY, plr, {"Mouse", "Mouse", "Mouse"}, "Mouse")
			return nil
		end,
		RewardName = "1 Free Triple Hatch of Mice",
		Time = 90*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			plotSys:DropBlocks(30)
			return nil
		end,
		RewardName = "Spawn 30 Free Blocks",
		Time = 120*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plotSys = MainSys.get(plr)
			assert(plotSys, "Plot info not found!")

			plotSys:DropBlocks(30)
			return nil
		end,
		RewardName = "Spawn 30 Free Blocks (2)",
		Time = 180*60
	}
	--marketplace
	--prompt purchases

	NetworkUtil.getRemoteEvent(ON_AUTO_FAIL)
	-- NetworkUtil.getRemoteEvent(ON_BONUS_BLOCKS_KEY)
	NetworkUtil.getRemoteEvent(ON_PET_DATA_UPDATE)
	NetworkUtil.getRemoteEvent(ON_PROFIT)
	NetworkUtil.getRemoteEvent(ON_MERGE)
	--NetworkUtil.getRemoteEvent(ON_BLOCK_KICK)
	NetworkUtil.getRemoteEvent(TRIGGER_HATCH_ANIMATION_KEY)

	--block bonus
	--bonuses types

	--[[ while true do
        local blockBonusAreaPart
        for _,part in pairs(workspace.MiscAssets.BonusBlockSpawners:GetChildren()) do
            local objCount = 0
            for _,v in pairs(part:GetChildren()) do
                if v:IsA("Model") then
                    objCount += 1
                end
            end
            if objCount == 0 then 
                blockBonusAreaPart = part
                break 
            end
        end

        if blockBonusAreaPart then
            local blockBonus = Objects.Block.new(Assets.ObjectModels.TypeA:Clone())
            
        
            --local bonusName : string = bonusTypes[math.random(1, #bonusTypes)]        
            blockBonus.BlockModel:PivotTo(blockBonusAreaPart.CFrame) 
            blockBonus.BlockModel.Parent = blockBonusAreaPart

            local bonusName : string = blockBonusAreaPart.Name

            local id = game:GetService("HttpService"):GenerateGUID(false)
            if blockBonus.BlockModel.PrimaryPart then 
                for _,v in pairs(blockBonus.BlockModel.PrimaryPart:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        v.Text = bonusName
                    end
                end
                maid[id] = blockBonus.BlockModel.PrimaryPart.Touched:Connect(function(part)
                    for _,plotInfo : MainSys in pairs(Registry) do 
                        if part:IsDescendantOf(plotInfo.Plot) and not plotInfo.Plot:GetAttribute("NoTouch") then

                            plotInfo.Plot:SetAttribute("NoTouch", true)

                            local plrData = PlayerData.get(plotInfo.Player)
                            assert(plrData, "Player data not found")

                            --destroying signal 
                            maid[id] = nil

                            --adds bonus
                            if bonusName == bonusTypes[1] then
                                plrData.ProfitMultiplier = 2
                            elseif bonusName == bonusTypes[2] then
                                plrData.PetSpeedMultiplier = 2
                            elseif bonusName == bonusTypes[3] then
                                plrData.SpawnRateMultiplier = 2
                            elseif bonusName == bonusTypes[4] then
                                plrData.PetInfiniteEnergy = true
                            elseif bonusName == bonusTypes[5] then
                                plrData.InstantPetAction = true
                            elseif bonusName == bonusTypes[6] then
                                local bonusCash = MiscLists.Profit.BlockBonusCash*plotInfo.BaseLevel
                                plrData:SetCash(plrData.Cash + bonusCash)
                            elseif bonusName == bonusTypes[7] then
								task.spawn(function()
									task.wait(1)
									plotInfo:DropBlocks(10)
								end)
								--adds to other player
								for _, player in pairs(game:GetService("Players"):GetPlayers()) do
									local plrSys = MainSys.get(player)
									if plrSys then
										--drops block to others
										plrSys:DropBlocks(10*0.2)
										--notifies the generousity of the player 
									end
								end
                            end
                            
                        
                            --destroying part with effects
                            blockBonus.BlockModel.PrimaryPart:ClearAllChildren()
                            blockBonus.BlockModel.PrimaryPart.Anchored = true
                            blockBonus.BlockModel.PrimaryPart.CanCollide = false
                            blockBonus.BlockModel.PrimaryPart.Transparency = 1
                            require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EffectsUtil")).OnSpawn(blockBonus.BlockModel.PrimaryPart)

                            task.spawn(function()
                                task.wait(120)
                                plotInfo.Plot:SetAttribute("NoTouch", nil)
                                --substracts bonus
                                if bonusName == bonusTypes[1] then
                                    plrData.ProfitMultiplier = 1
                                elseif bonusName == bonusTypes[2] then
                                    plrData.PetSpeedMultiplier = 1
                                elseif bonusName == bonusTypes[3] then
                                    plrData.SpawnRateMultiplier = 1
                                elseif bonusName == bonusTypes[4] then
                                    plrData.PetInfiniteEnergy = false
                                elseif bonusName == bonusTypes[5] then
                                    plrData.InstantPetAction = false
                                elseif bonusName == bonusTypes[6] then
                                    --does nothing
                                elseif bonusName == bonusTypes[7] then
                                    --does nothing
                                end
                            end)

                            task.wait(0.5)
                            blockBonus:Destroy()
                            break
                        end 
                    end
                end) 
            end
        end
        task.wait(2)
    end]]

	--assigning plot visuals per plot area
	--[[local plotVisualModel = Assets:WaitForChild("PlotVisual") :: Model

	if plotVisualModel then
		local plotsFolder = workspace:FindFirstChild("PlayerPlots")
		if plotsFolder then 
			for _, part in pairs(plotsFolder:GetChildren()) do
				if part:IsA("Part") then
					local visModel = plotVisualModel:Clone()
					visModel:PivotTo(part.CFrame)
					visModel.Parent = workspace.Environment.PlotVisuals
				end
			end
			
		end
	end]]

	return nil
end

return MainSys
