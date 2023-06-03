--!strict
-- Service
local RunService = game:GetService("RunService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ServiceProxy"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type ParameterValue<T> = (State<T> | T)

export type NotificationFrameParameters = {
	AnchorPoint: ParameterValue<Vector2>?,
	Size: ParameterValue<UDim2>?,
	Position: ParameterValue<UDim2>?,
	Parent: ParameterValue<GuiObject>?,
}
export type NotificationFrame = {
	__index: NotificationFrame,
	_IsAlive: boolean,
	_Maid: Maid,
	Index: number,
	Destroy: (self: NotificationFrame) -> nil,
	Frame: Frame,
	Instance: ScreenGui,
	_OpenNotifications: { [string]: boolean },
	Fire: (
		self: NotificationFrame,
		text: string,
		lifetime: number?
		-- buttonText: string?,
		-- bindableEvent: (BindableEvent | RemoteEvent)?
	) -> nil,
	new: () -> NotificationFrame,
	init: (Maid) -> nil,
}

-- Constants
local BACKGROUND_COLOR = Color3.fromHSV(0, 0, 0.9)

-- References
local currentNotificationFrame: NotificationFrame

-- Class
local NotificationFrame: NotificationFrame = {} :: any
NotificationFrame.__index = NotificationFrame

function NotificationFrame:Destroy()
	if not self._IsAlive then
		return
	end
	if currentNotificationFrame == self then
		currentNotificationFrame = nil :: any
	end
	self._IsAlive = false
	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function NotificationFrame:Fire(text: string, lifetime: number?)
	if not self._IsAlive then
		return
	end
	if self._OpenNotifications[text] then
		return
	end
	self.Index += 1

	local maid = Maid.new()
	self._Maid:GiveTask(maid)
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

	self._OpenNotifications[text] = true

	local Transparency = _Value(1)

	_new("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0, 0),
		BackgroundColor3 = BACKGROUND_COLOR,
		BackgroundTransparency = Transparency:Tween(),
		LayoutOrder = 1000000 - self.Index,
		Parent = self.Frame,
		[_CHILDREN] = {
			_new("TextLabel")({
				Name = "Text",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				RichText = true,
				Font = Enum.Font.Cartoon,
				Text = text,
				TextTransparency = Transparency:Tween(),
				TextSize = 20,
				TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
				TextScaled = false,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 0),
			}),
			_new("UICorner")({
				CornerRadius = UDim.new(0, 6),
			}),
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
				Transparency = Transparency:Tween(),
				Color = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
			}),
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		} :: { [number]: any },
	})

	Transparency:Set(0)

	task.delay(lifetime or string.len(text) / 10, function()
		pcall(function()
			self._OpenNotifications[text] = nil
			if self._IsAlive then
				Transparency:Set(1)
				task.wait(0.5)
			else
				maid:Destroy()
			end
		end)
	end)
	return nil
end

function NotificationFrame.new()
	local maid = Maid.new()
	local _buildMaid = Maid.new()
	maid:GiveTask(_buildMaid)

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

	local frame = _new("Frame")({
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(0.5, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1000,
		Name = "NotificationFrame",
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
		} :: { [number]: any },
	}) :: Frame

	local self: NotificationFrame = setmetatable({}, NotificationFrame) :: any
	self._IsAlive = true
	self._Maid = maid
	self.Index = 0
	self._OpenNotifications = {}
	self.Frame = frame
	self.Instance = _new("ScreenGui")({
		Name = "NotificationGui",
		Parent = if RunService:IsRunning()
			then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			else game:GetService("StarterGui"),
		[_CHILDREN] = {
			frame,
		},
	}) :: ScreenGui

	self._Maid:GiveTask(self.Instance.Destroying:Connect(function()
		self:Destroy()
	end))
	currentNotificationFrame = self

	return self
end

function NotificationFrame.init(maid: Maid)
	maid:GiveTask(NotificationFrame.new())

	return nil
end

return ServiceProxy(function()
	return currentNotificationFrame or NotificationFrame
end)
