--!strict
--REFERENCES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))

--Module
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local PlayerDataType = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local LeaderboardDataManager =
	require(ServerScriptService:WaitForChild("Server"):WaitForChild("LeaderboardDataManager"))
local RebirthUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RebirthUtil"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))

--Types
type Maid = Maid.Maid
export type PlayerDataType = PlayerDataType.PlayerDataType
export type PlayerData = PlayerDataType.PlayerData

--constants
local ON_OBJECT_INDEX_UPDATE = "OnObjectIndexUpdate" -- TO BE MERGED WITH OBJECT AND PET INDEX UPDATE
local ON_PET_INDEX_UPDATE = "OnPetIndexUpdate"
local ON_OBJECT_INDEX_ACHIEVEMENT = "OnObjectIndexAchievement"
local ON_PERKS_UPDATE = "OnPerksUpdate"
local GET_INDEX = "GetIndex"
local GET_PERKS = "GetPerks"
local ON_TUTORIAL_TRIGGER = "OnTutorialTrigger"

local ON_PERK_ADDED = "OnPerkAdded"

local ON_GUI_PROFIT = "OnGuiProfit"

--variables
local Registry = {}

--references

--local function
local function _getHighestBlock(Player: Player): number --grabs the existing highest level on the player's plot
	local currentBlocksLevel = { 0 }
	local blocksData = BlocksUtil.getBlocks(Player)
	for _, v in pairs(blocksData) do
		table.insert(currentBlocksLevel, v.Level)
	end
	return math.max(unpack(currentBlocksLevel))
end

--class
local PlayerData = {} :: PlayerData
PlayerData.__index = PlayerData

function PlayerData.new(player: Player): PlayerData
	local self: PlayerData = setmetatable({
		--Player Data
		Player = player :: Player,
		Cash = 0 :: number, -- a primary currency obtained by merging objects
		Gems = 10 :: number,
		Energy = 0 :: number, -- a secondary currency obtained upon removing pets added by their remaining energy
		Rebirth = 0 :: number, -- future rebirth system
		MergeCount = 0 :: number,

		--index (?)
		DiscoveredPets = {},
		DiscoveredBlockLevels = {},

		--block bonuses
		ProfitMultiplier = 1 :: number, -- gamepass object profit multiplier
		GemsProfitMultiplier = 1 :: number,
		PetSpeedMultiplier = 1 :: number,
		SpawnRateMultiplier = 1 :: number, -- gamepass to add block interval multiplier
		PetInfiniteEnergy = false :: boolean,
		InstantPetAction = false :: boolean,

		RarityMultiplier = 0 :: number, -- gamepas to increase chance of geting rarer pets
		AutoClicker = false :: boolean, -- gamepass to autoclick highest level object
		AutoHatch = false :: boolean, --gamepass to auto hatch
		TripleHatch = false :: boolean, -- gamepass to triple hatch

		Perks = {
			Cash = 0,
			Gems = 0,
			PetEquip = 0,
			KickPower = 0,
			BonusBlock = 0,
		},

		--locals
		_Maid = Maid.new() :: Maid,
		_isActive = true :: boolean,
	}, PlayerData) :: any

	Registry[self.Player] = self

	--add leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = self.Player

	--[[local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Parent = leaderstats
	cashValue.Value = self.Cash]]

	--[[local energyValue = Instance.new("IntValue")
	energyValue.Name = "EnergyValue"
	energyValue.Parent = leaderstats
	energyValue.Value = self.Energy]]

	local mergeValue = Instance.new("IntValue")
	mergeValue.Name = "Merge"
	mergeValue.Parent = leaderstats
	mergeValue.Value = self.MergeCount

	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirth"
	rebirthValue.Parent = leaderstats
	rebirthValue.Value = self.Rebirth

	--[[local gemsValue = Instance.new("IntValue")
	gemsValue.Name = "Gems"
	gemsValue.Parent = leaderstats
	gemsValue.Value = self.Gems]]

	--set to 0 (for new players)
	self:SetCash(0)
	self:SetGems(0)
	self:SetEnergy(0)
	self:SetRebirth(0)
	self:SetMergeCount(0)

	task.spawn(function()
		if MarketplaceService:UserOwnsGamePassAsync(self.Player.UserId, MiscLists.GamePassIds.RateOfPassiveMoney2x) then
			self.ProfitMultiplier = 2
		end
		task.wait()
		if MarketplaceService:UserOwnsGamePassAsync(self.Player.UserId, MiscLists.GamePassIds.RateOfGems2x) then
			self.GemsProfitMultiplier = 2
		end
	end)

	return self
