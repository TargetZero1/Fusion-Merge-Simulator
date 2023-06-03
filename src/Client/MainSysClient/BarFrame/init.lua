--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local ServiceProxy = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServiceProxy"))
--modules

--types
type Maid = Maid.Maid

type State<a> = ColdFusion.State<a>
type CanBeState<a> = ColdFusion.CanBeState<a>
type ValueState<a> = ColdFusion.ValueState<a>
type Fuse = ColdFusion.Fuse

export type BarFrame = {
	__index: BarFrame,
	_isActive: boolean,
	_Maid: Maid,
	_Fuse: Fuse,
	Instance: GuiObject,
	new: (
		ratioValue: ValueState<number>,
		statName: string?,
		color: ValueState<Color3>?,
		customValueDisplay: State<string>?
	) -> BarFrame,
	Destroy: (BarFrame) -> nil,
}

--constants
local TEXT_SIZE = 24
local BACKGROUND_COLOR = Color3.fromHSV(1, 0, 0.85)
local BAR_BACKGROUND_COLOR = Color3.fromRGB(25, 200, 0)

--variables
--references
local currentBarFrame: BarFrame

local BarFrame = {} :: BarFrame
BarFrame.__index = BarFrame

function BarFrame.new(
	ratioValue: ValueState<number>,
	statName: string?,
	color: ValueState<Color3>?,
	customValueDisplay: State<string>?
)
	ratioValue:Set(math.clamp(ratioValue:Get(), 0, 1)) --adjusting ratio value

	--references
	local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _import = _fuse.import
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local self = setmetatable({}, BarFrame) :: any
	self._Maid = maid
	self._Fuse = _fuse

	if color == nil then
		color = _Value(BAR_BACKGROUND_COLOR)
	end

	local DynamicRatioBarSize: State<UDim2> = _Computed(function(ratioval: number)
		return UDim2.fromScale(ratioval, 1)
	end, ratioValue):Tween(0.2)

	local DynamicRatioBarColor: State<Color3> = _Computed(function(ratioval: number, colorVal: Color3)
		local h, s, v = colorVal:ToHSV()
		return Color3.fromHSV(h, s, v - (v - ratioval))
	end, ratioValue, color):Tween(0.2)

	local ratioBar = _new("Frame")({
		Size = DynamicRatioBarSize,
		BackgroundColor3 = DynamicRatioBarColor,
		[_CHILDREN] = {
			_new("UICorner")({}),
		},
	})

	local ratioText: State<string> = _Computed(function(ratioval: number)
		return (statName or "")
			.. " "
			.. (if customValueDisplay then customValueDisplay:Get() else tostring(ratioval * 100))
	end, ratioValue)

	local textLabel = _new("TextLabel")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		TextColor3 = Color3.fromRGB(80, 80, 80),
		Font = Enum.Font.Cartoon,
		Text = ratioText,
		TextSize = TEXT_SIZE * 1.5,
	})

	self._isActive = true
	self.Instance = _new("Frame")({
		Size = UDim2.fromScale(1, 0.1),
		BackgroundColor3 = BACKGROUND_COLOR,
		[_CHILDREN] = {
			_new("UICorner")({}),
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
			}),
			ratioBar,

			textLabel,
		},
	}) :: GuiObject

	local inst = self.Instance :: GuiObject

	maid:GiveTask(inst.Destroying:Connect(function()
		self:Destroy()
	end))

	currentBarFrame = self
	return self
end

function BarFrame:Destroy()
	if not self._isActive then
		return
	end

	self._isActive = false

	if currentBarFrame == self then
		currentBarFrame = nil :: any
	end

	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

return ServiceProxy(function()
	return currentBarFrame or BarFrame
end)
