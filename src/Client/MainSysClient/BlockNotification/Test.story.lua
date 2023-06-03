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
		local BlockNotification = require(script.Parent)
		BlockNotification.init(maid)
		task.wait(1)
		BlockNotification:Fire("Testing ABC")
		task.wait(1)
		BlockNotification:Fire("Testing 123")
		task.wait(1)
		BlockNotification:Fire("Testing Do-Re-Mi")
	end)

	return function()
		maid:Destroy()
	end
end
