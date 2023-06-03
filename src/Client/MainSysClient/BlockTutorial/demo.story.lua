--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local BlockTutorial =
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("BlockTutorial"))

--types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type Signal = Signal.Signal


return function(target)
	local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = ColdFusion.new
	local _import = ColdFusion.import
	local _mount = ColdFusion.mount

	local _Value = ColdFusion.Value
	local _Computed = ColdFusion.Computed

	local _CHILDREN = ColdFusion.CHILDREN
	local _ON_EVENT = ColdFusion.ON_EVENT
	local _ON_PROPERTY = ColdFusion.ON_PROPERTY

	local blockTutorial = maid:GiveTask(BlockTutorial(maid))
	blockTutorial.Parent = target

	return function()
		maid:Destroy()
	end
end
