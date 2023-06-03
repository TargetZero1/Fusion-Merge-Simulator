--!strict
-- Services
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
export type HatchData = {
	Model: Model,
	Text: string,
	Color: Color3,
	Level: number,
}

-- Constants
local DISTANCE = 10
local CANVAS_DEPTH = 0.01
local TRANSITION_DURATION = 1
local EGG_WIGGLE_RANGE = 15
local WIGGLE_FLIP_DELAY = 0.3
local SCALE_WEIGHT = 1
local CONFETTI_SCALE = 0.07
local CONFETTI_SPEED_SCALE = 1
local TEXT_TWEEN_DURATION = 0.4
local SPEED_WEIGHT = 0.25

local OPEN_SOUND = "rbxassetid://12222253"
local GLOW_ASSET_ID = "rbxassetid://252246909"

-- Variables
-- References
local AssetFolder = ReplicatedStorage:WaitForChild("Assets")
local PlotModels = AssetFolder:WaitForChild("PlotModels")
local PlotModel = PlotModels:WaitForChild("PlotModel")

-- Private functions
function preloadSound(id: string)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	task.spawn(function()
		ContentProvider:PreloadAsync({
			sound,
		})
		sound:Destroy()
	end)
end

function getViewportFrame(
	model: Model,
	Transparency: CanBeState<number>?,
	CFrameOffset: CanBeState<CFrame>?,
	FieldOfView: CanBeState<number>?,
	Color: CanBeState<Color3>?
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

	model:PivotTo(CFrame.new(0, 0, 0))
	maid:GiveTask(model)

	local Offset = _import(CFrameOffset, CFrame.new(0, 0, 0))
	local ViewportColor = _import(Color, Color3.new(1, 1, 1))

	local _cf, size = model:GetBoundingBox()
	local diameter = size.Magnitude

	local camera = _new("Camera")({
		FieldOfView = FieldOfView,
		CFrame = _Computed(function(offset: CFrame)
			return offset * CFrame.new(Vector3.new(0, 0, diameter), Vector3.new(0, 0, 0))
		end, Offset),
	})

	local viewportFrame = _new("ViewportFrame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CurrentCamera = camera,
		BorderSizePixel = 0,
		ZIndex = 20,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Ambient = Color3.new(1, 1, 1),
		LightColor = Color3.new(1, 1, 1),
		ImageColor3 = ViewportColor,
		ImageTransparency = Transparency,
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
	})

	maid:GiveTask(viewportFrame.Destroying:Connect(function()
		maid:Destroy()
	end))

	return viewportFrame
end

function getConfetti(color: Color3, parent: Instance, Enabled: State<boolean>, lvl: number)
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

	local emitter = _new("ParticleEmitter")({
		LightEmission = 0,
		LightInfluence = 0,
		Brightness = 1,
		Texture = "http://www.roblox.com/asset/?id=241685484",
		Color = ColorSequence.new(color),
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Size = NumberSequence.new(CONFETTI_SCALE),
		Squash = NumberSequence.new(0),
		Transparency = NumberSequence.new(0),
		ZOffset = 0,
		EmissionDirection = Enum.NormalId.Top,
		Lifetime = NumberRange.new(1, 2),
		Rate = 20 * (2.5 ^ (lvl - 1) - 1),
		Rotation = NumberRange.new(-90, 90),
		RotSpeed = NumberRange.new(-260, 260),
		Speed = NumberRange.new(CONFETTI_SPEED_SCALE * 10 * 0.75, CONFETTI_SPEED_SCALE * 10 * 0.75),
		SpreadAngle = Vector2.new(360, 360),
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		Acceleration = Vector3.new(0, -1.5 * CONFETTI_SPEED_SCALE * 1.5, 0),
		Drag = 0,
		LockedToPart = false,
		TimeScale = 1.5,
		VelocityInheritance = 0.5,
		Parent = parent,
		Enabled = Enabled,
	}) :: ParticleEmitter

	return emitter
end

