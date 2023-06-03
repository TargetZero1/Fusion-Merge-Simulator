--!strict
--references

--service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--modules
local GuiStyleGuide = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiStyleGuide"))

--variables
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent --  for text buttons similar to mousebutton event
local State = Fusion.State --  constructor for storing values
local Computed = Fusion.Computed --  allows to dynamically grab the updated value

return {
	TextButton = function(props: { [any]: any })
		local _color = State(Color3.fromRGB(255, 255, 255))
		local _transp = State(1)

		local _gradientFrame = function(zindex, transp)
			return New("Frame")({
				ZIndex = zindex,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.new(),
				BackgroundColor3 = Color3.fromRGB(),
				BackgroundTransparency = transp or Computed(function()
					return _transp:get()
				end),
				[Children] = {
					New("UICorner")({}),
				},
			})
		end

		return New("TextButton")({
			Parent = props.Parent,
			Name = props.Name,
			Text = props.Text,
			Size = props.Size or UDim2.fromScale(1, 1),
			TextColor3 = props.TextColor3 or Color3.new(1, 1, 1),
			TextScaled = props.TextScaled or true,
			TextSize = props.TextSize or 25,
			ClipsDescendants = false,
			Position = props.Position or UDim2.new(),
			BackgroundColor3 = Computed(function()
				return props.BackgroundColor3 and props.BackgroundColor3:get() or GuiStyleGuide.Colors.Button:get()
			end),
			BackgroundTransparency = props.BackgroundTransparency or 0,
			TextStrokeTransparency = props.TextStrokeTransparency or 0.5,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			ZIndex = props.ZIndex or 3,
			[Children] = {
				New("UICorner")({}),
				Shadow = New("Frame")({
					ZIndex = props.ZIndex and (props.ZIndex - 2) or 1,
					Position = UDim2.fromScale(0, 0.08),
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Computed(function()
						return props.BackgroundColor3 and props.BackgroundColor3:get()
							or GuiStyleGuide.Colors.Button:get()
					end),
					BackgroundTransparency = props.BackgroundTransparency or 0,
					[Children] = {
						New("UICorner")({}),
						--gradient frame
						_gradientFrame(props.ZIndex and (props.ZIndex - 1) or 2, 0.9),
					},
				}),
				New("UITextSizeConstraint")({
					MaxTextSize = props.TextSize or 25,
					MinTextSize = props.TextSize or 25,
				}),
				--[[ New "UIGradient" {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.new()),
                        ColorSequenceKeypoint.new(1, Color3.new())
                    },
                    --Transparency = Computed(function() return _gradientTransp:get() end)
                } ]]
				_gradientFrame(props.ZIndex and (props.ZIndex + 1) or 4),
				props[Children],
			},
			[OnEvent("Activated")] = function()
				--fx
				if props.Activated then
					props.Activated()
				end
			end :: any,
			[OnEvent("MouseEnter")] = function()
				--fx
				_transp:set(0.9)
				--[[_gradientTransp:set(State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,0.95),
                    NumberSequenceKeypoint.new(1,0.95)
                }))]]
			end :: any,
			[OnEvent("MouseLeave")] = function()
				--fx
				_transp:set(1)
				--[[_gradientTransp.Transparency = State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,1),
                    NumberSequenceKeypoint.new(1,1)
                })]]
			end :: any,
		})
	end,

	ImageButton = function(props: { [any]: any })
		local _color = State(Color3.fromRGB(255, 255, 255))
		local _transp = State(1)

		local _gradientFrame = function(zindex, transp)
			return New("Frame")({
				ZIndex = zindex,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.new(),
				BackgroundColor3 = Color3.fromRGB(),
				BackgroundTransparency = transp or Computed(function()
					return _transp:get()
				end),
				[Children] = {
					New("UICorner")({}),
				},
			})
		end

		return New("ImageButton")({
			Parent = props.Parent,
			Name = props.Name,
			Image = props.Image,
			Size = props.Size or UDim2.fromScale(1, 1),
			ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1),
			ClipsDescendants = false,
			Position = props.Position or UDim2.new(),
			BackgroundColor3 = Computed(function()
				return props.BackgroundColor3 and props.BackgroundColor3:get() or GuiStyleGuide.Colors.Button:get()
			end),
			BackgroundTransparency = props.BackgroundTransparency or 0,
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			ZIndex = props.ZIndex or 3,
			[Children] = {
				New("UICorner")({}),
				Shadow = New("Frame")({
					ZIndex = props.ZIndex and (props.ZIndex - 2) or 1,
					Position = UDim2.fromScale(0, 0.08),
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Computed(function()
						return props.BackgroundColor3 and props.BackgroundColor3:get()
							or GuiStyleGuide.Colors.Button:get()
					end),
					BackgroundTransparency = props.BackgroundTransparency or 0,
					[Children] = {
						New("UICorner")({}),
						--gradient frame
						_gradientFrame(props.ZIndex and (props.ZIndex - 1) or 2, 0.9),
					},
				}),
				New("UITextSizeConstraint")({
					MaxTextSize = props.TextSize or 25,
					MinTextSize = props.TextSize or 25,
				}),
				--[[ New "UIGradient" {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.new()),
                        ColorSequenceKeypoint.new(1, Color3.new())
                    },
                    --Transparency = Computed(function() return _gradientTransp:get() end)
                } ]]
				_gradientFrame(props.ZIndex and (props.ZIndex + 1) or 4),
				props[Children],
			},
			[OnEvent("Activated")] = function()
				--fx
				if props.Activated then
					local success, msg = pcall(function()
						props.Activated()
					end)

					if not success then
						warn(msg)
					end
				end
			end :: any,
			[OnEvent("MouseEnter")] = function()
				--fx
				_transp:set(0.9)
				--[[_gradientTransp:set(State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,0.95),
                    NumberSequenceKeypoint.new(1,0.95)
                }))]]
			end :: any,
			[OnEvent("MouseLeave")] = function()
				--fx
				_transp:set(1)
				--[[_gradientTransp.Transparency = State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,1),
                    NumberSequenceKeypoint.new(1,1)
                })]]
			end :: any,
		})
	end,

	PlainTextButton = function(props: { [any]: any })
		return New("TextButton")({
			Parent = props.Parent,
			Name = props.Name,
			ZIndex = props.ZIndex or 2,
			Text = props.Text,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(200, 200, 200),
			TextStrokeTransparency = props.TextStrokeTransparency or 0.9,
			Position = props.Position or UDim2.new(),
			Size = props.Size or UDim2.fromScale(1, 1),
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			[OnEvent("Activated")] = function()
				--fx
				if props.Activated then
					props.Activated()
				end
			end :: any,
			[OnEvent("MouseEnter")] = function()
				--fx

				--[[_gradientTransp:set(State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,0.95),
                    NumberSequenceKeypoint.new(1,0.95)
                }))]]
			end :: any,
			[OnEvent("MouseLeave")] = function()
				--fx
				--[[_gradientTransp.Transparency = State(NumberSequence.new{
                    NumberSequenceKeypoint.new(0,1),
                    NumberSequenceKeypoint.new(1,1)
                })]]
			end :: any,
		})
	end,
	init = function(maid)
		return nil
	end,
}
