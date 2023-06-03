--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
-- Modules

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		local GamepassMenu = require(script.Parent)

		local A = maid:GiveTask(Signal.new())
		local B = maid:GiveTask(Signal.new())
		local C = maid:GiveTask(Signal.new())

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

		local Wallet = _Value(900)

		local menu = maid:GiveTask(GamepassMenu(nil, Wallet, _Value(1), _Value(1), _Value(1), A, B, C))

		local frame = maid:GiveTask(Instance.new("Frame"))
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.Size = UDim2.fromOffset(500, 400)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1
		frame.Parent = coreGui

		menu.Parent = frame
	end)

	return function()
		maid:Destroy()
	end
end
