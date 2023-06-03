--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--references

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local EffectsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EffectsUtil"))

local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local GuiLibrary = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"))
local PetInventory = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PetInventory"))
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))

local IndexMenu = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("IndexMenu"))
local OptionsMenu = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("OptionsMenu"))
local ShopMenu = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ShopMenu"))
local KickToolGui = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("KickToolGui"))
local DailyRewardsMenu = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("DailyRewardsMenu"))
local DailyRewardMainMenu = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("DailyRewardsMenu"):WaitForChild("MainButton"))
local AchievementUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("AchievementUI"))

--types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type PetData = PetsUtil.PetData
type MenuOption = ("PetInventory" | "Index" | "OptionsMenu" | "ShopMenu" | "DailyRewardsMenu" | nil)

--variables
local Player = game:GetService("Players").LocalPlayer
local New = Fusion.New

--constants
local GET_PET_DATA = "GetPetData"
local GET_PET_MAX_EQUIP = "GetPetMaxEquip"
local ON_PET_DATA_UPDATE = "OnPetDataUpdate"
local HARD_RESET = "HardReset"
local GET_INDEX = "GetIndex"

local ON_OBJECT_INDEX_UPDATE = "OnObjectIndexUpdate"
local ON_PET_INDEX_UPDATE = "OnPetIndexUpdate"
local ON_OBJECT_INDEX_ACHIEVEMENT = "OnObjectIndexAchievement"

local ON_KICK_MODE_UPDATE = "OnKickModeUpdate"

local ON_MERGE = "OnMerge"
local ON_KICK_MODE_SWITCH = "OnKickModeSwitch"
local ON_PUBLIC_PLOT_SWITCH = "OnPublicPlotSwitch"

local ON_PET_MAX_EQUIP_UPDATE = "OnPetMaxEquipUpdate"
local ON_DAILY_REWARDS_DATA_UPDATE = "OnDailyRewardsDataUpdate"

local ON_REWARD_CLAIM = "OnRewardClaim"
local ON_CLAIMED_DAILY_REWARDS_UPDATE = "OnClaimedDailyRewardsUpdate"
local ON_TICK_UPDATE = "OnTickUpdate"

local ON_GUI_PROFIT = "OnGuiProfit"

-- references
local target : GuiObject = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