end

function PlayerData:SetCash(cashAmount: number)
	--local leaderstats = self.Player:FindFirstChild("leaderstats") :: Folder?
	--local cashValue: IntValue? = if leaderstats then leaderstats:FindFirstChild("Cash") :: IntValue else nil
	--if cashValue then
	--	cashValue.Value = self.Cash
	--end
	self.Cash = cashAmount
	self.Player:SetAttribute("Cash", self.Cash)

	return nil
end

function PlayerData:SetGems(gemsAmount: number)
	--local leaderstats = self.Player:FindFirstChild("leaderstats") :: Folder?
	--local gemsValue: IntValue? = if leaderstats then leaderstats:FindFirstChild("Gems") :: IntValue else nil
	--if gemsValue then
	--	gemsValue.Value = math.round(gemsAmount)
	--end
	self.Gems = math.round(gemsAmount)
	self.Player:SetAttribute("Gems", self.Gems)
	--NetworkUtil.fireClient(ON_PERKS_UPDATE, self.Player, self.Perks)
	return nil
end

function PlayerData:SetEnergy(energyAmount: number)
	--[[local leaderstats = self.Player:FindFirstChild("leaderstats") :: Folder?
	local energyValue: IntValue? = if leaderstats then leaderstats:FindFirstChild("EnergyValue") :: IntValue else nil
	if energyValue then
		energyValue.Value = self.Energy
	end]]
	self.Energy = energyAmount

	return nil
end

function PlayerData:SetRebirth(rebirthAmount: number)
	local leaderstats = self.Player:FindFirstChild("leaderstats") :: Folder?
	local rebirthValue = if leaderstats then leaderstats:FindFirstChild("Rebirth") :: IntValue else nil
	if rebirthValue then
		rebirthValue.Value = rebirthAmount
	end
	self.Rebirth = rebirthAmount
	LeaderboardDataManager.update("Rebirths", self.Player, self.Rebirth, false)

	self.Player:SetAttribute("Rebirths", rebirthAmount)
	return nil
end

function PlayerData:SetMergeCount(mergeCount: number)
	local leaderstats = self.Player:FindFirstChild("leaderstats") :: Folder?
	local mergeValue = if leaderstats then leaderstats:FindFirstChild("Merge") :: IntValue else nil
	if mergeValue then
		mergeValue.Value = mergeCount
	end

	self.MergeCount = mergeCount
	LeaderboardDataManager.update("LocalMerges", self.Player, self.MergeCount, false)
	LeaderboardDataManager.update("Merges", self.Player, self.MergeCount, false)

	
	return nil
end

function PlayerData:Destroy()
	--unregisters
	Registry[self.Player] = nil
	--nilling vars
	local t = self :: any
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)

	return nil
end

