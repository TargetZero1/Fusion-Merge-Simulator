--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--modules
local BarFrame =
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("BarFrame"))

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

	local ratio = _Value(0.8)
	local bgColor = _Value(Color3.fromRGB(255, 255, 0))

	local barFrame = maid:GiveTask(BarFrame.new(ratio, "⚡", bgColor))
	barFrame.Instance.Parent = target

	task.delay(0.5, function()
		ratio:Set(0.2)
	end)
	return function()
		maid:Destroy()
	end
end
