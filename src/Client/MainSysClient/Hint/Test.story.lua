--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

-- Modules
local Hint = require(script.Parent)

-- Types
type Maid = Maid.Maid
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		local screenGui = maid:GiveTask(
			Hint(
				Color3.fromHSV(0, 1, 0.8),
				"This is a test error message thingy. This is a test error message thingy. This is a test error message thingy. This is a test error message thingy"
			)
		)
		screenGui.Parent = coreGui
	end)

	return function()
		maid:Destroy()
	end
end
