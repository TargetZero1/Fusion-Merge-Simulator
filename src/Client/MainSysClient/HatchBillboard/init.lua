--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local CurveUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("CurveUtil"))
local GeometryUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GeometryUtil"))

-- Modules
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type List<T> = TableUtil.List<T>
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type PetData = PetsUtil.PetData
type Signal = Signal.Signal

export type PetDisplayData = PetData & {
	Chance: number,
	Text: string,
}

-- Constants
local SCALE = 1.5
local BACKGROUND_COLOR = Color3.fromHSV(1, 0, 0.7)
local MIN_VIEWING_DISTANCE = 30 --50
local MAX_VIEWING_DISTANCE = 50 --150
local ROBUX_ICON_CHAR = utf8.char(0xE002)

-- Variables
-- References
local AssetFolder = ReplicatedStorage:WaitForChild("Assets")
local PetModels = AssetFolder:WaitForChild("PetModels")

-- Private functions
function getUIPadding(px: number, maid: Maid): UIPadding
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

	return _new("UIPadding")({
		PaddingTop = UDim.new(0, px),
		PaddingBottom = UDim.new(0, px),
		PaddingLeft = UDim.new(0, px),
		PaddingRight = UDim.new(0, px),
	}) :: UIPadding
end

function getUICorner(px: number, maid: Maid): UICorner
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

	return _new("UICorner")({
		CornerRadius = UDim.new(0, px),
	}) :: UICorner
end

function getPetIconInfoFrame(
	petData: PetDisplayData,
	Transparency: State<number>,
	IsPremium: State<boolean>,
	maid: Maid
): Frame
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

	local template: Model? = if petData then PetModels:FindFirstChild(petData.Name) else nil
	assert(template ~= nil)
	local model = template:Clone()
	model:PivotTo(CFrame.new(0, 0, 0))

	local _cf, size = model:GetBoundingBox()

	local diameter = size.Magnitude
	local camera = _new("Camera")({
		FieldOfView = 30,
		CFrame = CFrame.new(Vector3.new(diameter * 0.5, diameter * 0.5, diameter), Vector3.new(0, 0, 0)),
	})
	local backColor = Color3.fromHSV(1, 0, 0.9)
	return _new("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = backColor,
		BackgroundTransparency = Transparency,
		[_CHILDREN] = {
			getUICorner(4 * SCALE, maid) :: any,
			getUIPadding(2 * SCALE, maid),
			_new("TextLabel")({
				Name = "ChanceLabel",
				Text = "<b>" .. math.round(100 * petData.Chance) .. "%</b>",
				RichText = true,
				Visible = _Computed(function(isPremium: boolean)
					return not isPremium
				end, IsPremium),
				TextColor3 = Color3.new(1, 1, 1),
				BackgroundColor3 = LegibilityUtil(Color3.new(1, 0, 0), Color3.new(1, 1, 1)),
				Rotation = -35,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.25, 0.15),
				ZIndex = 5,
				BackgroundTransparency = Transparency,
				TextTransparency = Transparency,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromScale(0, 0),
				TextSize = 15 * SCALE,
				Font = Enum.Font.Gotham,
				[_CHILDREN] = {
					getUIPadding(2 * SCALE, maid),
					getUICorner(3 * SCALE, maid) :: any,
				},
			}),
			_new("TextLabel")({
				Name = "TextLabel",
				Text = "<b>" .. string.upper(petData.Text) .. "</b>",
				RichText = true,
				BackgroundColor3 = Color3.fromHSV(1, 0, 0.98),
				TextColor3 = LegibilityUtil(Color3.new(0.5, 0.5, 0.5), Color3.fromHSV(1, 0, 0.98)),
				ZIndex = 10,
				BackgroundTransparency = Transparency,
				TextTransparency = Transparency,
				Position = UDim2.fromScale(0.5, 0.95),
				AnchorPoint = Vector2.new(0.5, 1),
				AutomaticSize = Enum.AutomaticSize.XY,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextSize = 12 * SCALE,
				Font = Enum.Font.Gotham,
				[_CHILDREN] = {
					getUICorner(3 * SCALE, maid) :: any,
					getUIPadding(2 * SCALE, maid),
				},
			}),
			_new("ViewportFrame")({
				BackgroundTransparency = Transparency,
				ImageTransparency = Transparency,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(0.8, 0.8),
				CurrentCamera = camera,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 1,
				Ambient = Color3.new(1, 1, 1),
				LightColor = Color3.new(1, 1, 1),
				ClipsDescendants = true,
				[_CHILDREN] = {
					camera,
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("WorldModel")({
						[_CHILDREN] = {
							model,
						},
					}),
				},
			}) :: ViewportFrame,
		},
	}) :: Frame
