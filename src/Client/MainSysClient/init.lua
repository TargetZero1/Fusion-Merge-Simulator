--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

--references
local Player = game:GetService("Players").LocalPlayer :: Player
local PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ServiceProxy"))

--modules
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local PetKinds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetKinds"))
local HatchBillboard = require(script:WaitForChild("HatchBillboard"))
local HatchProcess = require(script:WaitForChild("HatchProcess"))
local UpgradeBoard = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("UpgradeBoard"))
local Hint = require(script:WaitForChild("Hint"))
local BlockNotification = require(script:WaitForChild("BlockNotification"))
local ShopMenu = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ShopMenu"))
local RebirthShopMenu =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("RebirthShopMenu"))
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))
local PlayerDataType =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local BlockTutorial = 
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("BlockTutorial"))

--types
type Maid = Maid.Maid
export type MainSysClient = {
	__index: MainSysClient,
	_Maid: Maid,
	new: () -> MainSysClient,
	Destroy: (MainSysClient) -> nil,
	init: (Maid, plotModel: Model, plotDeclared: Model) -> nil,
}
type PetDisplayData = HatchBillboard.PetDisplayData
type HatchPetClass = "Dog" | "Cat" | "Mouse" | "Premium"
type PerkType = PlayerDataType.PerkType

-- constants
local HATCH_KEY = "Hatch"
local TRIPLE_HATCH_KEY = "TripleHatch"
local UPGRADE_BASE_KEY = "UpgradeBase"
local UPGRADE_LIMIT_KEY = "UpgradeLimit"
local UPGRADE_RATE_KEY = "UpgradeRate"
local BUY_RELOAD_DURATION = 0
local SINGLE_BUTTON_ICON = "rbxassetid://13082575559"
local MULTI_BUTTON_ICON = "rbxassetid://12791265386"

local TRIGGER_HATCH_ANIMATION_KEY = "TriggerHatchAnimationKey"

local ON_PERK_ADDED = "OnPerkAdded"
local ON_PERKS_UPDATE = "OnPerksUpdate"
local GET_PERKS = "GetPerks"

local CAT_ICON = "rbxassetid://13078992959"
local DOG_ICON = "rbxassetid://13078992583"
local MOUSE_ICON = "rbxassetid://13079331502"

local FIRE_PREMIUM_HATCH_SEQUENCE = "FirePremiumHatchSequence"

local PREMIUM_CAT_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Cat
local PREMIUM_DOG_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Dog
local PREMIUM_MOUSE_DEV_PRODUCT_ID = MiscLists.DeveloperProductIds.AddLevel5Mouse
--remotes

--references
local AssetFolder = ReplicatedStorage:WaitForChild("Assets")
local PetModels = AssetFolder:WaitForChild("PetModels")

--variables

--local function
local function _getHighestBlock(): number
	task.wait(0.1)
	local currentBlocksLevel = { 0 }
	local blocksData = BlocksUtil.getBlocks(Player)
	for _, v in pairs(blocksData) do
		table.insert(currentBlocksLevel, v.Level)
	end
	return math.max(unpack(currentBlocksLevel))
end
local function hatch(petNames: { [number]: string }?, petClass : string): nil
	if not petNames then
		return
	end
	assert(petNames ~= nil, "bad petNames")
	local hatchDataList = {}
	for i, petName in ipairs(petNames) do
		print(petName, "LVL", petName:gsub("%a", ""):sub(1, 1))
		local lvl = tonumber(petName:gsub("%a", ""):sub(1, 1)) or 1
		local class = petName:gsub(tostring(lvl), "")

		local model = PetModels:WaitForChild(petName):Clone()
		table.insert(hatchDataList, {
			Model = model,
			Text = class:gsub("%d", ""),
			Color = Color3.fromHSV(math.random(), 1, 1),
			Level = lvl,
		})
	end

	HatchProcess(hatchDataList, petClass)
	return nil
end
--class
local currentMainSys: MainSysClient

local MainSys = {} :: MainSysClient
MainSys.__index = MainSys