function PlayerData:SetData(info: PlayerDataType)
	self:SetCash(info.Cash or self.Cash)
	self:SetGems(info.Gems or self.Gems)
	self:SetEnergy(info.Energy or self.Energy)
	self:SetRebirth(info.Rebirth or self.Rebirth)

	LeaderboardDataManager.update("Rebirths", self.Player, info.Rebirth or self.Rebirth, true)
	LeaderboardDataManager.update("LocalMerges", self.Player, info.MergeCount or self.MergeCount, false)
	LeaderboardDataManager.update("Merges", self.Player, info.MergeCount or self.MergeCount, true)

	if info.Index then
		for _, v in pairs(info.Index.Object) do
			self:AddIndexHistory("Object", v, true)
		end
		for _, v in pairs(info.Index.Pet) do
			self:AddIndexHistory("Pet", v, true)
		end
	end

	self:SetMergeCount(info.MergeCount or self.MergeCount)

	self.Perks = {
		Cash = if info.Perks then info.Perks["Cash" :: PlayerDataType.PerkType] else 0,
		Gems = if info.Perks then info.Perks["Gems" :: PlayerDataType.PerkType] else 0,
		PetEquip = if info.Perks then info.Perks["PetEquip" :: PlayerDataType.PerkType] else 0,
		KickPower = if info.Perks then info.Perks["KickPower" :: PlayerDataType.PerkType] else 0,
		BonusBlock = if info.Perks then info.Perks["BonusBlock" :: PlayerDataType.PerkType] else 0,
	}

	

	--testing only
	if self.Player.Name == "aryoseno11" then
		self:SetCash(50000000000)
		-- self:SetRebirth(0)
		-- self:SetGems(250)
	end
	if self.Player.Name == "CJ_Oyer" then
		self:SetRebirth(0)
		self:SetCash(500000000)
	end
	--if self.Player.UserId == 2792466732 then
		--stage 2
		--self:SetCash(50000000000)

		--stage 3
		--self:SetGems(930)

		--final stage
		--self:SetCash(124000000)
		--self:SetMergeCount(1285)
	--end
	return nil
end

function PlayerData:GetData()
	local data = {}
	data.Cash = self.Cash :: number
	data.Energy = self.Energy :: number
	data.Rebirth = self.Rebirth :: number
	data.Gems = self.Gems :: number

	data.Index = {
		Object = self.DiscoveredBlockLevels,
		Pet = self.DiscoveredPets,
	}

	data.MergeCount = self.MergeCount :: number

	data.Perks = self.Perks

	return data
end

function PlayerData:Reset(clean: boolean)
	self:SetCash(0)
	self:SetEnergy(0)

	if clean then
		table.clear(self.DiscoveredPets)
		table.clear(self.DiscoveredBlockLevels)

		self:SetRebirth(0)
		self:SetMergeCount(0)
		self:SetGems(0)

		self.Perks["Cash" :: PlayerDataType.PerkType] = 0
		self.Perks["Gems" :: PlayerDataType.PerkType] = 0
		self.Perks["PetEquip" :: PlayerDataType.PerkType] = 0
		self.Perks["KickPower" :: PlayerDataType.PerkType] = 0
		self.Perks["BonusBlock" :: PlayerDataType.PerkType] = 0
	end
	return nil
end

function PlayerData:RebirthAction()
	local price = MiscLists.Prices.RebirthPrice[self.Rebirth + 1]
		or MiscLists.Prices.RebirthPrice[#MiscLists.Prices.RebirthPrice]
	print(self.Rebirth, self.Cash, "<", price)
	if self.Cash < price then
		warn("Not enough cash to do rebirth!")
		return
	end
	local highestBlockLevel = _getHighestBlock(self.Player)


	local ownsDoubleGamepass = MarketplaceService:UserOwnsGamePassAsync(
		self.Player.UserId, 
		MiscLists.GamePassIds.RateOfGems2x
	)

	print("DOUBLE GAMEPASS OWNED", ownsDoubleGamepass)
	
	local reward = RebirthUtil.getRebirthGemRewardFromBlockLevel(
		highestBlockLevel, 
		self.Rebirth + 1, 
		self.Perks["Gems" :: PlayerDataType.PerkType] or 0,
		ownsDoubleGamepass
	)

	self:Reset(false) -- then resets

	self:SetRebirth(self.Rebirth + 1) --set rebirth

	--adds reward
	-- local adjustedReward = self:GetAdjustedPerkAmount("Gems", reward)
	-- adjustedReward = self:GetAdjustedGamepassAmount(MiscLists.GamePassIds.RateOfGems2x, adjustedReward)
	--print(self.Gems , " + " ,adjustedReward)
	self:SetGems(self.Gems + reward)
	--print(self.Gems)
	--reduce cost (obselete)
	--self.Cash -= price

	--rebirth badge
	if not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Rebirth) then
		BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Rebirth)
	end

	return nil
end

