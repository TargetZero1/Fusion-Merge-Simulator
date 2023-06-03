--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--modoules

--variables
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent --  for text buttons similar to mousebutton event

return {
	DefaultFrame = function(props: { [any]: any })
		return New("Frame")({
			Parent = props.Parent or nil,
			Name = props.Name or nil,
			BorderSizePixel = props.BorderSizePixel or 0,
			Size = props.Size or UDim2.new(1, 0, 1, 0),
			Position = props.Position or UDim2.new(),
			BackgroundTransparency = props.BackgroundTransparency or nil,
			BackgroundColor3 = props.BackgroundColor3 or nil,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Visible = props.Visible or true,

			[Children] = {
				New("UICorner")({}),
				props[Children],
			},
		})
	end,
	BarFrame = function(props: { [any]: any })
		return New("Frame")({
			Parent = props.Parent or nil,
			Name = props.Name or nil,
			BorderSizePixel = props.BorderSizePixel or 0,
			Size = props.Size or UDim2.new(1, 0, 1, 0),
			Position = props.Position or UDim2.new(0.5, 0.5),
			BackgroundTransparency = props.BackgroundTransparency or (props and props.Image and 1 or 0),
			BackgroundColor3 = props.BackgroundColor3 or nil,
			ZIndex = props.ZIndex or 1,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Visible = props.Visible or true,
			[Children] = {
				Image = New("ImageLabel")({
					Name = "BackgroundImage",
					Image = props.Image,
					ImageTransparency = props.ImageTransparency or (props and props.Image and 0 or 1),
					ZIndex = props.ZIndex and (props.ZIndex + 1) or 2,
				}),
				RatioFrame = New("Frame")({
					Name = "RatioFrame",
					BackgroundColor3 = Color3.fromRGB(25, 200, 25),
					Size = props.ContentSize or UDim2.new(0, 0, 1, 0),
					BorderSizePixel = 0,
					ZIndex = props and props.ZIndex and (props.ZIndex + 1) or 2,
					[Children] = {
						New("UICorner")({
							CornerRadius = UDim.new(0, 10),
						}),
					},
				}),
				New("UICorner")({
					CornerRadius = UDim.new(0, 10),
				}),
				props and props[Children] or nil,
			},
		})
	end,
	ListsFrame = function(props: { [any]: any })
		return New("Frame")({
			Name = props.Name,
			Parent = props.Parent,
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.new(),
			BackgroundColor3 = props.BackgroundColor3,
			BackgroundTransparency = props.BackgroundTransparency or 0,
			ZIndex = props.ZIndex or 1,
			Visible = props.Visible or true,
			[Children] = {
				New("UIListLayout")({
					FillDirection = props.FillDirection,
					HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
					VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
					Padding = props.Padding or UDim.new(0, 10),
				}),
				New("UICorner")({}),
				props[Children],
			},
		})
	end,
	GridFrame = function(props: { [any]: any })
		return New("ScrollingFrame")({
			Name = props.Name,
			Parent = props.Parent,
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.new(),
			BackgroundTransparency = props.BackgroundTransparency or 0,
			Visible = props.Visible or true,
			CanvasSize = props.CanvasSize or UDim2.fromScale(0, 0),
			AutomaticCanvasSize = props.AutomaticCanvasSize or Enum.AutomaticSize.XY,
			[Children] = {
				New("UIGridLayout")({
					FillDirection = props.FillDirection,
					HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left,
					VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top,
					CellPadding = props.CellPadding or UDim2.fromOffset(5, 10),
					CellSize = props.CellSize or UDim2.fromOffset(100, 35),
				}),
				New("UICorner")({}),
				props[Children],
			},
		})
	end,
	ViewportFrame = function(props: { [any]: any })
		--set model pos
		if props.Model and props.Model.PrimaryPart then
			props.Model:PivotTo(CFrame.new())
		end
		--set cam
		local camera: Camera
		if props.Model and props.Model.PrimaryPart then
			camera = New("Camera")({
				CFrame = CFrame.lookAt(
					props.Model.PrimaryPart.Position
						+ props.Model.PrimaryPart.CFrame.RightVector
							* (props.Model.PrimaryPart.Size.X + (props.CameraDistance or 0)),
					props.Model.PrimaryPart.Position
				),
			})
		end
		return New("ViewportFrame")({
			Parent = props.Parent,
			Name = props.Name,
			Position = props.Position or UDim2.new(),
			Size = props.Size or UDim2.fromScale(1, 1),
			BackgroundTransparency = props.BackgroundTransparency,
			BackgroundColor3 = props.BackgroundColor3,
			LayoutOrder = props.LayoutOrder,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			ZIndex = props.ZIndex or 1,
			Visible = props.Visible or true,
			[Children] = {
				New("UICorner")({}),
				camera,
				props.Model,
				New("TextButton")({
					Text = props.Text,
					ZIndex = props.ZIndex and (props.ZIndex + 1) or 2,
					Size = UDim2.fromScale(1, 1),
					TextSize = props.TextSize or 25,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = props.TextStrokeTransparency or 0.6,
					BackgroundTransparency = 1,
					[OnEvent("Activated")] = function()
						if props.Activated then
							props.Activated()
						end
					end,
				}),
				props[Children],
			},
			CurrentCamera = camera,
		})
	end,
	ImageFrame = function(props: { [any]: any })
		return New("ImageLabel")({
			Name = props.Name,
			Parent = props.Parent,
			Image = props.Image,
			BackgroundTransparency = props.BackgroundTransparency or 1,
			BorderSizePixel = props.BorderSizePixel or 0,
			Position = props.Position,
			Size = props.Size or UDim2.fromScale(1, 1),
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			ZIndex = props.ZIndex or 2,
			[Children] = {
				props[Children],
			},
		})
	end,
	init = function(maid)
		return nil
	end,
}
