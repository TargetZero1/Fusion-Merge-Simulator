--!strict
--services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
--modules
-- local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
--module
local MonetizationUtil = {}

-- function MonetizationUtil.calculateReward(base: number, highestBlockLevel: number)
-- 	local adjustedBase = (
-- 		MiscLists.Limits.BaseRewardOnRebirthPoint[base]
-- 		or MiscLists.Limits.BaseRewardOnRebirthPoint[#MiscLists.Limits.BaseRewardOnRebirthPoint]
-- 	) :: number

-- 	print(adjustedBase, "?", base)
-- 	local variable = MiscLists.Limits.VariableReward

-- 	return math.round(adjustedBase + (variable * highestBlockLevel))
-- end

return MonetizationUtil