function PlayerData:GetAdjustedPerkAmount(perkType: PlayerDataType.PerkType, amount: number)
	local perkData = MiscLists.Limits.Perks[perkType][self.Perks[perkType] :: number]
	local adjustedAmount = if perkType ~= "PetEquip"
		then (amount + (amount * (if perkData then perkData.Perk else 0)))
		else (amount + (if perkData then perkData.Perk else 0))
	return adjustedAmount
end

function PlayerData:GetAdjustedGamepassAmount(gamepassID: number, amount: number)
	if gamepassID == MiscLists.GamePassIds.RateOfPassiveMoney2x then
		return amount * self.ProfitMultiplier
	elseif gamepassID == MiscLists.GamePassIds.RateOfGems2x then
		return amount * self.GemsProfitMultiplier
	end
	return amount
end

function PlayerData:AddIndexHistory(instName: string, ...) -- will change to definitive parameters soon since this method is quite confusing currently smh 
	assert(self.Player, "player missing")
	local isLoadMode = table.pack(...)[2] 
	if instName == "Pet" and not table.find(self.DiscoveredPets, table.pack(...)[1]) then
		table.insert(self.DiscoveredPets, table.pack(...)[1])
		--pet owner badge
		if
			#self.DiscoveredPets > 0
			and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.PetOwner)
		then
			BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.PetOwner)
		end
	elseif instName == "Object" and not table.find(self.DiscoveredBlockLevels, table.pack(...)[1]) then
		table.insert(self.DiscoveredBlockLevels, table.pack(...)[1])

		--level 1 block badge
		local highestLevel = _getHighestBlock(self.Player)
		if highestLevel == 1 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block1Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block1Unlocked)
			end
		elseif highestLevel == 2 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block2Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block2Unlocked)
			end
		elseif highestLevel == 9 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block9Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block9Unlocked)
			end
		elseif highestLevel == 17 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block17Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block17Unlocked)
			end
		elseif highestLevel == 25 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block25Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block25Unlocked)
			end
		elseif highestLevel == 33 then
			if not BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block33Unlocked) then
				BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block33Unlocked)
			end
		end
		
		--if table.find(self.DiscoveredBlockLevels, 1) and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Block1Unlocked) then
		--	BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block1Unlocked)
		--end
		--level 9 block badge
		--if table.find(self.DiscoveredBlockLevels, 9) and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Block9Unlocked) then
		--	BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block9Unlocked)
		--end
		--level 17 block badge
		--if table.find(self.DiscoveredBlockLevels, 17) and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Block17Unlocked) then
		--	BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block17Unlocked)
		--end
		--level 25 block badge
		--if table.find(self.DiscoveredBlockLevels, 25) and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Block25Unlocked) then
		--	BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block25Unlocked)
		--end
		--level 33 block badge
		--if table.find(self.DiscoveredBlockLevels, 33) and not BadgeService:UserHasBadgeAsync(self.Player.UserId, MiscLists.BadgeIds.Block33Unlocked) then
		--	BadgeService:AwardBadge(self.Player.UserId, MiscLists.BadgeIds.Block33Unlocked)
		--end
		--block achievement
		if not isLoadMode then
			print("Fire")
			NetworkUtil.fireClient(ON_OBJECT_INDEX_ACHIEVEMENT, self.Player,  table.pack(...)[1])
		end
	end
	NetworkUtil.fireClient(ON_OBJECT_INDEX_UPDATE, self.Player, self.DiscoveredBlockLevels)
	NetworkUtil.fireClient(ON_PET_INDEX_UPDATE, self.Player, self.DiscoveredPets)
	
	return nil
end

