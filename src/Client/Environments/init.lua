--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local BonusBlockSpawner = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environments"):WaitForChild("BonusBlockSpawner"))
local PlotSigns = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Environments"):WaitForChild("PlotSigns"))

--types
type Maid = Maid.Maid

--
return {
	init = function(maid: Maid)
		BonusBlockSpawner.init(maid)
		PlotSigns.init(maid)
	end,
}
