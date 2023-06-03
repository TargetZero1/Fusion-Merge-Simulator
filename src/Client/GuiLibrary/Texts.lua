--!strict
--service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--variables
local New = Fusion.New
local Children = Fusion.Children

return {
	DefaultTextLabel = function(props: { [any]: any })
		return New("TextLabel")({
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Name = props.Name,
			Font = props.Font or Enum.Font.GothamMedium,
			LayoutOrder = props.LayoutOrder,
			TextScaled = props.TextScaled or true,
			Parent = props.Parent,
			Text = props.Text,
			BackgroundTransparency = props.BackgroundTransparency or 1,
			ZIndex = props.ZIndex or 1,
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.new(0.5, 0.5),
			TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
			TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
			TextSize = props.TextSize or 25,
			TextColor3 = props.TextColor3 or Color3.fromRGB(200, 200, 200),
			TextStrokeTransparency = props.TextStrokeTransparency or 0.5,
			BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
			TextWrapped = true or props.TextWrapped,
			[Children] = {
				New("UITextSizeConstraint")({
					MaxTextSize = props.TextSize or 25,
					MinTextSize = props.TextSize or 25,
				}),
				props[Children],
			},
		})
	end,
	init = function(maid) end,
}