--[[function PlayerData:GetGamePassASync(gamepassID : number)
    print("Get Asyinc")
    do  --rarity pass 
        self.RarityMultiplier = 0
        local hasLuckyPass = false
        local hasSuperLuckyPass = false
        local _,e = pcall(function() hasLuckyPass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.Lucky) end)
        local _,e2 = pcall(function() hasSuperLuckyPass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.SuperLucky) end)
        if e then
            warn("Warning: ", e)
        end
        if e2 then
            warn("Warning: ", e2)
        end
        if hasLuckyPass or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.Lucky) then 
            self.RarityMultiplier += 1 
        end
        if hasSuperLuckyPass or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.SuperLucky) then 
            self.RarityMultiplier += 3 
        end
    end
    do --2x rate of passive money
        local hasProfitMultiplierPass = false
        local _,e = pcall(function() hasProfitMultiplierPass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.RateOfPassiveMoney2x) end)
        if e then
            warn("Warning: ", e)
        end
        if hasProfitMultiplierPass or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.RateOfPassiveMoney2x) then
            self.ProfitIntervalMultiplier = 2
        end
    end
    do --auto clicker
        local hasAutoClicker = false
        local _,e = pcall(function() hasAutoClicker = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.AutoClicker) end)
        if e then
            warn("Warning: ", e)
        end
        if hasAutoClicker or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.AutoClicker) then
            self.AutoClicker = true
        end
    end
    do --auto-hatch and triple hatch
        local hasAutoHatchPass
        local hasTripleHatchPass 
        local _,e = pcall(function() hasAutoHatchPass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.AutoHatch) end)
        local _,e2 = pcall(function() hasTripleHatchPass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, miscLists.GamePassIds.TripleHatch) end)
        if e then  warn("Warning: ", e) end
        if e2 then warn("Warning: ", e2) end
        if hasAutoHatchPass or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.AutoHatch) then 
            self.AutoHatch = true
        end
        if hasTripleHatchPass or (runService:IsStudio() and gamepassID == miscLists.GamePassIds.TripleHatch) then
            self.TripleHatch = true
        end
    end
end

function PlayerData:OnGamePassPurchase(gamePassId : number)
    local alreadyHasGamepass = false
    local _,e = pcall(function() alreadyHasGamepass = marketplaceService:UserOwnsGamePassAsync(self.Player.UserId, gamePassId) end)
    if e then warn("Warning: ".. e); return end
    if not alreadyHasGamepass then
        marketplaceService:PromptGamePassPurchase(self.Player, gamePassId)
    end  
end

function PlayerData:OnDeveloperProductHandler(receiptInfo : any) : Enum.ProductPurchaseDecision
    --local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId

    --double currency
    if productId == miscLists.DeveloperProductIds.DoubleCurrentMoney then
        -- Get the handler function associated with the developer product ID and attempt to run it
        local success, result = pcall(function()
                --doubles the current cash and adding it also by 100
            self:SetCash((self.Cash*2) + 100)
        end)
        if success then
            -- The player has received their benefits!
            -- return PurchaseGranted to confirm the transaction.
            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            warn("Failed to process receipt:", receiptInfo, result)
        end
    end
    
    -- the player's benefits couldn't be awarded.
    -- return NotProcessedYet to try again next time the player joins.
    return Enum.ProductPurchaseDecision.NotProcessedYet
end]]

---@public
function PlayerData.get(plr: Player)
	return Registry[plr]
end

