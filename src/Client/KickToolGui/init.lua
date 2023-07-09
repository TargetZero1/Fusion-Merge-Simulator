--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
--modules

--types
type Maid = Maid.Maid
type Signal = Signal.Signal
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

--constants
local BACKGROUND_COLOR = Color3.fromRGB(200, 200, 200)
local TERTIARY_COLOR = Color3.fromRGB(10, 150, 10)

local TEXT_SIZE = 25
local PADDING_SIZE = UDim.new(0.05, 0)

--local functions
local function getToolButton(
	maid: Maid,
	index: number,
	kickModeState: ValueState<MainSysUtil.KickMode>,
	kickModeButton: MainSysUtil.KickMode,
	func: ((any) -> any)?
)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	return _new("TextButton")({
		Name = kickModeButton,
		LayoutOrder = index,
		Size = _Computed(function(kickModeVal: MainSysUtil.KickMode)
			return if kickModeVal == kickModeButton then UDim2.fromScale(1.1, 1.1) else UDim2.fromScale(1, 1)
		end, kickModeState):Tween(),
		AutoButtonColor = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		Font = Enum.Font.Cartoon,
		TextSize = TEXT_SIZE,
		BackgroundColor3 = Color3.fromRGB(),
		TextColor3 = _Computed(function(kickModeVal: MainSysUtil.KickMode)
			return if kickModeVal == kickModeButton then TERTIARY_COLOR else BACKGROUND_COLOR
		end, kickModeState):Tween(),
		Text = kickModeButton,
		BackgroundTransparency = 0.75,
		[_CHILDREN] = {
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1,
			}),
			_new("UICorner")({}),
			_new("UIStroke")({
				Color = _Computed(function(kickModeVal: MainSysUtil.KickMode)
					return if kickModeVal == kickModeButton then TERTIARY_COLOR else BACKGROUND_COLOR
				end, kickModeState):Tween(),
				Thickness = 2,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
			_new("TextLabel")({
				Name = "IndexDisplay",
				Font = Enum.Font.Cartoon,
				TextScaled = true,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.3, 0.3),
				Text = tostring(index),
				TextColor3 = _Computed(function(kickModeVal: MainSysUtil.KickMode)
					return if kickModeVal == kickModeButton then TERTIARY_COLOR else BACKGROUND_COLOR
				end, kickModeState):Tween(),
			}),
		},
		[_ON_EVENT("Activated")] = func,
	})
end

--Frame
return function(maid: Maid, kickMode: ValueState<MainSysUtil.KickMode>, toolSignal: Signal)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject: InputObject, gpe: boolean)
		if not gpe then
			if inputObject.KeyCode == Enum.KeyCode.One then
				toolSignal:Fire("Kick" :: MainSysUtil.KickMode)
			elseif inputObject.KeyCode == Enum.KeyCode.Two then
				toolSignal:Fire("Punt" :: MainSysUtil.KickMode)
			elseif inputObject.KeyCode == Enum.KeyCode.Three then
				toolSignal:Fire("Tap" :: MainSysUtil.KickMode)
			end
		end
	end))

	return _new("Frame")({
		Name = "ToolFrame",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.85),
		Size = UDim2.fromScale(0.25, 0.1),
		[_CHILDREN] = {
			_new("UIAspectRatioConstraint")({
				AspectRatio = 4,
			}),
			_new("UIListLayout")({
				Padding = PADDING_SIZE,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			--Tools

			getToolButton(maid, 3, kickMode, "Tap" :: MainSysUtil.KickMode, function()
				toolSignal:Fire("Tap" :: MainSysUtil.KickMode)
				return nil
			end),
			getToolButton(maid, 1, kickMode, "Kick" :: MainSysUtil.KickMode, function()
				toolSignal:Fire("Kick" :: MainSysUtil.KickMode)
				return nil
			end),
			getToolButton(maid, 2, kickMode, "Punt" :: MainSysUtil.KickMode, function()
				toolSignal:Fire("Punt" :: MainSysUtil.KickMode)
				return nil
			end),
		},
	})
end
