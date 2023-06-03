--!strict
-- Services
local RunService = game:GetService("RunService")
-- local Players = game:GetService("Players")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local Assets = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))
local MainSysUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local CursorTracer = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("CursorTracer"))

-- Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type CursorTracer = CursorTracer.CursorTracer
type GamepassData = {
	Texture: string,
	Id: number,
	Name: string,
	Color: Color3,
	Price: number,
}
-- Constants
local AFFORD_COLOR = Color3.new(0, 0.5, 0)
local UNAFFORD_COLOR = Color3.new(0.8, 0, 0)
local BLOCK_ICON = "rbxassetid://12607770315"
local TIMER_ICON = "rbxassetid://12607780536"
local MULTI_BLOCK_ICON = "rbxassetid://12809225949"
local TEXT_SCALE = 1.3

local PANEL_COLORS = {
	Assets.Texture.Gamepass.Tab.Blue,
	Assets.Texture.Gamepass.Tab.Green,
	Assets.Texture.Gamepass.Tab.Purple,
	Assets.Texture.Gamepass.Tab.Yellow,
}

-- Variables
-- References

-- Private function
function getItemPanel(
	Wallet: State<number>,
	onClick: () -> nil,
	title: string,
	price: State<number>,
	icon: string,
	ValueText: State<string>,
	Level: State<number>,
	MaxLevel: State<number>,
	layoutOrder: number,
	cursorTracker: CursorTracer?
): Frame
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

	local backgroundTexture = PANEL_COLORS[(layoutOrder % #PANEL_COLORS) + 1]

	local PriceColor = _Computed(function(wallet: number)
		if wallet < price:Get() then
			return UNAFFORD_COLOR
		else
			return AFFORD_COLOR
		end
	end, Wallet):Tween()

	local clickBuffer = false
	local function onButtonClick()
		if not clickBuffer then
			clickBuffer = true
			if Wallet:Get() >= price:Get() then
				onClick()

				--play ok sound
				local sound = Instance.new("Sound")
				sound.SoundId = MiscLists.AssetIdLists.SoundIds.Success
				sound.Parent = script
				sound:Play()
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
			else
				--play fail sound
				local sound = Instance.new("Sound")
				sound.SoundId = MiscLists.AssetIdLists.SoundIds.Fail
				sound.Parent = script
				sound:Play()
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
			end
			task.wait(0.1)
			clickBuffer = false
		else
			warn("You click too fast!")
		end
	end

	local InternalHoverState = _Value(false)
	local button = _new("ImageButton")({
		Name = "Button",
		AutoButtonColor = _Computed(function(wallet: number)
			return wallet > price:Get()
		end, Wallet),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = _Computed(function(isHover: boolean)
			if isHover then
				return UDim2.new(0.7, 10, 0.15, 10)
			else
				return UDim2.fromScale(0.7, 0.15)
			end
		end, InternalHoverState):Tween(0.15, Enum.EasingStyle.Bounce),
		LayoutOrder = 10,
		BackgroundColor3 = PriceColor,
		Visible = _Computed(function(lvl: number, maxLevel: number)
			return lvl < maxLevel
		end, Level, MaxLevel),
		[_ON_EVENT("Activated")] = if not cursorTracker then onButtonClick else nil,
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = UDim.new(0, 8),
			}),
			_new("UIStroke")({
				Color = Color3.fromHSV(0, 0, 0.3),
				Thickness = 3,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = 0.2,
			}),
			_new("ImageLabel")({
				Image = "rbxassetid://13024186595",
				ImageColor3 = _Computed(function(wallet: number)
					if wallet < price:Get() then
						return UNAFFORD_COLOR
					else
						return Color3.new(1, 1, 1)
					end
				end, Wallet):Tween(),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Stretch,
				Size = UDim2.fromOffset(50, 50),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0.3, 0.5),
				LayoutOrder = 1,
			}),
			_new("TextLabel")({
				TextSize = 30,
				LayoutOrder = 2,
				Text = _Computed(function(priceNumber: number): string
					return if (priceNumber < 0) or (priceNumber == math.huge)
						then "MAXED"
						else tostring(FormatUtil.formatNumber(priceNumber)) .. ""
				end, price),
				TextColor3 = _Computed(function(backColor: Color3)
					return LegibilityUtil(Color3.new(1, 1, 1), backColor)
				end, PriceColor),
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				Position = UDim2.fromScale(0.95, 0.5),
				AnchorPoint = Vector2.new(1, 0.4),
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.LuckiestGuy,
				RichText = false,
				BackgroundTransparency = 1,
				[_CHILDREN] = {},
			}),
		},
	}) :: ImageButton

	if cursorTracker then
		local ClickState = cursorTracker:GetClickState(button)
		ClickState:Connect(function(cur: boolean)
			if cur then
				onButtonClick()
			end
		end)

		local HoverState = cursorTracker:GetHoverState(button)
		HoverState:Connect(function(cur: boolean)
			InternalHoverState:Set(cur)
		end)
	end

	local out = _new("ImageLabel")({
		LayoutOrder = layoutOrder,
		Name = title,
		Size = UDim2.fromOffset(200, 325),
		Image = backgroundTexture,
		BackgroundColor3 = PriceColor,
		BackgroundTransparency = 1,
		ImageRectSize = Vector2.new(0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(64, 128), Vector2.new(64, 128)),
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("TextLabel")({
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				TextSize = 20 * TEXT_SCALE,
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.LuckiestGuy,
				FontFace = Font.new("LuckiestGuy", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
				RichText = false,
				Text = title,
				[_CHILDREN] = {
					_new("UIStroke")({
						Color = Color3.fromHSV(0, 0, 0.3),
						Thickness = 2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						Transparency = 0,
					}),
					_new("UIPadding")({
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 1),
						PaddingRight = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),
				},
			}),
			_new("TextLabel")({
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2.5,
				TextSize = 17 * TEXT_SCALE,
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				TextColor3 = Color3.fromHSV(0.6, 0.6, 1),
				Font = Enum.Font.Cartoon,
				FontFace = Font.new("Cartoon", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
				RichText = false,
				Text = _Computed(function(lvl: number, maxLevel: number): string
					return "Level " .. tostring(math.round(lvl)) .. " / " .. tostring(maxLevel)
				end, Level, MaxLevel),
				[_CHILDREN] = {
					_new("UIStroke")({
						Color = Color3.fromHSV(0, 0, 0.3),
						Thickness = 2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						Transparency = 0,
					}),
					_new("UIPadding")({
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),
				},
			}),

			_new("ImageLabel")({
				LayoutOrder = 7,
				Name = "Icon",
				Image = icon,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Size = if title == "Spawn Level" then UDim2.fromOffset(110, 150) else UDim2.fromOffset(150, 150),
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingTop = UDim.new(0.1, 0),
						PaddingBottom = UDim.new(0.1, 0),
						PaddingRight = UDim.new(0.1, 0),
						PaddingLeft = UDim.new(0.1, 0),
					}),
					_new("TextLabel")({
						AutomaticSize = Enum.AutomaticSize.XY,
						LayoutOrder = 5,
						TextSize = 28 * TEXT_SCALE,
						AnchorPoint = if title == "Spawn Time" then Vector2.new(0.5, 0.8) else Vector2.new(0.5, 0.5),
						Position = if title == "Spawn Time"
							then UDim2.fromScale(0.5, 1)
							else UDim2.fromScale(0.5, 0.55),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
						TextColor3 = Color3.new(1, 1, 1),
						Font = Enum.Font.LuckiestGuy,
						RichText = false,
						TextYAlignment = Enum.TextYAlignment.Center,
						Text = _Computed(function(txt: string)
							return txt
						end, ValueText),
						TextXAlignment = Enum.TextXAlignment.Left,
						[_CHILDREN] = {
							_new("UIStroke")({
								Color = Color3.fromHSV(0, 0, 0.3),
								Thickness = 2,
								ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
								Transparency = 0,
							}),
							_new("UIPadding")({
								PaddingTop = UDim.new(0, 7),
								PaddingBottom = UDim.new(0, 0),
								PaddingRight = UDim.new(0, 15),
								PaddingLeft = UDim.new(0, 15),
							}),
							_new("UICorner")({
								CornerRadius = UDim.new(0.5, 0),
							}),
						},
					}),
				},
			}),
			button,
		},
	}) :: Frame

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end

