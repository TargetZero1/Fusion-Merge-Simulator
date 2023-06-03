--!strict
-- Services
-- Packages
-- Modules
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))
-- Types
-- Constants
-- Variables
-- References
-- Class
local Util = {}

function Util.getRebirthGemRewardFromBlockLevel(
	highestBlockLevel: number, 
	nextRebirthIndex: number, 
	gemModLevel: number, 
	ownsDoubleGemRate: boolean
): number
	-- print("rebirth value", nextRebirthIndex)
	local modifier = if ownsDoubleGemRate then 2 else 1
	-- print("gamepass modifier: ", modifier)

	local gemModData = MiscLists.Limits.Perks.Gems[gemModLevel]
	local gemMod = 1
	if gemModData then
		gemMod += gemModData.Perk
		--print("gem perk resulting in a percent increase of ", gemModData.Perk * 100, "%")
	end

	local baseReward: number = MiscLists.Limits.BaseRewardOnRebirthPoint[nextRebirthIndex] or MiscLists.Limits.BaseRewardOnRebirthPoint[#MiscLists.Limits.BaseRewardOnRebirthPoint]
	--print("base reward", baseReward, "for rebirth", nextRebirthIndex)

	local highBlockBonus: number = MiscLists.Limits.VariableReward * highestBlockLevel
	--print("variable reward: ", highBlockBonus, " which is ", MiscLists.Limits.VariableReward, " x ", highestBlockLevel, "block level")

	local netModifier = modifier * gemMod
	--print("net modifier: ", netModifier, " as that is gamepass (", modifier, ") x gem perk modifier (", gemMod, ")")

	local preModSum = baseReward + highBlockBonus
	--print("pre mod sum: ", preModSum)

	local final = math.round(netModifier * preModSum)
	
	-- print("final value", final)

	return final
end

return Util