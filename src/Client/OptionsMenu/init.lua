--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local ExitButton = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ExitButton"))

--types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse

type ValueState<a> = ColdFusion.ValueState<a>
type State<a> = ColdFusion.State<a>
type CanBeState<a> = ColdFusion.CanBeState<a>

type Signal = Signal.Signal

--constants
-- local BACKGROUND_COLOR = Color3.fromRGB(200, 200, 200)
local PRIMARY_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_COLOR = Color3.fromRGB(100, 100, 100)
local TERTIARY_COLOR = Color3.fromRGB(10, 150, 10)
local ERROR_COLOR = Color3.fromRGB(200, 100, 100)

local TEXT_SIZE = 25
local PADDING_SIZE = UDim.new(0.05, 0)
--variables

--references

--local functions
local function getOption(maid, OptName: string, state: ValueState<boolean>, Signal: Signal)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	return _new("Frame")({
		Name = OptName,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.25),
		[_CHILDREN] = {
			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = PADDING_SIZE,
			}),
			_new("TextLabel")({
				Name = "OptTitle",
				BackgroundTransparency = 1,
				Font = Enum.Font.Cartoon,
				Size = UDim2.fromScale(0.75, 1),
				Text = OptName,
				TextSize = TEXT_SIZE,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			_new("TextButton")({
				Name = "Button",
				Font = Enum.Font.Cartoon,
				AutoButtonColor = true,
				BackgroundColor3 = _Computed(function(stateVal)
					return if stateVal then TERTIARY_COLOR else ERROR_COLOR
				end, state):Tween(),
				BackgroundTransparency = 0,
				Size = UDim2.fromScale(0.2, 1),
				TextColor3 = PRIMARY_COLOR,
				Text = _Computed(function(stateVal: boolean)
					return if stateVal then "On" else "Off"
				end, state),
				TextSize = TEXT_SIZE,
				[_CHILDREN] = {
					_new("UICorner")({}),
				},
				[_ON_EVENT("Activated")] = function()
					Signal:Fire()
				end,
			}),
		},
	})
end

--module
return function(
	maid: Maid,

	MusicState: ValueState<boolean>,
	SoundFXState: ValueState<boolean>,
	PlotPublicState: ValueState<boolean>,

	MusicOptEvent: Signal,
	SoundFXEvent: Signal,
	PlotPublicEvent: Signal,
	OnBack: Signal
)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local out = _new("Frame")({
		Name = "OptionsMenu",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = PRIMARY_COLOR,
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		[_CHILDREN] = {
			_new("UICorner")({}),
			_new("UIAspectRatioConstraint")({}),
			_new("UIStroke")({
				Color = SECONDARY_COLOR,
				Thickness = 2,
			}),
			_new("UIPadding")({
				PaddingBottom = PADDING_SIZE,
				PaddingTop = PADDING_SIZE,
				PaddingLeft = PADDING_SIZE,
				PaddingRight = PADDING_SIZE,
			}),
			_new("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = PADDING_SIZE,
			}),
			--menu frames
			_new("Frame")({
				Name = "Title",
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.08),
				[_CHILDREN] = {
					_new("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = PADDING_SIZE,
					}),
					_new("ImageLabel")({
						Name = "Title",
						LayoutOrder = 1,
						Image = "rbxassetid://5078636253",
						BackgroundTransparency = 0.5,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0.15, 0),
						[_CHILDREN] = {
							_new("UIAspectRatioConstraint")({}),
						},
					}),
					_new("TextLabel")({
						Name = "Title",
						LayoutOrder = 2,
						Font = Enum.Font.Cartoon,
						Text = tostring("Settings"):upper(),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = TEXT_SIZE * 2,
						TextColor3 = SECONDARY_COLOR,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.85, 1),
						Position = UDim2.fromScale(0.15, 0),
					}),
				},
			}),
			_new("Frame")({
				Name = "Content1",
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.55),
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingBottom = PADDING_SIZE,
						PaddingTop = PADDING_SIZE,
						PaddingLeft = PADDING_SIZE,
						PaddingRight = PADDING_SIZE,
					}),
					_new("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = PADDING_SIZE,
					}),
					getOption(maid, "Music Option", MusicState, MusicOptEvent),
					getOption(maid, "Sound Effects", SoundFXState, SoundFXEvent),
					getOption(maid, "Plot Public Access", PlotPublicState, PlotPublicEvent),
					_new("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.25),
					}),
				},
			}),
			_new("Frame")({
				Name = "Content2",
				LayoutOrder = 2,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = SECONDARY_COLOR,
				Size = UDim2.fromScale(1, 0.3),
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingBottom = PADDING_SIZE,
						PaddingTop = PADDING_SIZE,
						PaddingLeft = PADDING_SIZE,
						PaddingRight = PADDING_SIZE,
					}),
					_new("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = PADDING_SIZE,
					}),
					_new("TextLabel")({
						Text = "",
						Font = Enum.Font.Cartoon,
						Size = UDim2.fromScale(1, 1),
					}),
				},
			}),
			--_new("")
		},
	}) :: GuiObject

	maid:GiveTask(ExitButton(out, function()
		OnBack:Fire()
		maid:Destroy()
	end, _Value(true)))

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end
