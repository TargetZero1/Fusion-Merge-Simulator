--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules

-- Types
type Maid = Maid.Maid
-- Constants
local SINGLE_BUTTON_ICON = "rbxassetid://13082575559"
local MULTI_BUTTON_ICON = "rbxassetid://12791265386"
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		local HatchBillboard = require(script.Parent)
		type PetDisplayData = HatchBillboard.PetDisplayData

		local frame = maid:GiveTask(Instance.new("Frame"))
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromOffset(200, 300)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Parent = coreGui

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

		local PetDataList = _Value({
			{
				Equipped = false,
				Level = 1,
				Name = "Cat",
				Chance = 0.33,
				Text = "Fuzzles",
				Class = "Cat",
			},
			{
				Equipped = false,
				Level = 2,
				Name = "Dog",
				Chance = 0.33,
				Text = "Spot",
				Class = "Dog",
			},
			{
				Equipped = false,
				Level = 3,
				Name = "Mouse",
				Chance = 0.33,
				Text = "Stuart",
				Class = "Mouse",
			},
			-- {
			-- 	Equipped = false,
			-- 	Level = 4,
			-- 	Name = "Dog",
			-- 	Chance = 0.33,
			-- 	Text = "Doge",
			-- 	Class = "Dog",
			-- },
		} :: any)

		local onBasicHatch = maid:GiveTask(Signal.new())
		local onTripleHatch = maid:GiveTask(Signal.new())
		local onAutoHatch = maid:GiveTask(Signal.new())

		local gui = maid:GiveTask(
			HatchBillboard(
				Vector3.new(0, 0, 0),
				PetDataList,
				onBasicHatch,
				onTripleHatch,
				onAutoHatch,
				_Value(SINGLE_BUTTON_ICON),
				_Value(MULTI_BUTTON_ICON),
				_Value(MULTI_BUTTON_ICON),
				_Value(math.random(1000) * math.random(100000)),
				_Value(true)
			)
		)
		gui.Parent = frame
	end)

	return function()
		maid:Destroy()
	end
end
