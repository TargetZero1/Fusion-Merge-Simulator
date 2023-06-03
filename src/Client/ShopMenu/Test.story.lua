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
	local OnBack = maid:GiveTask(Signal.new())
	math.randomseed(tick())

	task.spawn(function()
		local ShopMenu = require(script.Parent)
		maid:GiveTask(ShopMenu(IsVisible, OnBack, coreGui))
	end)

	return function()
		maid:Destroy()
	end
end