function PlayerData.init(maid: Maid)
	--server <-> client comms
	NetworkUtil.onServerInvoke(GET_INDEX, function(plr, instType)
		local plrData = PlayerData.get(plr)

		return if instType == "Pet"
			then plrData.DiscoveredPets
			elseif instType == "Object" then plrData.DiscoveredBlockLevels
			else nil
	end)

	NetworkUtil.onServerInvoke(GET_PERKS, function(plr)
		local plrData = PlayerData.get(plr)

		return plrData.Perks
	end)

	NetworkUtil.onServerInvoke(ON_PERK_ADDED, function(plr: Player, perkType: PlayerDataType.PerkType)
		local plrData = PlayerData.get(plr)
		assert(plrData)

		local perkList = MiscLists.Limits.Perks[perkType]
		assert(perkList, "Perk not found!")

		local nextLevel: number = plrData.Perks[perkType] + 1

		local perkInfoByLevel = perkList[nextLevel]
		if perkInfoByLevel then
			if perkInfoByLevel.Gems > plrData.Gems then
				warn("Not enough gems to buy the perk!")
				return nil
			end

			plrData.Perks[perkType] = nextLevel

			--reduce gems
			--[[if perkType == "Gems" then
				plrData:SetGems(plrData.Gems + plrData.Gems*perkInfoByLevel.Perk)
			else
				plrData:SetGems(plrData.Gems - perkInfoByLevel.Gems)
				if perkType == "Cash" then 
					plrData:SetCash(plrData.Cash + plrData.Cash*perkInfoByLevel.Perks)
				elseif perkType == "re" then
					plrData:SetGems(plrData.Gems + plrData.Gems*perkInfoByLevel.Perks)
				end
				
			end]]
			plrData:SetGems(plrData.Gems - perkInfoByLevel.Gems)
		end

		NetworkUtil.fireClient(ON_PERKS_UPDATE, plr, plrData.Perks)
		return nil
	end)
	NetworkUtil.getRemoteEvent(ON_OBJECT_INDEX_UPDATE)
	NetworkUtil.getRemoteEvent(ON_PET_INDEX_UPDATE)
	NetworkUtil.getRemoteEvent(ON_OBJECT_INDEX_ACHIEVEMENT)
	
	NetworkUtil.getRemoteEvent(ON_PERKS_UPDATE)
	NetworkUtil.getRemoteEvent(ON_GUI_PROFIT)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(plr: Player, gamepassId: number, wasPurchased: boolean)
			if wasPurchased then
				local plrData = PlayerData.get(plr)
				assert(plrData, "Failed to load player data")
				if gamepassId == MiscLists.GamePassIds.RateOfPassiveMoney2x then
					plrData.ProfitMultiplier = 2
				elseif gamepassId == MiscLists.GamePassIds.RateOfGems2x then
					plrData.GemsProfitMultiplier = 2
				end
			end
		end
	)

	--add rewards
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plrData = PlayerData.get(plr)
			assert(plrData, "Player data not found!")

			local profit = (MiscLists.Limits.BlockIncomeOnLevel[_getHighestBlock(plr) or #MiscLists.Limits.BlockIncomeOnLevel])
			local bonusCash = if profit then profit*100 else 0
			plrData:SetCash(plrData.Cash + bonusCash)
			
			NetworkUtil.fireClient(ON_GUI_PROFIT, plr, bonusCash)

			return nil
		end,
		RewardName = "100x Highest Block Income",
		Time = 2*60
	}

	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plrData = PlayerData.get(plr)
			assert(plrData, "Player data not found!")

			local profit = (MiscLists.Limits.BlockIncomeOnLevel[_getHighestBlock(plr) or #MiscLists.Limits.BlockIncomeOnLevel])
			local bonusCash = if profit then profit*200 else 0
			plrData:SetCash(plrData.Cash + bonusCash)
			
			print(bonusCash)
			return nil
		end,
		RewardName = "200x Highest Block Income",
		Time = 10*60
	}
	
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plrData = PlayerData.get(plr)
			assert(plrData, "Player data not found!")

			local profit = (MiscLists.Limits.BlockIncomeOnLevel[_getHighestBlock(plr) or #MiscLists.Limits.BlockIncomeOnLevel])
			local bonusCash = if profit then profit*200 else 0
			plrData:SetCash(plrData.Cash + bonusCash)
			
			print(bonusCash)
			return nil
		end,
		RewardName = "200x Highest Block Income (2)",
		Time = 20*60
	}
	
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plrData = PlayerData.get(plr)
			assert(plrData, "Player data not found!")

			local profit = (MiscLists.Limits.BlockIncomeOnLevel[_getHighestBlock(plr) or #MiscLists.Limits.BlockIncomeOnLevel])
			local bonusCash = if profit then profit*300 else 0
			plrData:SetCash(plrData.Cash + bonusCash)
			
			print(bonusCash)
			return nil
		end,
		RewardName = "300x Highest Block Income",
		Time = 45*60
	}
	DailyRewards.addReward{
		RewardFunc = function(plr : Player)
			local plrData = PlayerData.get(plr)
			assert(plrData, "Player data not found!")

			local profit = (MiscLists.Limits.BlockIncomeOnLevel[_getHighestBlock(plr) or #MiscLists.Limits.BlockIncomeOnLevel])
			local bonusCash = if profit then profit*500 else 0
			plrData:SetCash(plrData.Cash + bonusCash)
			
			print(bonusCash)
			return nil
		end,
		RewardName = "500x Highest Block Income",
		Time = 75*60
	}


	return nil
end

return PlayerData
