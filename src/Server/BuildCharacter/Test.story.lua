--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Gamework
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Class
return function()
	local maid = Maid.new()

	task.spawn(function()
		local BuildCharacter = require(script.Parent)
		local model = maid:GiveTask(
			BuildCharacter(42223924, CFrame.new(229, 13.909, -827) * CFrame.Angles(0, math.rad(-90), 0), 3)
		)
		if model then
			model.Parent = workspace
		end
	end)

	return function()
		maid:Destroy()
	end
end
