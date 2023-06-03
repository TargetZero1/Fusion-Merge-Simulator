--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local Hatch = require(script.Parent)

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		maid:GiveTask(Hatch({
			{
				Model = game.ReplicatedStorage.Assets.PetModels.Dog:Clone(),
				Text = "Dog",
				Color = Color3.fromHSV(0.6, 1, 1),
				Level = 1,
			},
			{
				Model = game.ReplicatedStorage.Assets.PetModels.Dog2:Clone(),
				Text = "Dog",
				Color = Color3.fromHSV(0.6, 1, 1),
				Level = 2,
			},
			{
				Model = game.ReplicatedStorage.Assets.PetModels.Dog3:Clone(),
				Text = "Dog",
				Color = Color3.fromHSV(0.6, 1, 1),
				Level = 3,
			},
		}, "Dog"))
	end)

	return function()
		maid:Destroy()
	end
end