function MainSys.new()
	local self = setmetatable({}, MainSys) :: any
	self._Maid = Maid.new() :: Maid

	local intTick = tick()
	self._Maid:GiveTask(RunService.Stepped:Connect(function()
		if (tick() - intTick) >= 1 then
			self:Update()
			intTick = tick()
		end
	end))

	--[[local function bonusBlockUpdate()
		if self.Plot:GetAttribute("NoTouch") then
            --attribute update block bonus
            for _,object : Objects.Block in pairs(Objects.getObjects() :: any) do
                if object.Player == nil then 
                    local blockBonusModel = object.BlockModel
                    if blockBonusModel.PrimaryPart then 
                        blockBonusModel.PrimaryPart.Transparency = 1 
                        blockBonusModel.PrimaryPart.Anchored = true
                        blockBonusModel.PrimaryPart.CanCollide = false
                        for _,v in pairs(blockBonusModel.PrimaryPart:GetDescendants()) do
                            if v:IsA("TextLabel") then v.TextTransparency = 1 
                            elseif v:IsA("Texture") then v.Transparency = 1 end
                        end
                    end
                    
                end
            end
        else
            --attribute update block bonus
            for _,object : Objects.Block in pairs(Objects.getObjects() :: any) do
                if object.Player == nil then 
                    local blockBonusModel = object.BlockModel
                    if blockBonusModel.PrimaryPart then 
                        blockBonusModel.PrimaryPart.CanCollide = true
                        blockBonusModel.PrimaryPart.Anchored = false
                        blockBonusModel.PrimaryPart.Transparency = 0 
                        for _,v in pairs(blockBonusModel.PrimaryPart:GetDescendants()) do
                            if v:IsA("TextLabel") then v.TextTransparency = 0 
                            elseif v:IsA("Texture") then v.Transparency = 0 end
                        end
                    end
                end
            end
        end
	end]]

	--[[bonusBlockUpdate()
	self.Plot:GetAttributeChangedSignal("NoTouch"):Connect(function()
		bonusBlockUpdate()
	end)]]

	currentMainSys = self

	return self
end

function MainSys:Destroy()
	--unregisters
	self._Maid:Destroy()

	local t = self :: any
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)
	return nil
end

