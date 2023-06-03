--!strict
--service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--variables
local Player = game:GetService("Players").LocalPlayer

local New = Fusion.New
local Children = Fusion.Children

return {
	Default = function(props: { [any]: any })
		return New("BillboardGui")({
			Active = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			MaxDistance = props.MaxDistance or 30,
			Parent = props.Parent or Player.PlayerGui:FindFirstChild("BillboardGuis"),
			Adornee = props.Adornee,
			Name = props.Name,
			Size = props.Size or UDim2.new(1, 0, 1, 0),
			ExtentsOffset = props.ExtentsOffset,
			ExtentsOffsetWorldSpace = props.ExtentsOffsetWorldSpace,
			AlwaysOnTop = props.AlwaysOnTop,
			[Children] = {
				props[Children],
			},
		})
	end,
	init = function(maid) end,
}
