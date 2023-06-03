--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local Road = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Environments"):WaitForChild("Road"))

--types
type Maid = Maid.Maid

--
return {
	init = function(maid: Maid)
		Road.init(maid)
		-- BonusBlockSpawner.init(maid)
	end,
}
