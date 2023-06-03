--!strict
--services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--types
type Maid = Maid.Maid

return {
	init = function(maid: Maid)
		for _, part: BasePart in pairs(CollectionService:GetTagged("PartButton")) do
			part.Touched:Connect(function(partTouched)
				if
					partTouched.Parent
					and partTouched.Parent:FindFirstChild("Humanoid")
					and (Players:GetPlayerFromCharacter(partTouched.Parent) == Players.LocalPlayer)
				then
					part:SetAttribute("isTouched", true)
					task.wait(1)
					part:SetAttribute("isTouched", nil)
				end
			end)
		end
		return nil
	end,
}