-- Class
return function(
	surfacePart: Part?,
	Wallet: State<number>,
	SpawnLevel: State<number>,
	UpgradeLevel: State<number>,
	SpawnTimerLevel: State<number>,
	OnSpawnLevel: Signal,
	OnMaxClick: Signal,
	OnSpawnTime: Signal,
	PlotModel: Model?
): Frame
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

	--state vars
	local UpgradeBasePrice = _Value(MiscLists.Prices.UpgradeBaseLevel)
	local UpgradeMaximumObjectCountPrice = _Value(MiscLists.Prices.UpgradeMaximumObjectCount)
	local UpgradeRateOfSpawnPrice = _Value(MiscLists.Prices.UpgradeRateOfSpawn)

	local AbsoluteSize = _Value(Vector2.new(0, 0))

	local frame = _new("Frame")({
		Name = "Menu",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			-- _new("UIPadding")({
			-- 	PaddingTop = UDim.new(0,PADDING_PX),
			-- 	PaddingBottom = UDim.new(0,PADDING_PX),
			-- 	PaddingLeft = UDim.new(0,PADDING_PX),
			-- 	PaddingRight = UDim.new(0,PADDING_PX),
			-- }),
		},
	}) :: Frame

	local cursorTracer: CursorTracer?
	if surfacePart then
		local surfaceGui = _new("SurfaceGui")({
			Name = "UpgradeBoardMenu",
			Parent = if RunService:IsRunning()
				then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
				else game:GetService("StarterGui"),
			Brightness = 1,
			LightInfluence = 0,
			ResetOnSpawn = false,
			Face = Enum.NormalId.Front,
			Adornee = surfacePart,
			PixelsPerStud = 28,
			SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
			[_CHILDREN] = {
				frame,
			},
		}) :: SurfaceGui
		cursorTracer = maid:GiveTask(CursorTracer.new(surfaceGui))
	end


	AbsoluteSize:Set(frame.AbsoluteSize)

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		AbsoluteSize:Set(frame.AbsoluteSize)
	end))

	maid:GiveTask(getItemPanel(
		Wallet,
		function()
			OnSpawnLevel:Fire()
		end,
		"Spawn Level",
		UpgradeBasePrice,
		BLOCK_ICON,
		_Computed(function(lvl: number): string
			return tostring(lvl)
		end, SpawnLevel),
		SpawnLevel,
		_Value(#MiscLists.Prices.ObjectLevelPrice),
		1,
		cursorTracer
	)).Parent =
		frame

	local maxBlock = -math.huge
	for i, v in pairs(MiscLists.Prices.MaxBlockCountPrice) do
		if i > maxBlock then
			maxBlock = i
		end
	end

	maid:GiveTask(getItemPanel(
		Wallet,
		function()
			OnMaxClick:Fire()
		end,
		"Max Blocks",
		UpgradeMaximumObjectCountPrice,
		MULTI_BLOCK_ICON,
		_Computed(function(lvl: number): string
			return tostring(lvl)
		end, UpgradeLevel),
		UpgradeLevel,
		_Value(maxBlock),
		2,
		cursorTracer
	)).Parent =
		frame

	maid:GiveTask(getItemPanel(
		Wallet,
		function()
			OnSpawnTime:Fire()
		end,
		"Spawn Time",
		UpgradeRateOfSpawnPrice,
		TIMER_ICON,
		_Computed(function(lvl: number): string
			print(lvl)
			return tostring(math.max(math.round(10 * (5 - (lvl * 0.2))) / 10, 0.2)) .. "s"
		end, SpawnTimerLevel),
		SpawnTimerLevel,
		_Value(#MiscLists.Prices.SpawnIntervalPrice - 1),
		3,
		cursorTracer
	)).Parent =
		frame
	
	maid:GiveTask(frame.Destroying:Connect(function()
		maid:Destroy()
	end))

	--detecting cash changes
	if PlotModel then
		PlotModel:GetAttributeChangedSignal("BaseLevel"):Connect(function()
			local plotData = MainSysUtil.getMainSysData(PlotModel)
			if plotData then
				--UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.UpgradeBaseLevel*plotData.BaseLevel))
				UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.ObjectLevelPrice[plotData.BaseLevel + 1] or math.huge))
			end
		end)

		PlotModel:GetAttributeChangedSignal("AutoSpawnerInterval"):Connect(function()
			local plotData = MainSysUtil.getMainSysData(PlotModel)
			if plotData then
				--UpgradeRateOfSpawnPrice:Set(math.ceil(plotData.AutoSpawnerInterval / (plotData.AutoSpawnerInterval / MiscLists.Prices.UpgradeRateOfSpawn)))
				--hacky way; finding the nearest number on misclist vs the current interval second
				-- local interval
				local nextInterval
				for i, v in pairs(MiscLists.Prices.SpawnIntervalPrice) do
					if
						MiscLists.Prices.SpawnIntervalPrice[i + 1]
						and math.round(
								(
									MiscLists.Prices.SpawnIntervalPrice[i + 1].Interval
									- (plotData.AutoSpawnerInterval - 0.2)
								) * 1000
							)
							== 0
					then
						-- interval = v
						nextInterval = MiscLists.Prices.SpawnIntervalPrice[i + 1]
					end
				end
				UpgradeRateOfSpawnPrice:Set(math.ceil(if nextInterval then nextInterval.Price else math.huge))
			end
		end)

		PlotModel:GetAttributeChangedSignal("MaximumObjectCount"):Connect(function()
			local plotData = MainSysUtil.getMainSysData(PlotModel)
			if plotData then
				--UpgradeMaximumObjectCountPrice:Set(math.ceil(MiscLists.Prices.UpgradeMaximumObjectCount* (plotData.MaximumObjectCount / MiscLists.Limits.MaximumObjectCount)))
				UpgradeMaximumObjectCountPrice:Set(
					math.ceil(MiscLists.Prices.MaxBlockCountPrice[plotData.MaximumObjectCount + 1] or math.huge)
				)
			end
		end)

		local plotData = MainSysUtil.getMainSysData(PlotModel)
		if plotData then
			--UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.UpgradeBaseLevel*plotData.BaseLevel))
			UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.ObjectLevelPrice[plotData.BaseLevel + 1] or math.huge))
			UpgradeMaximumObjectCountPrice:Set(
				math.ceil(MiscLists.Prices.MaxBlockCountPrice[plotData.MaximumObjectCount + 1] or math.huge)
			)
			-- local interval
			local nextInterval
			for i, v in pairs(MiscLists.Prices.SpawnIntervalPrice) do
				if
					MiscLists.Prices.SpawnIntervalPrice[i + 1]
					and math.round(
							(MiscLists.Prices.SpawnIntervalPrice[i + 1].Interval - (plotData.AutoSpawnerInterval - 0.2))
								* 1000
						)
						== 0
				then
					-- interval = v
					nextInterval = MiscLists.Prices.SpawnIntervalPrice[i + 1]
				end
			end
			UpgradeRateOfSpawnPrice:Set(math.ceil(if nextInterval then nextInterval.Price else math.huge))
		end
		--UpgradeMaximumObjectCountPrice:Set(math.ceil(MiscLists.Prices.UpgradeMaximumObjectCount* (plotData.MaximumObjectCount / MiscLists.Limits.MaximumObjectCount)))
		--[[maid:GiveTask(Player:WaitForChild("leaderstats"):WaitForChild("Cash"):GetPropertyChangedSignal("Value"):Connect(function()
			local plotData = MainSysUtil.getMainSysData(PlotModel)
			if plotData then
				--[[UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.UpgradeBaseLevel*plotData.BaseLevel))
				UpgradeMaximumObjectCountPrice:Set(math.ceil(MiscLists.Prices.UpgradeMaximumObjectCount* (plotData.MaximumObjectCount / MiscLists.Limits.MaximumObjectCount)))
				UpgradeRateOfSpawnPrice:Set(math.ceil(plotData.AutoSpawnerInterval / (plotData.AutoSpawnerInterval / MiscLists.Prices.UpgradeRateOfSpawn)))]]

		--[[UpgradeBasePrice:Set(math.ceil(MiscLists.Prices.ObjectLevelPrice[plotData.BaseLevel] or 0))
				UpgradeMaximumObjectCountPrice:Set(math.ceil(MiscLists.Prices.MaxBlockCountPrice[plotData.BaseLevel] or 0))
				--hacky way; finding the nearest number on misclist vs the current interval second
				local interval 
				for _,v in pairs(MiscLists.Prices.SpawnIntervalPrice) do
					if math.round((v.Interval - plotData.AutoSpawnerInterval)*1000) == 0 then
						interval = v
					end
				end
				UpgradeRateOfSpawnPrice:Set(math.ceil(if interval then interval.Price else 0))
			end
		end))]]
	end

	return frame
end
