--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))

-- Modules
local IndexMenu = require(script.Parent)

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

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT

	local OnBack = maid:GiveTask(Signal.new())

	local objs = _Value({ 2 })
	local pets = _Value({ "Dog", "Cat", "Mouse" })

	task.spawn(function()
		local isVisible = _Value(true)
		IndexMenu.new(maid, OnBack, objs, pets, isVisible, coreGui)
	end)

	maid:GiveTask(OnBack:Connect(function()
		print("Back!")
	end))

	task.spawn(function()
		task.wait(2)
		objs:Set({ 1, 2, 3, 4 })
	end)

	return function()
		maid:Destroy()
	end
end