end

function getPetIcon(
	index: number,
	petData: PetDisplayData?,
	Transparency: State<number>,
	IsPremium: State<boolean>,
	maid: Maid
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

	local out = _new("Frame")({
		Name = "PetIcon",
		BackgroundTransparency = 1,
		LayoutOrder = index,
		[_CHILDREN] = {
			getUIPadding(4 * SCALE, maid) :: any,
		},
	})

	if petData then
		local frame = getPetIconInfoFrame(petData, Transparency, IsPremium, maid)
		frame.Parent = out
	end

	return out
end

function getButton(
	onClick: () -> nil,
	ButtonIcon: State<string>,
	BackgroundColor: State<Color3>,
	layoutOrder: number,
	Transparency: State<number>,
	Visible: State<boolean>,
	PositionScaleAdjustment: State<number>,
	CursorPosition: ValueState<Vector2>
)
	local maid = Maid.new()
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

	local buffer = false

	-- local screenGui = _new("ScreenGui")({
	-- 	Name = "Button",
	-- 	Parent = game:GetService("CoreGui")
	-- })

	-- local frame = _new("Frame")({
	-- 	AnchorPoint = Vector2.new(0.5,0.5),
	-- 	Size = UDim2.fromOffset(30,30),
	-- 	Position = _Computed(function(pos: Vector2)
	-- 		return UDim2.fromOffset(pos.X, pos.Y)
	-- 	end, CursorPosition),
	-- 	Parent = screenGui,
	-- })

	local IsHovering = _Value(false)
	local IsClicking = _Value(false)

	local out: TextButton = _new("TextButton")({
		Name = "Button" .. tostring(layoutOrder),
		RichText = true,
		Visible = Visible,
		Active = _Computed(function(trans: number)
			if trans < 0.3 then
				return true
			else
				return false
			end
		end, Transparency),
		LayoutOrder = layoutOrder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = _Computed(function(adjustment: number)
			return UDim2.fromScale(adjustment + (layoutOrder / 3) - (1 / 6), 0.5)
		end, PositionScaleAdjustment),
		BackgroundColor3 = _Computed(function(isHover: boolean, color: Color3)
			if isHover then
				local h, s, v = color:ToHSV()
				return Color3.fromHSV(h, s * 0.8, v)
			else
				return color
			end
		end, IsHovering, BackgroundColor):Spring(850, 0.1),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = _Computed(function(isClick: boolean, trans: number)
			if isClick then
				if trans >= 1 then
					return 1
				else
					return 1 - ((1 - trans) * 0.7)
				end
			else
				return trans
			end
		end, IsClicking, Transparency),
		TextTransparency = 1,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		[_ON_EVENT("Activated")] = function()
			if not buffer then
				buffer = true
				onClick()
				task.wait(10)
				buffer = false
			end
		end,
		[_CHILDREN] = {
			_new("ImageLabel")({
				Image = ButtonIcon,
				BackgroundTransparency = 1,
				ImageTransparency = Transparency,
				Size = _Computed(function(isHover: boolean)
					if isHover then
						return UDim2.fromOffset(38 * SCALE, 38 * SCALE)
					else
						return UDim2.fromOffset(32 * SCALE, 32 * SCALE)
					end
				end, IsHovering):Spring(850, 0.1),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, SCALE * 4),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			getUICorner(4 * SCALE, maid) :: any,
			getUIPadding(4 * SCALE, maid),
		},
	}) :: any

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		if not RunService:IsRunning() then
			CursorPosition:Set(UserInputService:GetMouseLocation())
		end
		-- CursorPosition:Set(mouseLocation)
		local mouseLocation = CursorPosition:Get()
		local absPos = out.AbsolutePosition
		local absSize = out.AbsoluteSize

		local startX = absPos.X
		local startY = absPos.Y
		local finX = startX + absSize.X
		local finY = startY + absSize.Y

		if
			mouseLocation.X > startX
			and mouseLocation.X < finX
			and mouseLocation.Y > startY
			and mouseLocation.Y < finY
		then
			IsHovering:Set(true)
			local mouseButtons: { [number]: InputObject } = UserInputService:GetMouseButtonsPressed()
			IsClicking:Set(false)
			for i, inputObject in ipairs(mouseButtons) do
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
					IsClicking:Set(true)
				end
			end
		else
			IsHovering:Set(false)
			IsClicking:Set(false)
		end
	end))

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end

