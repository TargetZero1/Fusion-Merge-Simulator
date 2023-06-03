--!strict
--service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--variables
local State = Fusion.State --  constructor for storing values

local GUIStyleGuide = {}

GUIStyleGuide.Colors = {
	Button = State(Color3.fromRGB(10, 100, 255)),
}

return GUIStyleGuide
