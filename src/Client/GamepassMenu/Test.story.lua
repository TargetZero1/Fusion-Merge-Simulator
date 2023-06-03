--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		local GamepassMenu = require(script.Parent)
		local menu = maid:GiveTask(GamepassMenu())

		local frame = maid:GiveTask(Instance.new("Frame"))
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.Size = UDim2.fromOffset(300, 200)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Parent = coreGui

		menu.Parent = frame
	end)

	return function()
		maid:Destroy()
	end
end