function mainFrame(
	Pets: ValueState<List<PetDisplayData>>,
	Transparency: State<number>,
	onButton1Click: Signal,
	onButton2Click: Signal,
	onButton3Click: Signal,
	Button1Label: State<string>,
	Button2Label: State<string>,
	Button3Label: State<string>,
	Price: State<number>,
	IsPremium: State<boolean>,
	CursorPosition: ValueState<Vector2>
): GuiBase2d
	local maid = Maid.new()

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

	local displayFrame = _new("Frame")({
		Name = "Display",
		BackgroundColor3 = Color3.fromHSV(1, 0, 0.8),
		Size = UDim2.fromOffset(1.5 * 200 * SCALE, 0.5 * 200 * SCALE),
		BorderSizePixel = 0,
		LayoutOrder = 1,
		BackgroundTransparency = Transparency,
		[_CHILDREN] = {
			_new("UIGridLayout")({
				CellPadding = UDim2.new(0, 0, 0, 0),
				CellSize = UDim2.fromScale(1 / 3, 1),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirectionMaxCells = 3,
				SortOrder = Enum.SortOrder.LayoutOrder,
				StartCorner = Enum.StartCorner.TopLeft,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			getUIPadding(2 * SCALE, maid),
			getUICorner(4 * SCALE, maid),
		},
	})

	-- Build icons
	local InvisibleTransparency = _Value(1)

	_Computed(function(pets: List<PetData>)
		local out: List<PetData | number> = {}
		for i, pet in ipairs(pets) do
			table.insert(out, pet)
		end
		for i = #pets + 1, 3 do
			out[i] = 1
		end
		return out
	end, Pets):ForPairs(function(index: number, val: PetDisplayData | number, pairMaid: Maid)
		local pData: PetDisplayData?
		if type(val) ~= "number" then
			pData = val
		end
		local icon = getPetIcon(
			index,
			pData,
			if type(val) == "number" then InvisibleTransparency else Transparency,
			IsPremium,
			pairMaid
		)
		icon.Parent = displayFrame
		return index, val
	end)
	local blue = Color3.fromRGB(10, 100, 255)

	local ScaleAdjustment = _Computed(function(enab: boolean)
		if enab then
			return 0
		else
			return 1 / 6
		end
	end, IsPremium)

	local buttonFrame = _new("Frame")({
		Name = "ButtonFrame",
		AutomaticSize = Enum.AutomaticSize.None,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 45 * SCALE),
		LayoutOrder = 2,
		[_CHILDREN] = {
			maid:GiveTask(getButton(function()
				onButton1Click:Fire()
			end, Button1Label, _Value(blue), 1, Transparency, _Value(true), ScaleAdjustment, CursorPosition)),
			maid:GiveTask(getButton(
				function()
					onButton2Click:Fire()
				end,
				Button2Label,
				_Computed(function(isPremium: boolean): Color3
					if isPremium then
						return blue
					else
						return Color3.fromRGB(31, 128, 29)
					end
				end, IsPremium),
				2,
				Transparency,
				_Value(true),
				ScaleAdjustment,
				CursorPosition
			)),
			getButton(
				function()
					onButton3Click:Fire()
				end,
				Button3Label,
				_Computed(function(isPremium: boolean): Color3
					if isPremium then
						return blue
					else
						return Color3.fromRGB(10, 100, 255)
					end
				end, IsPremium),
				3,
				Transparency,
				IsPremium,
				_Value(0),
				CursorPosition
			),
			-- _new("TextButton")({
			-- 	Name = "AutoButton",
			-- 	Text = _Computed(function(label: string): string
			-- 		return "<b>" .. label .. "</b>"
			-- 	end, Button3Label),
			-- 	RichText = true,
			-- 	TextColor3 = AutoTextColor,
			-- 	AnchorPoint = Vector2.new(0.5,0.5),
			-- 	Position = UDim2.fromScale(1-(1/6), 0.5),
			-- 	LayoutOrder = 3,
			-- 	BackgroundTransparency = Transparency,
			-- 	TextTransparency = Transparency,
			-- 	BackgroundColor3 = AutoBackgroundColor,
			-- 	AutomaticSize = Enum.AutomaticSize.XY,
			-- 	TextXAlignment = Enum.TextXAlignment.Center,
			-- 	TextYAlignment = Enum.TextYAlignment.Center,
			-- 	TextSize = _Computed(function(isEnabled: boolean): number
			-- 		if isEnabled then
			-- 			return 25 * SCALE - AUTO_BORDER_THICKNESS * 2
			-- 		else
			-- 			return 25 * SCALE
			-- 		end
			-- 	end, IsButton3Enabled):Tween(),
			-- 	Font = Enum.Font.Gotham,
			-- 	AutoButtonColor = true,
			-- 	[_ON_EVENT("Activated")] = function()
			-- 		-- IsButton3Enabled:Set(not IsButton3Enabled:Get())
			-- 		onButton3Click:Fire(IsButton3Enabled:Get())
			-- 	end,
			-- 	[_CHILDREN] = {
			-- 		getUICorner(4 * SCALE, maid) :: any,
			-- 		getUIPadding(4 * SCALE, maid),
			-- 		_new("UIStroke")({
			-- 			Thickness = _Computed(function(enabled: boolean)
			-- 				if enabled then
			-- 					return AUTO_BORDER_THICKNESS
			-- 				else
			-- 					return 0
			-- 				end
			-- 			end, IsButton3Enabled):Tween(),
			-- 			Transparency = 0,
			-- 			Color = AutoTextColor,
			-- 			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			-- 		}),
			-- 	},
			-- }),
		},
	})

	_new("UIListLayout")({
		Parent = _Computed(function(isPremium: boolean): Instance?
			if isPremium then
				return nil
			else
				return buttonFrame
			end
		end, IsPremium),
		Padding = UDim.new(0, 4 * SCALE),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local main = _new("Frame")({
		BackgroundColor3 = BACKGROUND_COLOR,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		LayoutOrder = 2,
		BackgroundTransparency = Transparency,
		BorderSizePixel = 0,
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = UDim.new(0, SCALE * 4),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			displayFrame,
			buttonFrame,
			getUIPadding(4 * SCALE, maid),
			getUICorner(4 * SCALE, maid),
		},
	}) :: Frame

	local out = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = UDim.new(0, SCALE * 4),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromScale(0, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = Transparency,
				BackgroundColor3 = Color3.fromHSV(1, 0, 0.98),
				BorderSizePixel = 0,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = UDim.new(0, 0),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("ImageLabel")({
						Image = "rbxassetid://13024186595",
						Visible = _Computed(function(isPremium: boolean)
							return not isPremium
						end, IsPremium),
						ImageColor3 = Color3.fromHSV(1, 0, 0.85),
						ImageTransparency = Transparency,
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Stretch,
						Size = UDim2.fromOffset(30, 30),
						Position = UDim2.fromScale(0, 0.5),
						AnchorPoint = Vector2.new(0.3, 0.5),
						LayoutOrder = 1,
					}),
					getUIPadding(8 * SCALE, maid),
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("TextLabel")({
						Name = "TextLabel",
						Text = _Computed(function(isPremium: boolean, price: number): string
							if isPremium then
								return FormatUtil.bold(
									FormatUtil.color(ROBUX_ICON_CHAR, Color3.fromRGB(31, 128, 29))
										.. FormatUtil.formatNumber(price)
								)
							else
								return FormatUtil.bold(FormatUtil.formatNumber(price))
							end
						end, IsPremium, Price),
						LayoutOrder = 2,
						RichText = true,
						TextColor3 = LegibilityUtil(Color3.new(0.5, 0.5, 0.5), Color3.fromHSV(1, 0, 0.98)),
						ZIndex = 10,
						BackgroundTransparency = 1,
						TextTransparency = Transparency,
						Position = UDim2.fromScale(0.5, 0.95),
						AnchorPoint = Vector2.new(0.5, 1),
						AutomaticSize = Enum.AutomaticSize.XY,
						TextYAlignment = Enum.TextYAlignment.Center,
						TextSize = 20 * SCALE,
						Font = Enum.Font.Gotham,
						[_CHILDREN] = {},
					}),
				},
			}),
			main,
		},
	}) :: Frame

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end

