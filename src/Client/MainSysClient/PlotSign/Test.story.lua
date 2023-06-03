--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--modules
local PlotSign =
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("PlotSign"))

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

	local plotSign = maid:GiveTask(PlotSign.new(36744065, _Value("count")))
	plotSign.Instance.Parent = target

	return function()
		maid:Destroy()
	end
end
