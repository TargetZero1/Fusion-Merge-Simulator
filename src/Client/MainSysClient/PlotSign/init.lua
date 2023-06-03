--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
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

export type PlotSign = {
	__index: PlotSign,
	_isActive: boolean,
	_Maid: Maid,
	_Fuse: Fuse,
	Instance: GuiObject,
	new: (userId: number, mergeCount: ValueState<string>) -> PlotSign,
	Destroy: (PlotSign) -> nil,
}

--constants
local TEXT_SIZE = 24
local BACKGROUND_COLOR = Color3.fromHSV(1, 0, 0.85)
local PROFILE_BACKGROUND_COLOR = Color3.fromRGB(25, 200, 0)

--variables
--references
--local functions
local function getTextLabel(maid: Maid, text: ValueState<string>)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _import = _fuse.import
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	return _new("TextLabel")({
		Text = text,
		--BackgroundColor3 = Color3.fromRGB(255,255,190),
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = TEXT_SIZE * 4,
		Font = Enum.Font.Cartoon,
		Size = UDim2.fromScale(0.1, 0.2),
		[_CHILDREN] = {
			_new("UICorner")({}),
		},
	})
end

local currentPlotSign: PlotSign

local PlotSign = {} :: PlotSign
PlotSign.__index = PlotSign

function PlotSign.new(userId: number, mergeCount: ValueState<string>)
	local player = Players:GetPlayerByUserId(userId)
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

	local self = setmetatable({}, PlotSign) :: any
	self._Maid = maid
	self._Fuse = _fuse

	local avatarImage = _new("ImageLabel")({
		Size = UDim2.fromScale(0.6, 0.6),
		BackgroundColor3 = PROFILE_BACKGROUND_COLOR,
		Image = ("http://www.roblox.com/Thumbs/Avatar.ashx?x=400&y=400&Format=Png&username=%s"):format(player.Name),
		[_CHILDREN] = {
			_new("UICorner")({ CornerRadius = UDim.new(1, 0) }),
			_new("UIStroke")({ Thickness = 4, Color = Color3.fromRGB(255, 255, 255) }),
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1,
			}),
		},
	})

	local userNameText = getTextLabel(maid, player.Name)

	--[[local leaderstats = player:FindFirstChild("leaderstats")
    local cashIntVal : IntValue | NumberValue = if leaderstats then leaderstats:FindFirstChild("Cash") else nil
    local cash = _Value(if cashIntVal then "$" .. cashIntVal.Value else "$" .. 0)

    --detect changes
    if cashIntVal then
        maid:GiveTask(cashIntVal:GetPropertyChangedSignal("Value"):Connect(function()
            cash:Set("$" .. tostring(cashIntVal.Value))
        end))
    end]]

	--

	self._isActive = true
	self.Instance = _new("Frame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BACKGROUND_COLOR,
		[_CHILDREN] = {
			_new("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
			}),
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
			}),
			avatarImage,
			_mount(userNameText)({
				TextSize = TEXT_SIZE * 20,
				Size = UDim2.fromScale(0.10, 0.05),
			}),
			--stats
			_mount(getTextLabel(maid, mergeCount))({
				Text = _Computed(function(mergeCountVal)
					return "Merge count: " .. (mergeCountVal or "0")
				end, mergeCount),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.2, 0.1),
				TextColor3 = PROFILE_BACKGROUND_COLOR,
				Font = Enum.Font.Cartoon,
			}),
		},
	}) :: GuiObject

	local inst = self.Instance :: GuiObject

	maid:GiveTask(inst.Destroying:Connect(function()
		self:Destroy()
	end))

	currentPlotSign = self
	return self
end

function PlotSign:Destroy()
	if not self._isActive then
		return
	end

	self._isActive = false

	if currentPlotSign == self then
		currentPlotSign = nil :: any
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
	return currentPlotSign or PlotSign
end)
