--!strict
--references

--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local Buttons = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"):WaitForChild("Buttons"))
local Frames = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"):WaitForChild("Frames"))
local BillboardGui =
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"):WaitForChild("BillboardGui"))
local Texts = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"):WaitForChild("Texts"))

return {
	Buttons = Buttons,
	Frames = Frames,
	BillboardGui = BillboardGui,
	Texts = Texts,

	init = function(maid)
		Buttons.init(maid)
		Frames.init(maid)
		BillboardGui.init(maid)
		Texts.init(maid)
	end,
}