function MainSys.init(maid, plotModel: Model, plotDeclared)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN

	--setting gui for hatch
	-- local isHatching = false

	--gives gamepass board
	local SurfaceGui = _new("SurfaceGui")({
		Name = "ShopGui",
		Parent = plotDeclared:WaitForChild("Billboards"):WaitForChild("GamePassButtons"),
		SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		CanvasSize = Vector2.new(650, 450),
	}) :: SurfaceGui

	local shopMenu = maid:GiveTask(ShopMenu(_Value(true), nil, SurfaceGui))
	shopMenu.AnchorPoint = Vector2.new(0.7, 0.5)
	shopMenu.Position = UDim2.fromScale(0.5, 0.45)
	shopMenu.Size = UDim2.fromScale(1, 1)
	do
		local shopMenuFrame = shopMenu:FindFirstChild("Frame") :: Frame
		local loadingText = SurfaceGui:FindFirstChild("TextLabel") :: TextLabel
		if shopMenuFrame then
			shopMenuFrame.BackgroundTransparency = 1
		end
		if loadingText then
			loadingText:Destroy()
		end
	end
	--maid:GiveTask(GamepassMenu(plotDeclared:WaitForChild("Billboards"):WaitForChild("GamePassButtons") :: Part))

	local function buildHatchBillboard(petClass: HatchPetClass)
		local egg = plotModel:WaitForChild("Distributers"):WaitForChild(petClass):WaitForChild("Egg") :: Model
		assert(egg and egg.PrimaryPart)

		local DisplayPetData = _Value({})

		local onButton1Click = maid:GiveTask(Signal.new())
		local onButton2Click = maid:GiveTask(Signal.new())
		local onButton3Click = maid:GiveTask(Signal.new())
		local IsPremium = _Value(petClass == "Premium")
		local Price = _Computed(function(isPremium: boolean): number
			if isPremium then
				return 299
			else
				return 750 * 1000
			end
		end, IsPremium)

		local ButtonLabel1 = _Value(if petClass == "Premium" then MOUSE_ICON else SINGLE_BUTTON_ICON)
		local ButtonLabel2 = _Value(if petClass == "Premium" then CAT_ICON else MULTI_BUTTON_ICON)
		local ButtonLabel3 = _Value(if petClass == "Premium" then DOG_ICON else MULTI_BUTTON_ICON)
		maid:GiveTask(
			HatchBillboard(
				egg.PrimaryPart.Position + Vector3.new(0, 7, 0),
				DisplayPetData,
				onButton1Click,
				onButton2Click,
				onButton3Click,
				ButtonLabel1,
				ButtonLabel2,
				ButtonLabel3,
				Price,
				IsPremium
			)
		)
		maid:GiveTask(NetworkUtil.onClientEvent(FIRE_PREMIUM_HATCH_SEQUENCE, function(petName: string)
			if petClass == "Premium" then
				hatch({ petName }, petClass)
			end
		end))

		maid:GiveTask(onButton1Click:Connect(function()
			-- print("B1", petClass)
			if petClass == "Premium" then
				MarketplaceService:PromptProductPurchase(game:GetService("Players").LocalPlayer, PREMIUM_MOUSE_DEV_PRODUCT_ID)
				-- hatch({ NetworkUtil.invokeServer(HATCH_KEY, "Mouse", true) })
			else
				hatch({ NetworkUtil.invokeServer(HATCH_KEY, petClass, false) }, petClass)
			end
		end))

		local errorSound = maid:GiveTask(Instance.new("Sound"))
		errorSound.SoundId = "rbxassetid://3779045779"

		maid:GiveTask(onButton2Click:Connect(function()
			if petClass == "Premium" then
				MarketplaceService:PromptProductPurchase(game:GetService("Players").LocalPlayer, PREMIUM_CAT_DEV_PRODUCT_ID)
				-- hatch({ NetworkUtil.invokeServer(HATCH_KEY, "Cat", true) })
			else
				local petNames: { [number]: string }? =
					NetworkUtil.invokeServer(TRIPLE_HATCH_KEY, false, petClass, false)

				if petNames then
					hatch(petNames, petClass)
				else
					SoundService:PlayLocalSound(errorSound)
					maid:GiveTask(
						Hint(
							Color3.fromHSV(0.1, 0.8, 1),
							"To use Triple Hatch, please join our group and consider liking 👍 the game!"
						)
					)
				end
			end
		end))

		-- maid:GiveTask(NetworkUtil.onClientEvent(ON_AUTO_FAIL_KEY, function(msg: string)
		-- 	IsButton3Enabled:Set(false)
		-- 	maid:GiveTask(Hint(Color3.fromHSV(0, 1, 0.8), msg))
		-- end))

		maid:GiveTask(onButton3Click:Connect(function(isEnabled: boolean)
			-- print("B3", petClass)
			if petClass == "Premium" then
				MarketplaceService:PromptProductPurchase(game:GetService("Players").LocalPlayer, PREMIUM_DOG_DEV_PRODUCT_ID)
				-- hatch({ NetworkUtil.invokeServer(HATCH_KEY, "Dog", true) })
				-- else
				-- local autoSuccess = NetworkUtil.invokeServer(AUTO_HATCH_KEY, isEnabled, false, petClass, false)
				-- if not autoSuccess then
				-- 	IsButton3Enabled:Set(false)

				-- 	-- prompt gamepass purchase?
				-- 	MarketplaceService:PromptGamePassPurchase(game:GetService("Players").LocalPlayer, AUTO_GAMEPASS_ID)
				-- 	local _plr, _id, isSuccess = MarketplaceService.PromptGamePassPurchaseFinished:Wait()

				-- 	-- if prompt succeeds, attempt hatch again
				-- 	local isPurchaseSuccess = isSuccess and _id == AUTO_GAMEPASS_ID
				-- 	IsButton3Enabled:Set(isPurchaseSuccess)
				-- end
			end
		end))

		if petClass == "Premium" then
			for _, PetKindData: PetKinds.PetKindData<RarityUtil.RarityName> in pairs(PetKinds :: any) do
				local pClass: PetsUtil.PetClass = PetKindData.PetModel.Name:gsub("%d+", "") :: any

				if type(PetKindData) == "table" and PetKindData.PetModel then
					local petData: PetDisplayData = {
						PetId = "",
						UserId = tostring(Player.UserId),
						Class = pClass,
						Name = pClass .. "7",
						Equipped = false,
						Level = 7,
						Text = PetKindData.PetModel.Name .. " " .. FormatUtil.ToRomanNumerals(7),
						Chance = 0.333,
					}
					local dPD = DisplayPetData:Get()
					table.insert(dPD, petData)
					DisplayPetData:Set(dPD)
				end
			end
		else
			local petKindData = PetKinds[petClass]
			assert(petKindData)

			local levels = { 0.8, 0.15, 0.05 }

			if petKindData.PetModel then
				for lvl = 1, 3 do
					local petData: PetDisplayData = {
						PetId = "",
						UserId = tostring(Player.UserId),
						Class = petClass,
						Name = petClass .. if lvl == 1 then "" else tostring(lvl),
						Equipped = false,
						Level = lvl,
						Text = petKindData.PetModel.Name .. " " .. FormatUtil.ToRomanNumerals(lvl),
						Chance = levels[lvl],
					}
					local dPD = DisplayPetData:Get()
					table.insert(dPD, petData)
					DisplayPetData:Set(dPD)
				end
			end
		end

		-- for _, PetKindData: PetKinds.PetKindData<RarityUtil.RarityName> in pairs(PetKinds :: any) do
		-- 	local pClass: PetsUtil.PetClass = PetKindData.PetModel.Name:gsub("%d+", "") :: any

		-- 	local function getIsPremium(): boolean
		-- 		return false
		-- 	end

		-- 	if type(PetKindData) == "table" and PetKindData.PetModel and (pClass == petClass or (petClass == "Premium" and getIsPremium())) then

		-- 		local petData: PetDisplayData = {
		-- 			PetId = "",
		-- 			UserId = tostring(Player.UserId),
		-- 			Class = pClass,
		-- 			Name = PetKindData.PetModel.Name,
		-- 			Equipped = false,
		-- 			Level = 1,
		-- 			Text = PetKindData.PetModel.Name..""..FormatUtil.ToRomanNumerals(5),
		-- 			Chance = PetKindData.Rarity.Value :: number ,
		-- 		}
		-- 		local dPD = DisplayPetData:Get()
		-- 		table.insert(dPD, petData)
		-- 		DisplayPetData:Set(dPD)

		-- 	end
		-- end
	end
	for i, petClass: HatchPetClass in ipairs({ "Dog", "Cat", "Mouse", "Premium" } :: any) do
		buildHatchBillboard(petClass)
	end

	BlockNotification.init(maid)

	--upgrades feature of billboard
	local upgradeOptions = PlayerGui:WaitForChild("SurfaceGuis"):WaitForChild("UpgradeOptions") :: SurfaceGui
	upgradeOptions.Adornee = plotDeclared:WaitForChild("Billboards"):WaitForChild("UpgradeButtons1")
	local BaseUpgradeFrame = upgradeOptions:WaitForChild("BaseUpgradeFrame")
	local BaseUpgradeFrameButton: TextButton? = if BaseUpgradeFrame
		then BaseUpgradeFrame:WaitForChild("PurchaseButton") :: TextButton
		else nil
	local LimitUpgradeFrame = upgradeOptions:WaitForChild("LimitUpgradeFrame")
	local LimitUpgradeFrameButton: TextButton? = if LimitUpgradeFrame
		then LimitUpgradeFrame:WaitForChild("PurchaseButton") :: TextButton
		else nil
	local RateUpgradeFrame = upgradeOptions:WaitForChild("RateUpgradeFrame")
	local RateUpgradeFrameButton: TextButton? = if RateUpgradeFrame
		then RateUpgradeFrame:WaitForChild("PurchaseButton") :: TextButton
		else nil
	if BaseUpgradeFrameButton then
		BaseUpgradeFrameButton.Activated:Connect(function()
			NetworkUtil.invokeServer("UpgradeBase")
			--mainSysInfo:Update()
		end)
	end
	if LimitUpgradeFrameButton then
		LimitUpgradeFrameButton.Activated:Connect(function()
			NetworkUtil.invokeServer("UpgradeLimit")
			--mainSysInfo:Update()
		end)
	end
	if RateUpgradeFrameButton then
		RateUpgradeFrameButton.Activated:Connect(function()
			NetworkUtil.invokeServer("UpgradeRate")
			--mainSysInfo:Update()
		end)
	end
	--mainSysInfo:Update()

	--misc billboards
	--[[local SurfaceGuis = PlayerGui:FindFirstChild("SurfaceGuis") :: SurfaceGui ?
	if SurfaceGuis then
		local DataOptions: SurfaceGui = SurfaceGuis:WaitForChild("DataOptions") :: SurfaceGui
		DataOptions.Adornee = plotDeclared:WaitForChild("Billboards"):WaitForChild("DataButtons1")
		local ResetButton = DataOptions:WaitForChild("ResetButton") :: TextButton

		if ResetButton then
			ResetButton.Activated:Connect(function()
				NetworkUtil.invokeServer("Reset")
			end)
		end
	end]]

	--ground buttons
	local groundButtons = plotModel:WaitForChild("GroundButtons") :: Model

	local drop25BlockButton: BasePart? = if groundButtons
		then groundButtons:FindFirstChild("Drop25Block") :: BasePart
		else nil
	local drop50BlockButton: BasePart? = if groundButtons
		then groundButtons:FindFirstChild("Drop50Block") :: BasePart
		else nil
	local drop100BlockButton: BasePart? = if groundButtons
		then groundButtons:FindFirstChild("Drop100Block") :: BasePart
		else nil

	local function getIfPlayerPart(part: BasePart): boolean
		local character = game:GetService("Players").LocalPlayer.Character
		return character and part:IsDescendantOf(character)
	end

	if drop25BlockButton then
		drop25BlockButton.Touched:Connect(function(part)
			if getIfPlayerPart(part) then
				MarketplaceService:PromptProductPurchase(Player, MiscLists.DeveloperProductIds.Drop25Blocks)
			end
		end)
	end
	if drop50BlockButton then
		drop50BlockButton.Touched:Connect(function(part)
			if getIfPlayerPart(part) then
				MarketplaceService:PromptProductPurchase(Player, MiscLists.DeveloperProductIds.Drop50Blocks)
			end
		end)
	end
	if drop100BlockButton then
		drop100BlockButton.Touched:Connect(function(part)
			if getIfPlayerPart(part) then
				MarketplaceService:PromptProductPurchase(Player, MiscLists.DeveloperProductIds.Drop100Blocks)
			end
		end)
	end

	--3d boards
	--local cashValue = leaderstats:WaitForChild("Cash") :: NumberValue
	local Wallet = _Value(game:GetService("Players").LocalPlayer:GetAttribute("Cash"))

	local OnSpawnLevel = maid:GiveTask(Signal.new())
	local OnMaxClick = maid:GiveTask(Signal.new())
	local OnSpawnTime = maid:GiveTask(Signal.new())

	local SpawnLevel = _Value(plotModel:GetAttribute("BaseLevel") or 1)
	local UpgradeLevel = _Value(plotModel:GetAttribute("MaximumObjectCount") or 1)
	local SpawnTimerLevel = _Value((5 - (plotModel:GetAttribute("AutoSpawnerInterval") or 0)) / 0.2)

	maid:GiveTask(
		UpgradeBoard(
			plotDeclared:WaitForChild("Billboards"):WaitForChild("UpgradeButtons1") :: Part,
			Wallet,
			SpawnLevel,
			UpgradeLevel,
			SpawnTimerLevel,
			OnSpawnLevel,
			OnMaxClick,
			OnSpawnTime,
			plotModel
		)
	)

	--rotates
	maid:GiveTask(RunService.RenderStepped:Connect(function()
		local blockPlinthModel = plotDeclared:FindFirstChild("BlockPlinth") :: Model
		local blockDisplay = if blockPlinthModel then blockPlinthModel:FindFirstChild("Block") :: Model else nil
	
		if blockDisplay and blockDisplay.PrimaryPart then
			blockDisplay:PivotTo(blockDisplay.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(0.3), 0))
		end
	
		--rotates eggs as well
		local distributers = plotModel:FindFirstChild("Distributers")
	
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
		end
	end))
	

	--update
	maid:GiveTask(plotModel:GetAttributeChangedSignal("BaseLevel"):Connect(function()
		SpawnLevel:Set(plotModel:GetAttribute("BaseLevel"))
	end))
	maid:GiveTask(plotModel:GetAttributeChangedSignal("MaximumObjectCount"):Connect(function()
		UpgradeLevel:Set(plotModel:GetAttribute("MaximumObjectCount"))
	end))
	maid:GiveTask(plotModel:GetAttributeChangedSignal("AutoSpawnerInterval"):Connect(function()
		SpawnTimerLevel:Set((5 - ((plotModel:GetAttribute("AutoSpawnerInterval") or 0) + 0.2)) / 0.2)
	end))
	--

	maid:GiveTask(Player:GetAttributeChangedSignal("Cash"):Connect(function()
		Wallet:Set(Player:GetAttribute("Cash"))
	end))

	local clickTick = tick()
	maid:GiveTask(OnSpawnLevel:Connect(function()
		print("Spawn level click")
		if tick() - clickTick < BUY_RELOAD_DURATION then
			return
		end
		print("Spawn level purchase")
		clickTick = tick()
		SpawnLevel:Set(NetworkUtil.invokeServer(UPGRADE_BASE_KEY))
	end))
	maid:GiveTask(OnMaxClick:Connect(function()
		print("Max click click")
		if tick() - clickTick < BUY_RELOAD_DURATION then
			return
		end
		print("Max click purchase")
		clickTick = tick()
		UpgradeLevel:Set(NetworkUtil.invokeServer(UPGRADE_LIMIT_KEY))
	end))
	maid:GiveTask(OnSpawnTime:Connect(function()
		print("Spawn time click")
		if tick() - clickTick < BUY_RELOAD_DURATION then
			return
		end
		print("Spawn time purchase")
		clickTick = tick()
		SpawnTimerLevel:Set(NetworkUtil.invokeServer(UPGRADE_RATE_KEY))
	end))

	--rebirth billboard
	local rebirthSG = _fuse.new("SurfaceGui")({
		Name = "RebirthGui",
		Parent = plotDeclared:WaitForChild("Billboards"):WaitForChild("DataButtons1"),
		SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		CanvasSize = Vector2.new(700, 500),
	})

	local gemValue = _Value(Player:GetAttribute("Gems"))
	local rebirthValue = _Value(Player:GetAttribute("Rebirths"))
	local highestBlockLevel = _Value(_getHighestBlock())
	local PerksState = _Value(NetworkUtil.invokeServer(GET_PERKS))

	maid:GiveTask(Player:GetAttributeChangedSignal("Gems"):Connect(function()
		gemValue:Set(Player:GetAttribute("Gems"))
	end))

	maid:GiveTask(Player:GetAttributeChangedSignal("Rebirths"):Connect(function()
		rebirthValue:Set(Player:GetAttribute("Rebirths"))
	end))

	local onShopMenuBack = maid:GiveTask(Signal.new())
	local onRebirthClicked = maid:GiveTask(Signal.new())
	local onPerksClicked = maid:GiveTask(Signal.new())

	local rebirthShopMenu = RebirthShopMenu(
		_Value(true),
		gemValue,
		rebirthValue,
		highestBlockLevel,
		Wallet,
		PerksState,
		onShopMenuBack,
		onRebirthClicked,
		onPerksClicked
	)
	rebirthShopMenu.Parent = rebirthSG

	maid:GiveTask(onRebirthClicked:Connect(function()
		NetworkUtil.invokeServer("Rebirth")
	end))

	maid:GiveTask(onPerksClicked:Connect(function(perkType: string)
		NetworkUtil.invokeServer(ON_PERK_ADDED, perkType)
	end))

	local currentBlocksModel = plotModel:FindFirstChild("Objects")
	if currentBlocksModel then
		maid:GiveTask(currentBlocksModel.ChildAdded:Connect(function()
			highestBlockLevel:Set(_getHighestBlock())
		end))
		maid:GiveTask(currentBlocksModel.ChildRemoved:Connect(function()
			highestBlockLevel:Set(_getHighestBlock())
		end))
	end

	--Server-Client Comms
	maid:GiveTask(NetworkUtil.onClientEvent(ON_PERKS_UPDATE, function(perksState)
		PerksState:Set(perksState)
		return nil
	end))
	-- NetworkUtil.onClientInvoke(TRIPLE_HATCH_KEY, function(petNames: {[number]: string}): nil
	-- 	local hatchDataList = {}
	-- 	for i, petName in ipairs(petNames) do

	-- 		local model = PetModels:WaitForChild(petName):Clone()
	-- 		table.insert(hatchDataList, {
	-- 			Model = model,
	-- 			Text = petName,
	-- 			Color = Color3.fromHSV(math.random(), 1, 1)
	-- 		})
	-- 	end

	-- 	HatchProcess(hatchDataList)
	-- 	return nil
	-- end)

	-- NetworkUtil.onClientInvoke(HATCH_KEY, function(petName)
	-- 	--do the animation
	-- 	local model = PetModels:WaitForChild(petName):Clone()
	-- 	HatchProcess({
	-- 		{
	-- 			Model = model,
	-- 			Text = petName,
	-- 			Color = Color3.fromHSV(math.random(), 1, 1)
	-- 		}
	-- 	})
	-- 	-- EffectsUtil.EggHatch(Player.PlayerGui.ScreenGui, petName)
	-- 	return nil -- yields to get pet in server
	-- end)

	--lock to landscape
	if not game:GetService("UserInputService").KeyboardEnabled then
		maid:GiveTask(RunService.RenderStepped:Connect(function()
			PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
		end))
	end


	--tutorial trigger
	--[[local tutorialEnabled = _Value(false)
	local mergeCountValue = Player:WaitForChild("leaderstats"):WaitForChild("Merge") :: IntValue
	if mergeCountValue then
		print("Test0")
		maid:GiveTask(mergeCountValue.Changed:Connect(function ()
			print("test1")
			if 	mergeCountValue.Value <= 3 then
				print("Tru")
				tutorialEnabled:Set(true)
			else
				print("Fals")
				tutorialEnabled:Set(false)
			end
		end))
	end]]

	local _bg = _new("BillboardGui")({
		Name = "TutorialBillboard",
		Parent = Player:WaitForChild("PlayerGui"),
		Size = UDim2.fromScale(10, 5),
		AlwaysOnTop = true,
		ExtentsOffsetWorldSpace = Vector3.new(0,3,0),
		[_CHILDREN] = {
			BlockTutorial(maid)
		} 
	}) :: BillboardGui
	local mergeCountValue = Player:WaitForChild("leaderstats"):WaitForChild("Merge") :: IntValue

	maid.TutorialService = RunService.RenderStepped:Connect(function()
		if mergeCountValue.Value <= 3 then
			local maxDist = math.huge

			local blocksData = BlocksUtil.getBlocks(Player)
			local closestBlockModel
			for _,blockData : BlocksUtil.BlockData in pairs(blocksData) do
				local blockModel = BlocksUtil.getBlockModelById(blockData.BlockId) :: Model
				if  Player.Character 
				and Player.Character.PrimaryPart 
				and blockData.Level == 1 
				and blockModel.PrimaryPart 
				and (blockModel.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude < maxDist then
					maxDist = (blockModel.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude
					closestBlockModel = blockModel
				end
			end
			_bg.Adornee = closestBlockModel
		else
			_bg.Adornee = nil :: any
			maid.TutorialService = nil
		end
	end)

	NetworkUtil.onClientEvent(TRIGGER_HATCH_ANIMATION_KEY, function(petNames : {PetName : string}, petClass : string)
		print(petNames, petClass)
		hatch(petNames, petClass)
	end)

	return nil
end

return ServiceProxy(function()
	return currentMainSys or MainSys
end)
