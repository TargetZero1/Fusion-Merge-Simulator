--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))
--types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type GamepassData = {
	Texture: string,
	Id: number,
	Name: string,
	Color: Color3,
	Price: number,
}
type Signal = Signal.Signal
--constants
local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(100,255,100)
local TERTIARY_COLOR = Color3.fromRGB(250,250,0)

local TEXT_SIZE = 25
--variables
--references
--local functions
local function getButton(maid: Maid, text: string, onClicked: Signal?, bgColor: ValueState<Color3>?)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT

	return _new("TextButton")({
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = text,
		TextColor3 = LegibilityUtil(
			Color3.new(1, 1, 1),
			if bgColor then bgColor:Get() else Color3.fromRGB(200, 200, 200)
		),
		AutoButtonColor = true,
		BackgroundColor3 = bgColor,
		BackgroundTransparency = 0.5,
		Font = Enum.Font.Cartoon,
		Size = UDim2.fromScale(0.3, 1),
		TextSize = TEXT_SIZE * 0.8,
		RichText = true,
		[_ON_EVENT("Activated")] = function()
			if onClicked then
				onClicked:Fire()
			end
		end,
		[_CHILDREN] = {
			_new("UICorner")({}),
		},
	})
end
--module
return function(
    maid : Maid,
	OnClick : Signal
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

    local out = _new("ImageButton")({
		AutoButtonColor = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.65, 0.1),
        Size = UDim2.fromScale(0.09, 0.09),
		Image = "rbxassetid://13393642916",
		BackgroundColor3 = SECONDARY_COLOR,
        [_CHILDREN] = {
			_new("UICorner")({}),
            _new("UIAspectRatioConstraint")({}),
        },
		[_ON_EVENT("Activated")] = function()
			OnClick:Fire()
		end
    })
    return out
end