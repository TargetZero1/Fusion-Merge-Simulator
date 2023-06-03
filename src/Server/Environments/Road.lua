--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))

--types
type Maid = Maid.Maid

return {
	init = function(maid)
		local road = workspace:FindFirstChild("Environment"):FindFirstChild("Road")
		local clockWiseFolder = road:FindFirstChild("ClockWise")
		local counterClockWiseFolder = road:FindFirstChild("CounterClockWise")

		if clockWiseFolder and counterClockWiseFolder then
			for _, part: BasePart in pairs(clockWiseFolder:GetChildren()) do
				part.AssemblyLinearVelocity = part.CFrame.RightVector * MiscLists.MiscNumbers.RoadVelocity
				--[[maid:GiveTask(part.Touched:Connect(function(hit : BasePart)
                    local plr = Players:GetPlayerFromCharacter(hit.Parent)
                    print(plr, hit, hit.Parent)
                    if plr and hit.Parent and hit.Parent:IsA("Model") and hit.Parent.PrimaryPart then
                        print("Move1!")
                        hit.Parent.PrimaryPart.AssemblyLinearVelocity = part.CFrame.LookVector*100
                    end
                end))]]
			end

			for _, part: BasePart in pairs(counterClockWiseFolder:GetChildren()) do
				part.AssemblyLinearVelocity = -part.CFrame.RightVector * MiscLists.MiscNumbers.RoadVelocity
				--[[ maid:GiveTask(part.Touched:Connect(function(hit : BasePart)
                    local plr = Players:GetPlayerFromCharacter(hit.Parent)
                    print(plr, hit, hit.Parent)
                    if plr and hit.Parent and hit.Parent:IsA("Model") and hit.Parent.PrimaryPart then
                        print("Move2!")
                        hit.Parent.PrimaryPart.AssemblyLinearVelocity = -part.CFrame.LookVector*100
                    end
                end))]]
			end
		end
	end,
}
