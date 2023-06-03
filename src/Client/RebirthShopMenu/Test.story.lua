--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
-- Modules
local PlayerDataType =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local RebirthUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RebirthUtil"))	
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
-- Types
type Maid = Maid.Maid
type PerkType = PlayerDataType.PerkType
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()
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

	local IsVisible = _Value(true)

	local GemValue = _Value(555)
	local RebirthValue = _Value(2)
	local HighestBlockLevel = _Value(2)
	local CashValue = _Value(1200)
	local PerkState: ColdFusion.ValueState<{ [PerkType]: number }> = _Value({
		["Cash" :: PerkType] = 1,
		["Gems" :: PerkType] = 1,
		["PetEquip" :: PerkType] = 1,
		["KickPower" :: PerkType] = 1,
		["BonusBlock" :: PerkType] = 1,
	})

	local testAsGamepassOwner = false
	-- print("Simulating for user with"..(if testAsGamepassOwner then "" else "out").." 2x gem-rate gamepass")
	-- for rebirthCount=1,10 do
	-- 	for gemModLevel=0, 5 do
	-- 		print("\nREBIRTH LEVEL: ", rebirthCount, "GEM LEVEL: ", gemModLevel)
	-- 		for maxLevel=15, 16 do
	local blockLevel = 15
	local gemPerkLevel = 0
	for rebirth=1, 6 do
		gemPerkLevel = rebirth-1
		print("\nrebirth", rebirth, "perk level", gemPerkLevel)
		local reward = RebirthUtil.getRebirthGemRewardFromBlockLevel(
			blockLevel, 
			rebirth, 
			gemPerkLevel,
			testAsGamepassOwner
		)
		local rewardText = FormatUtil.formatNumber(reward)
		warn("reward", rewardText)
	end

	-- 		end
	-- 	end
	-- end

	local OnBack = maid:GiveTask(Signal.new())

	local OnRebirthSignal = maid:GiveTask(Signal.new())

	local onPerksClicked = maid:GiveTask(Signal.new())

	math.randomseed(tick())

	task.spawn(function()
		local ShopMenu = require(script.Parent)
		local menu = maid:GiveTask(
			ShopMenu(
				IsVisible,
				GemValue,
				RebirthValue,
				HighestBlockLevel,
				CashValue,
				PerkState,
				OnBack,
				OnRebirthSignal,
				onPerksClicked
			)
		)

		menu.Parent = coreGui
	end)

	maid:GiveTask(OnRebirthSignal:Connect(function()
		print("Rebirth!")
	end))

	maid:GiveTask(onPerksClicked:Connect(function(perk: string)
		print(perk)
	end))

	return function()
		maid:Destroy()
	end
end