-- Preloading
preloadSound(OPEN_SOUND)

-- Class
function runProcess(data: HatchData, position: Vector2, individualScale: number, hatchClass: string, lvl: number): Maid
	local maid = Maid.new()

	local distance = DISTANCE + position.X * 2

	local victorySound = Instance.new("Sound")
	victorySound.SoundId = OPEN_SOUND

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

	local Position = _Value(Vector2.new(0.5, -0.5))
	local PositionTween = Position:Tween(TRANSITION_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	local Rotation = _Value(0)
	local RotationTween = Rotation:Tween()

	local Scale = _Value(0.01)
	local ScaleTween = Scale:Tween(TRANSITION_DURATION, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

	local BorderSize = _Value(0)

	local ModelCFrame = _Value(CFrame.Angles(0, math.rad(-60), 0))
	local ModelFOV = _Value(40)
	local ModelTransparency = _Value(1)
	local ModelColor = _Value(Color3.new(0, 0, 0))
	local ModelRotation = _Value(0)
	local ModelScale = _Value(0)

	local EggCFrame = _Value(CFrame.new(0, 0, 0))
	local EggFOV = _Value(40)
	local EggTransparency = _Value(0)
	local EggColor = _Value(Color3.new(1, 1, 1))
	local EggRotation = _Value(0)
	local EggPosition = _Value(UDim2.fromScale(0.5, 0.5))
	local EggScale = _Value(1)

	local ParticleEnabled = _Value(false)
	local TextVisible = _Value(false)

	local h, s, v = data.Color:ToHSV()

	local secColor = Color3.fromHSV(h, s * 0.7, v)

	local canvas = _new("Part")({
		Name = "Canvas",
		Color = data.Color,
		Transparency = 1,
		Locked = true,
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Parent = workspace,
		Material = Enum.Material.SmoothPlastic,
		CastShadow = false,
	}) :: Part

	local attachment = maid:GiveTask(Instance.new("Attachment"))
	attachment.Parent = canvas

	maid:GiveTask(getConfetti(Color3.fromHSV(0, 1, 1), attachment, ParticleEnabled, lvl))
	maid:GiveTask(getConfetti(Color3.fromHSV(0.15, 1, 1), attachment, ParticleEnabled, lvl))
	maid:GiveTask(getConfetti(Color3.fromHSV(0.3, 1, 1), attachment, ParticleEnabled, lvl))
	maid:GiveTask(getConfetti(Color3.fromHSV(0.5, 1, 1), attachment, ParticleEnabled, lvl))
	maid:GiveTask(getConfetti(Color3.fromHSV(0.65, 1, 1), attachment, ParticleEnabled, lvl))
	maid:GiveTask(getConfetti(Color3.fromHSV(0.8, 1, 1), attachment, ParticleEnabled, lvl))

	local EggDistributer = PlotModel:WaitForChild("Distributers"):WaitForChild(hatchClass)
	local EggTemplate = EggDistributer:WaitForChild("Egg")

	local egg = _new("Model")({
		Name = "Egg",
		[_CHILDREN] = {
			EggTemplate:Clone(),
		},
	}) :: Model

	local modVF = maid:GiveTask(
		getViewportFrame(
			data.Model,
			ModelTransparency:Tween(0.4),
			ModelCFrame:Tween(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			ModelFOV:Tween(),
			ModelColor:Tween(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		)
	)

	local eggVF = maid:GiveTask(
		getViewportFrame(egg, EggTransparency:Tween(), EggCFrame:Tween(), EggFOV:Tween(), EggColor:Tween())
	)

	local BackgroundColor = _Computed(function(vis: boolean)
		return if vis then data.Color else secColor
	end, TextVisible):Tween(TEXT_TWEEN_DURATION)

	local GlowScale = _Value(0)

	local surfaceGui = _new("SurfaceGui")({
		Name = "HatchProcessGui",
		Adornee = canvas,
		Parent = if RunService:IsRunning()
			then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			else game:GetService("StarterGui"),
		LightInfluence = 0,
		AlwaysOnTop = true, --for some reason buttons don't work when this isn't enabled?
		Face = Enum.NormalId.Back,
		ResetOnSpawn = false,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		PixelsPerStud = 25,
		[_CHILDREN] = {
			_new("Frame")({
				Name = "Circle",
				BackgroundColor3 = secColor,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(1 / SCALE_WEIGHT, 1 / SCALE_WEIGHT),
				[_CHILDREN] = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = BorderSize,
						Transparency = 0,
						Color = data.Color,
					}),
					_new("UIPadding")({
						PaddingTop = UDim.new(0.1, 0),
						PaddingBottom = UDim.new(0.1, 0),
						PaddingLeft = UDim.new(0.1, 0),
						PaddingRight = UDim.new(0.1, 0),
					}),
					_new("ImageLabel")({
						Image = GLOW_ASSET_ID,
						ZIndex = 1,
						ImageTransparency = _Computed(function(scale: number)
							return math.clamp((1 - scale), 0.3, 1)
						end, GlowScale):Tween(1),
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Rotation = _Computed(function(scale: number)
							return scale * 180
						end, GlowScale):Tween(5),
						BackgroundTransparency = 1,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = _Computed(function(scale: number)
							return UDim2.fromScale(1 + scale * 2, 1 + scale * 2)
						end, GlowScale):Tween(1),
					}),
					_new("TextLabel")({
						Name = "TextLabel",
						Text = "<b>"
							.. string.upper(data.Text)
							.. " "
							.. FormatUtil.ToRomanNumerals(data.Level)
							.. "</b>",
						RichText = true,
						TextColor3 = _Computed(function(col: Color3)
							return LegibilityUtil(Color3.new(0.5, 0.5, 0.5), col)
						end, BackgroundColor),
						TextTransparency = _Computed(function(vis: boolean)
							return if vis then 0 else 1
						end, TextVisible):Tween(TEXT_TWEEN_DURATION),
						ZIndex = 2,
						BackgroundColor3 = BackgroundColor,
						BackgroundTransparency = 0,
						Position = _Computed(function(vis: boolean)
							return if vis then UDim2.fromScale(0.5, 1) else UDim2.fromScale(0.5, 0.5)
						end, TextVisible):Tween(TEXT_TWEEN_DURATION),
						AnchorPoint = _Computed(function(vis: boolean)
							return if vis then Vector2.new(0.5, 0) else Vector2.new(0.5, 0.5)
						end, TextVisible):Tween(TEXT_TWEEN_DURATION),
						Size = UDim2.fromScale(0.5, 0.2),
						AutomaticSize = Enum.AutomaticSize.None,
						TextYAlignment = Enum.TextYAlignment.Center,
						TextScaled = true,
						Font = Enum.Font.Cartoon,
						[_CHILDREN] = {
							_new("UICorner")({
								CornerRadius = UDim.new(0.5, 0),
							}),
							_new("UIPadding")({
								PaddingTop = UDim.new(0.1, 0),
								PaddingBottom = UDim.new(0.1, 0),
								PaddingLeft = UDim.new(0.1, 0),
								PaddingRight = UDim.new(0.1, 0),
							}),
						},
					}),
					_new("Frame")({
						Name = "ModelFrame",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = _Computed(function(modScale: number)
							return UDim2.fromScale(modScale, modScale)
						end, ModelScale:Spring(7.5, 0.5)),
						Rotation = ModelRotation:Spring(5, 0.5),
						BackgroundTransparency = 1,
						ZIndex = 10,
						[_CHILDREN] = {
							modVF,
						},
					}),
					_new("Frame")({
						Name = "EggFrame",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = EggPosition:Tween(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						BackgroundTransparency = 1,
						Size = _Computed(function(modScale: number)
							return UDim2.fromScale(modScale, modScale)
						end, EggScale:Tween(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)),
						Rotation = EggRotation:Spring(10, 0.25),
						ZIndex = 20,
						[_CHILDREN] = {
							eggVF,
						},
					}),
				},
			}),
		},
	}) :: SurfaceGui

	maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		local camera = workspace.CurrentCamera
		local camCF = camera.CFrame
		local fieldOfView = math.rad(camera.FieldOfView)
		local scale = ScaleTween:Get()
		local rot = RotationTween:Get()
		local pos = PositionTween:Get()
		local xWeight = camera.ViewportSize.X / camera.ViewportSize.Y
		local yMaxDim = scale * 2 * math.tan(fieldOfView / 2) * distance
		local xMaxDim = yMaxDim * xWeight

		-- print(xMaxDim)

		BorderSize:Set(scale * camera.ViewportSize.Y * 0.05)

		canvas.Size = Vector3.new(
			individualScale * yMaxDim * SCALE_WEIGHT,
			individualScale * yMaxDim * SCALE_WEIGHT,
			CANVAS_DEPTH
		)
		canvas.CFrame = camCF
			* CFrame.new((pos.X - 0.5) * xMaxDim * 2, (pos.Y - 0.5) * -yMaxDim, -(distance + CANVAS_DEPTH / 2))
			* CFrame.Angles(0, 0, rot)
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surfaceGui.CanvasSize = Vector2.new(1, 1) * scale * camera.ViewportSize.Y * SCALE_WEIGHT
	end))

	local function wiggleEgg(weight: number)
		EggRotation:Set(-EGG_WIGGLE_RANGE * weight)
		task.wait(WIGGLE_FLIP_DELAY)
		EggRotation:Set(EGG_WIGGLE_RANGE * weight)
		task.wait(WIGGLE_FLIP_DELAY)
		EggRotation:Set(-EGG_WIGGLE_RANGE * weight)
		task.wait(WIGGLE_FLIP_DELAY)
		EggRotation:Set(0)
		task.wait(WIGGLE_FLIP_DELAY)
	end

	task.spawn(function()
		Position:Set(position)
		Scale:Set(0.5)

		task.wait(0.5)

		-- wiggle egg
		wiggleEgg(2)
		task.wait(0.5)
		-- wiggleEgg(1.5)
		-- -- task.wait(SPEED_WEIGHT*1)
		-- wiggleEgg(2)

		-- pop egg
		-- task.wait(0.5)
		EggRotation:Set(180)
		EggScale:Set(1.5)
		EggPosition:Set(UDim2.fromScale(0.5, 2.5))
		ModelTransparency:Set(0)
		ModelScale:Set(1)

		-- ModelRotation:Set(0)

		ModelCFrame:Set(CFrame.Angles(0, math.rad(30), 0))
		task.wait(SPEED_WEIGHT * 2)
		ParticleEnabled:Set(true)

		-- Unhide animal
		TextVisible:Set(true)

		if lvl >= 3 then
			SoundService:PlayLocalSound(victorySound)
		end
		if lvl == 2 then
			GlowScale:Set(0.3)
		elseif lvl == 3 then
			GlowScale:Set(1)
		end
		ModelColor:Set(Color3.new(1, 1, 1))
		EggTransparency:Set(1) --hide so that on the zoom back you can't see it

		-- task.wait(0.5)

		task.wait(1 * 2)
		TextVisible:Set(false)
		ParticleEnabled:Set(false)
		Position:Set(Vector2.new(-0.5, 0.5))
		Scale:Set(0)
		task.wait(2.5)
		maid:Destroy()
	end)

	return maid
end

return function(hatches: { [number]: HatchData }, hatchClass: string): Maid
	local maid = Maid.new()
	task.spawn(function()
		local increment = 1 / (#hatches + 1)
		for i, hatchData in ipairs(hatches) do
			task.wait(0.2)
			local x = increment * i
			-- print("X", x)
			-- x = -1 + x*2
			maid:GiveTask(runProcess(hatchData, Vector2.new(x, 0.5), 2 * increment, hatchClass, hatchData.Level))
		end
		task.wait(20)
		maid:Destroy()
	end)

	return maid
end
