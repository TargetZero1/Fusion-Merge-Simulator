--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Gamework
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
return function(userId: number, cf: CFrame, scale: number): Model?
	local model: Model

	pcall(function()
		model = Players:CreateHumanoidModelFromUserId(userId)
	end)

	if not model then
		return nil
	end

	model.Name = tostring(userId)
	assert(model.PrimaryPart)
	model.PrimaryPart.Anchored = true

	local maid = Maid.new()
	maid:GiveTask(model.Destroying:Connect(function()
		maid:Destroy()
	end))

	local humanoid: Humanoid? = model:WaitForChild("Humanoid", 10) :: any
	assert(humanoid)
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	for i, numVal in ipairs(humanoid:GetChildren()) do
		if numVal:IsA("NumberValue") and numVal.Name ~= "BodyProportionScale" and numVal.Name ~= "BodyTypeScale" then
			numVal.Value *= scale
		end
	end

	maid:GiveTask(RunService.Heartbeat:Connect(function()
		local boundCF, boundSize = model:GetBoundingBox()
		model.WorldPivot = boundCF

		model:PivotTo(cf + Vector3.new(0, boundSize.Y / 2, 0))
	end))

	return model
end
