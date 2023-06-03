--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))   
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))   
--modules
local AchievementUI = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("AchievementUI"))
--types
--constants
--variables
--references
return function(target)
   --[[ local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT]]
    
    local achievementUI = AchievementUI({
        Text = "You now have block level high-ish!",
        Image = ReplicatedStorage.Assets.ObjectModels.TypeA:Clone()
    })
    achievementUI.Parent = target
end