-- Class
return function(
	position: Vector3,
	Pets: ValueState<List<PetDisplayData>>,
	onButton1Click: Signal,
	onButton2Click: Signal,
	onButton3Click: Signal,
	Button1Label: State<string>,
	Button2Label: State<string>,
	Button3Label: State<string>,
	Price: State<number>,
	IsPremium: State<boolean>
): GuiBase2d
	local maid = Maid.new()
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

	local TransparencyBase = _Value(if RunService:IsRunning() then 1 else 0)
	local CursorPosition = _Value(Vector2.new(0, 0))
	local main = mainFrame(
		Pets,
		TransparencyBase:Tween(),
		onButton1Click,
		onButton2Click,
		onButton3Click,
		Button1Label,
		Button2Label,
		Button3Label,
		Price,
		IsPremium,
		CursorPosition
	)

	local part = _new("Part")({
		Name = "SurfaceGuiMount",
		CanTouch = false,
		CanCollide = false,
		CanQuery = false,
		Locked = true,
		Anchored = true,
		Transparency = 1,
		Parent = workspace,
		Size = Vector3.new(10, 10, 0.01) * SCALE,
	}) :: Part

	-- local hit: Part = _new("Part")({
	-- 	Anchored = true,
	-- 	Size = Vector3.new(1,1,1),
	-- 	Shape = Enum.PartType.Ball,
	-- 	Color = Color3.new(1,0,0),
	-- 	Parent = workspace
	-- }) :: any

	local surfaceGui: SurfaceGui = _new("SurfaceGui")({
		Name = "PetEggGui",
		Adornee = part,
		Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
		LightInfluence = 0,
		AlwaysOnTop = true, --for some reason buttons don't work when this isn't enabled?
		Face = Enum.NormalId.Front,
		ResetOnSpawn = false,
		CanvasSize = Vector2.new(450, 450),
		SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		PixelsPerStud = 25,
		[_CHILDREN] = {
			main,
		},
	}) :: any

	-- local guiHit: Frame = _new("Frame")({
	-- 	BackgroundColor3 = Color3.new(0,1,1),
	-- 	Size = UDim2.fromOffset(30,30),
	-- 	Parent = surfaceGui
	-- }) :: any

	maid:GiveTask(main.Destroying:Connect(function()
		maid:Destroy()
	end))

	maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		part.CFrame = CFrame.new(position, workspace.CurrentCamera.CFrame.Position)
		local dist = (part.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
		local alpha = CurveUtil.ease(
			math.clamp((dist - MIN_VIEWING_DISTANCE) / (MAX_VIEWING_DISTANCE - MIN_VIEWING_DISTANCE), 0, 1),
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)
		TransparencyBase:Set(math.round(100 * alpha) / 100)

		local screenPoint = UserInputService:GetMouseLocation()
		local camRay = workspace.CurrentCamera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
		local surfaceCF = part.CFrame * CFrame.new(0, 0, -part.Size.Z / 2)

		local hitPoint = GeometryUtil.getPlaneIntersection(
			camRay.Origin,
			camRay.Direction.Unit,
			surfaceCF.Position,
			-surfaceCF.LookVector
		)
		-- hit.Position = hitPoint
		local offset = (surfaceCF:Inverse() * CFrame.new(hitPoint)).Position * -1
		-- print("OFF", offset.X, offset.Y, "SIZE", part.Size.X, part.Size.Y)
		if math.abs(offset.Y) < part.Size.Y / 2 and math.abs(offset.X) < part.Size.X / 2 then
			local scaleY = (offset.Y - part.Size.Y / 2) / part.Size.Y + 1
			local scaleX = (offset.X - part.Size.X / 2) / part.Size.X + 1
			-- print("X", scaleX, "Y", scaleY)
			local pixelY = scaleY * surfaceGui.AbsoluteSize.Y
			local pixelX = scaleX * surfaceGui.AbsoluteSize.X
			-- guiHit.Position = UDim2.fromOffset(pixelX, pixelY)
			CursorPosition:Set(Vector2.new(pixelX, pixelY))
		else
			CursorPosition:Set(Vector2.new(0, 0))
		end
	end))

	return main
end