--functions
return {
	init = function(maid: Maid)
		--[PETS INVENTORY]
		--vars

		local _fuse = ColdFusion.fuse(maid)
		local _new = _fuse.new
		local _mount = _fuse.mount
		local _import = _fuse.import

		local _Value = _fuse.Value
		local _Computed = _fuse.Computed

		local _OUT = _fuse.OUT
		local _REF = _fuse.REF
		local _CHILDREN = _fuse.CHILDREN
		local _ON_EVENT = _fuse.ON_EVENT
		local _ON_PROPERTY = _fuse.ON_PROPERTY

		local MenuSelection: ValueState<MenuOption> = _Value(nil) :: any

		--PET INVENTORY OPTIONS FRAME
		--local IsPetInventoryVisible = _Computed(function(selection: MenuOption)
		--return selection == "PetInventory"
		--end, MenuSelection)
		local PetInventoryIndexSelection: ValueState<GuiObject?> = _Value(nil) :: any
		local Selection: ValueState<PetData?> = _Value(nil) :: any
		local Pets = _Value(NetworkUtil.invokeServer(GET_PET_DATA))
		local EquipLimit = _Value(NetworkUtil.invokeServer(GET_PET_MAX_EQUIP))

		maid:GiveTask(NetworkUtil.onClientEvent(ON_PET_DATA_UPDATE, function(petDataList: { [number]: PetData })
			--[[local pets = Pets:Get()
			for k,petData in pairs(petDataList) do
				local petDataFound
				for petsKey, previousPetData : PetData in pairs(pets) do
					if previousPetData.PetId == petData.PetId then
						petDataFound = previousPetData
						pets[petsKey] = petData
						--[[previousPetData.Equipped = petData.Equipped
						previousPetData.Class = petData.Class
						previousPetData.Level = petData.Level
						previousPetData.]]

					--[[end
				end
				if not petDataFound then
					table.insert(pets, petData)
				end
			end

			local petsToBeRemoved = {}
			for petsKey, previousPetData : PetData in pairs(pets) do
				local petDataFound
				for k, petData in pairs(petDataList) do
					if previousPetData.PetId == petData.PetId then
						petDataFound = previousPetData
					end
				end
				if not petDataFound then
					table.insert(petsToBeRemoved, previousPetData)
					--pets[petsKey] = nil
				end
			end

			for _,v in pairs(petsToBeRemoved) do
				local index = table.find(pets, v)
				if index then
					table.remove(pets, index)
				end
			end]]

			Pets:Set(petDataList)
		end))

		local OnPetBack = maid:GiveTask(Signal.new())
		local OnPetEquip = maid:GiveTask(Signal.new())
		local OnPetDelete = maid:GiveTask(Signal.new())
		local OnMerge = maid:GiveTask(Signal.new())

		--maid:GiveTask(PetInventory(Selection, Pets, PetInventoryIndexSelection, OnPetBack, OnPetEquip, OnPetDelete, OnMergeIndex, target)) -- pet inventory

		maid:GiveTask(OnPetBack:Connect(function()
			-- print("OnPetBack")
			MenuSelection:Set(nil)
			Selection:Set(nil)
		end))

		maid:GiveTask(OnPetEquip:Connect(function(petData: PetData?)
			if petData and petData.PetId then
				local petModel = PetsUtil.getPetModelById(petData.PetId)

				if petModel then
					NetworkUtil.invokeServer("Equip", petModel)

					petModel = PetsUtil.getPetModelById(petData.PetId) --re-grabbing since the pet model is different when it is updated
					Selection:Set(PetsUtil.getPetData(petModel))
				end
			end
		end))

		maid:GiveTask(OnPetDelete:Connect(function(petData: PetData?)
			--[[if petData and petData.PetId then
				local petModel = PetsUtil.getPetModelById(petData.PetId)

				if petModel then
					NetworkUtil.invokeServer("Destroy", petModel)
					Selection:Set(nil)
				end
			end]]
		end))

		local OnIndexBack = Signal.new()

		local ObjectsIndex = _Value(NetworkUtil.invokeServer(GET_INDEX, "Object"))

		local PetsIndex = _Value(NetworkUtil.invokeServer(GET_INDEX, "Pet"))

		local truVal = _Value(true)
		local _isIndexMenuVisible = _Computed(function(selection)
			if selection == "Index" then
				local indexMaid = Maid.new()
				IndexMenu.new(indexMaid, OnIndexBack, ObjectsIndex, PetsIndex, truVal, target :: Frame)
				if MenuSelection:Get() == selection then
					maid._indexMenu = indexMaid
				else
					indexMaid:Destroy()
					maid._indexMenu = nil
				end
			else
				maid._indexMenu = nil
			end
			return selection == "Index"
		end, MenuSelection)
		local _isPetMenuVisible = _Computed(function(selection)
			-- print("Selection:", selection)
			if selection == "PetInventory" then
				
				local petInventoryMaid = Maid.new()
				petInventoryMaid:GiveTask(
					PetInventory(
						petInventoryMaid,
						Selection,
						Pets,
						EquipLimit,
						PetInventoryIndexSelection,
						OnPetBack,
						OnPetEquip,
						OnPetDelete,
						OnMerge,
						target
					)
				) -- pet inventory
				if MenuSelection:Get() == selection then
					maid._petInventoryMenu = petInventoryMaid
					--EquipLimit:Set(NetworkUtil.invokeServer(GET_PET_MAX_EQUIP)) --RIPE OF BUGS, MIGHT REVAMP GUI OPTISON SOON AFTERWARDS
					---- print("cause 1")
				else
					petInventoryMaid:Destroy()
					maid._petInventoryMenu = nil
				end

				--updating the equip limit
				EquipLimit:Set(NetworkUtil.invokeServer(GET_PET_MAX_EQUIP))
			else
				maid._petInventoryMenu = nil
			end
			return selection == "PetInventory"
		end, MenuSelection)

		maid:GiveTask(NetworkUtil.onClientEvent(ON_OBJECT_INDEX_UPDATE, function(objectsIndex)
			ObjectsIndex:Set(objectsIndex)
			return nil
		end))
		maid:GiveTask(NetworkUtil.onClientEvent(ON_PET_INDEX_UPDATE, function(petsIndex)
			PetsIndex:Set(petsIndex)
			return nil
		end))
		maid:GiveTask(NetworkUtil.onClientEvent(ON_OBJECT_INDEX_ACHIEVEMENT, function(blockLevel : number)
			local blockModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ObjectModels"):WaitForChild("TypeA"):Clone()
			BlocksUtil.applyBlockData(blockModel, BlocksUtil.newBlockData(game:GetService("Players").LocalPlayer.UserId, blockLevel, false))
			BlocksUtil.BlockLeveLVisualUpdate(blockModel)

			local achievementUI = AchievementUI({
				Text = "Unlocked Block Level " .. FormatUtil.formatNumber(blockLevel) .. " !!" ,
				Image = blockModel
			}, 5)
			achievementUI.Parent = target
			return nil
		end))

		maid:GiveTask(OnIndexBack:Connect(function()
			-- print("OnIndexBack")
			MenuSelection:Set(nil)
		end))

		maid:GiveTask(OnMerge:Connect(function(petDatas: { PetData })
			local success = NetworkUtil.invokeServer(ON_MERGE, petDatas)
			if success then
				-- print("On merge")
				MenuSelection:Set(nil)
				MenuSelection:Set("PetInventory")
				--merge anim (future?)
			end
		end))

		--opts menu
		local MusicState = _Value(true)
		local SoundFXState = _Value(true)
		local PlotPublicState = _Value(true)

		local music = workspace:WaitForChild("Background Music", 10)
		_Computed(function(musicStateVal: boolean)
			if music and music:IsA("Sound") then
				task.wait()
				music.Volume = if musicStateVal then 1 else 0
			end
			return nil
		end, MusicState)

		_Computed(function(soundFXStateVal: boolean)
			if not soundFXStateVal then
				maid.SoundRemoveSignal = game.DescendantAdded:Connect(function(sound: Sound)
					if sound:IsA("Sound") then
						sound.Volume = 0
					end
				end)
			else
				maid.SoundRemoveSignal = nil
			end
			return nil
		end, SoundFXState)

		_Computed(function(plotPublicStateVal: boolean)
			--if plotPublicStateVal then
			--else
			local plotModel = NetworkUtil.invokeServer(ON_PUBLIC_PLOT_SWITCH, plotPublicStateVal)
			--end
			local specialSeparators = plotModel:FindFirstChild("SpecialSeparators")
			if plotModel and specialSeparators and specialSeparators:IsA("Model") then
				for _, v in pairs(specialSeparators:GetChildren()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
			return nil
		end, PlotPublicState)

		local MusicOptEvent = maid:GiveTask(Signal.new())
		local SoundFXEvent = maid:GiveTask(Signal.new())
		local PlotPublicEvent = maid:GiveTask(Signal.new())
		local OnOptionsMenuBack = maid:GiveTask(Signal.new())

		local _isOptionsMenuVisible = _Computed(function(selection)
			if selection == "OptionsMenu" then
				local optionsMenuMaid = Maid.new()
				local optsMenu = optionsMenuMaid:GiveTask(
					OptionsMenu(
						optionsMenuMaid,
						MusicState,
						SoundFXState,
						PlotPublicState,
						MusicOptEvent,
						SoundFXEvent,
						PlotPublicEvent,
						OnOptionsMenuBack
					)
				) -- pet inventory
				optsMenu.Parent = target

				if MenuSelection:Get() == selection then
					maid._optionsMenu = optionsMenuMaid
				else
					optionsMenuMaid:Destroy()
					maid._optionsMenu = nil
				end
			else
				maid._optionsMenu = nil
			end
			return selection == "OptionsMenu"
		end, MenuSelection)

		maid:GiveTask(MusicOptEvent:Connect(function()
			MusicState:Set(not MusicState:Get())
		end))
		maid:GiveTask(SoundFXEvent:Connect(function()
			SoundFXState:Set(not SoundFXState:Get())
		end))
		maid:GiveTask(PlotPublicEvent:Connect(function()
			PlotPublicState:Set(not PlotPublicState:Get())
		end))

		maid:GiveTask(OnOptionsMenuBack:Connect(function()
			-- print("OnOptionsMenuBack")
			MenuSelection:Set(nil)
		end))

		--shop menu
		local OnShopMenuBack = maid:GiveTask(Signal.new())
		local _isShopMenuVisible = _Computed(function(selection)
			if selection == "ShopMenu" then
				local shopMenuMaid = Maid.new()
				shopMenuMaid:GiveTask(ShopMenu(_Value(true), OnShopMenuBack, target))
				if MenuSelection:Get() == selection then
					maid._shopMenu = shopMenuMaid
				else
					shopMenuMaid:Destroy()
					maid._shopMenu = nil
				end
			else
				maid._shopMenu = nil
			end
			return selection == "ShopMenu"
		end, MenuSelection)
		maid:GiveTask(OnShopMenuBack:Connect(function()
			-- print("OnShopMenuBack")
			MenuSelection:Set(nil)
		end))

		--daily rewards menu
		local isDailyRewardsMenuVisible = _Value(false)
		local rewardTypes = _Value({})
		local claimedRewards = _Value({})
		local tickStart = _Value(DateTime.now().UnixTimestamp)
		local onRewardClick = maid:GiveTask(Signal.new())
		local dailyRewardsMenu = DailyRewardsMenu(
			maid,
			
			rewardTypes,
			claimedRewards,
			
			isDailyRewardsMenuVisible,

			tickStart,

			onRewardClick
		)
		dailyRewardsMenu.Parent = target

		maid:GiveTask(onRewardClick:Connect(function(rewardType : DailyRewards.RewardType)
			-- print("Claiming ", rewardType.RewardName, " reward")
			NetworkUtil.invokeServer(ON_REWARD_CLAIM, rewardType)
		end))

		do
			local onRewardMainButtonClick = maid:GiveTask(Signal.new())

			local mainButton = maid:GiveTask(DailyRewardMainMenu(maid, onRewardMainButtonClick))
			mainButton.Parent = target

			maid:GiveTask(onRewardMainButtonClick:Connect(function()
				isDailyRewardsMenuVisible:Set(not isDailyRewardsMenuVisible:Get())
			end))
		end
		
		--MAIN MENU
		_new("Frame")({
			Name = "MainMenu",
			Parent = target,
			BackgroundTransparency = 1,
			Visible = true,
			Position = UDim2.fromScale(0.05, 0.4),
			Size = UDim2.fromScale(0.20, 0.20),
			[_CHILDREN] = {
				_new("UIGridLayout")({
					CellPadding = UDim2.fromScale(0.05, 0.05),
					CellSize = UDim2.fromScale(0.46, 0.46),
					FillDirection = Enum.FillDirection.Vertical,
				}),
				New("UIAspectRatioConstraint")({
					AspectRatio = 1,
				}),
				--index
				GuiLibrary.Buttons.ImageButton({
					Name = "IndexMenu",
					Image = MiscLists.AssetIdLists.ImageIds.IndexIcon, --"rbxassetid://12666024011",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.5),
					Activated = function()
						-- print("IndexMenu activated")
						if MenuSelection:Get() == "Index" then
							MenuSelection:Set(nil)
						else
							MenuSelection:Set("Index")
						end
					end,
					[_CHILDREN] = {
						New("UIAspectRatioConstraint")({
							AspectRatio = 1,
						}),
					},
				}),
				--pet
				GuiLibrary.Buttons.ImageButton({
					Name = "PetMenu",
					Image = MiscLists.AssetIdLists.ImageIds.PetInventoryIcon,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.5),
					Activated = function()
						-- print("PetInventory activated")
						if MenuSelection:Get() == "PetInventory" then
							MenuSelection:Set(nil)
						else
							MenuSelection:Set("PetInventory")
						end
					end,
					[_CHILDREN] = {
						New("UIAspectRatioConstraint")({
							AspectRatio = 1,
						}),
					},
				}),
				--opts menu
				GuiLibrary.Buttons.ImageButton({
					Name = "OptionsMenu",
					Image = MiscLists.AssetIdLists.ImageIds.SettingsIcon,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.5),
					Activated = function()
						-- print("OptionsMenu activated")
						if MenuSelection:Get() == "OptionsMenu" then
							MenuSelection:Set(nil)
						else
							MenuSelection:Set("OptionsMenu")
						end
					end,
					[_CHILDREN] = {
						New("UIAspectRatioConstraint")({
							AspectRatio = 1,
						}),
					},
				}),
				GuiLibrary.Buttons.ImageButton({
					Name = "ShopMenu",
					Image = MiscLists.AssetIdLists.ImageIds.ShopIcon,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.5),
					Activated = function()
						-- print("ShopMenu activated")
						if MenuSelection:Get() == "ShopMenu" then
							MenuSelection:Set(nil)
						else
							MenuSelection:Set("ShopMenu")
						end
					end,
					[_CHILDREN] = {
						New("UIAspectRatioConstraint")({
							AspectRatio = 1,
						}),
					},
				}),
			},
		})

		--developer reset
		_new("TextButton")({
			Name = "DeveloperReset",
			Parent = target,
			Text = "Hard Reset",
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			Visible = (Player:GetRankInGroup(11827920) == 255),
			Position = UDim2.fromScale(0.9, 0.5),
			Size = UDim2.fromScale(0.1, 0.1),
			[_ON_EVENT("Activated")] = function()
				NetworkUtil.invokeServer(HARD_RESET)
			end,
			[_CHILDREN] = {
				New("UIAspectRatioConstraint")({
					AspectRatio = 1,
				}),
				_new("UICorner")({}),
			},
		})

		--kick mode tools
		--states
		local kickMode: ValueState<MainSysUtil.KickMode> = _Value("Kick" :: any)

		local toolSignal = maid:GiveTask(Signal.new())

		local toolGui = maid:GiveTask(KickToolGui(maid, kickMode, toolSignal))
		toolGui.Parent = target

		toolSignal:Connect(function(kickModeVal: MainSysUtil.KickMode)
			NetworkUtil.invokeServer(ON_KICK_MODE_SWITCH, kickModeVal)
		end)

		--check
		maid:GiveTask(NetworkUtil.onClientEvent(ON_KICK_MODE_UPDATE, function(kickModeVal: MainSysUtil.KickMode)
			kickMode:Set(kickModeVal)
			return nil
		end))

		maid:GiveTask(NetworkUtil.onClientEvent(ON_PET_MAX_EQUIP_UPDATE, function(maxEquippedNum: number)
			EquipLimit:Set(maxEquippedNum)
			-- print("cause 2")

			return nil
		end))

		maid:GiveTask(NetworkUtil.onClientEvent(ON_DAILY_REWARDS_DATA_UPDATE, function(dailyRewardsData : {DailyRewards.RewardType})
			rewardTypes:Set(dailyRewardsData)
		end))
		maid:GiveTask(NetworkUtil.onClientEvent(ON_CLAIMED_DAILY_REWARDS_UPDATE, function(claimedRewardsData : {DailyRewards.ClaimedRewardData})
			claimedRewards:Set(claimedRewardsData)
		end))
		maid:GiveTask(NetworkUtil.onClientEvent(ON_TICK_UPDATE, function(tickNumber : number)
			tickStart:Set(tickNumber)
		end))
		

		maid:_GiveTask(NetworkUtil.onClientEvent(ON_GUI_PROFIT, function(profit : number)
			local ScreenGui = Player.PlayerGui:FindFirstChild("ScreenGui") :: ScreenGui
			local Stats = ScreenGui:FindFirstChild("Stats") 

			local mouse = Player:GetMouse() :: Mouse
			if Player.Character and Stats then
				
				local raycast = Ray.new(Player.Character.PrimaryPart.Position, mouse.Hit.Position - Player.Character.PrimaryPart.Position) :: Ray
				for i = 1, 10, 1 do
					task.spawn(function()
						EffectsUtil.GainProfitFX(
							mouse.Hit.Position,
							Stats:FindFirstChild("CashFrame") :: GuiObject,
							ScreenGui
						)
					end)
					
				end
			end
		end))
		--kick button
		--[[if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then --if it is on phone
			GuiLibrary.Buttons.TextButton({
				Text = "Kick",
				Parent = target,
				Size = UDim2.fromScale(0.1, 0.04),
				BackgroundColor3 = State(Color3.fromRGB(100, 100, 250)),
				Position = UDim2.fromScale(0.5, 0.85),
				Activated = function()
					NetworkUtil.invokeServer("KickBlocks")
				end,
			})
		elseif UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then -- else if it is on PC
			UserInputService.InputBegan:Connect(function(input: InputObject, _gameProcessed: boolean)
				if input.KeyCode == Enum.KeyCode.R then
					NetworkUtil.invokeServer("KickBlocks")
				end
			end)
		end]]


		

		return nil
	end,
}
