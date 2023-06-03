--!strict
-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local GeometryUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("GeometryUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
-- Modules
-- Types
type Signal = Signal.Signal
type Maid = Maid.Maid
type State<V> = ColdFusion.State<V>
type ValueState<V> = ColdFusion.ValueState<V>
export type CursorTracer = {
	__index: CursorTracer,
	_Maid: Maid,
	_IsAlive: boolean,
	IsCursorOverBoard: State<boolean>,
	CursorAbsolutePosition: State<Vector2?>,
	GetHoverState: (self: CursorTracer, guiObject: GuiObject) -> State<boolean>,
	GetClickState:  (self: CursorTracer, guiObject: GuiObject) -> State<boolean>,
	Destroy: (self: CursorTracer) -> nil,
	GetIfOverGuiObject: (self: CursorTracer, guiObject: GuiObject) -> boolean,
	getIfPositionOverGuiObject: (guiObject: GuiObject, cursorAbsolutePosition: Vector2) -> boolean,
	new: (surfaceGui: SurfaceGui) -> CursorTracer,
}
-- Constants
local DEBUG_ENABLED = RunService:IsStudio() and false
-- Variables
-- References
-- Private functions
function getIfClicking(): boolean
	local mouseButtons: { [number]: InputObject } = UserInputService:GetMouseButtonsPressed()
	for i, inputObject in ipairs(mouseButtons) do
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			return true
		end
	end
	return false
end

-- Class
local CursorTracer = {} :: CursorTracer
CursorTracer.__index = CursorTracer

function CursorTracer:Destroy()
	if not self._IsAlive then return end
	self._IsAlive = false
	self._Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function CursorTracer:GetIfOverGuiObject(guiObject: GuiObject): boolean
	local cursorAbsolutePosition = self.CursorAbsolutePosition:Get()
		
	if not RunService:IsRunning() then
		cursorAbsolutePosition = UserInputService:GetMouseLocation()
	end

	if cursorAbsolutePosition then
		return self.getIfPositionOverGuiObject(guiObject, cursorAbsolutePosition)
	else
		return false
	end
end

function CursorTracer:GetHoverState(guiObject: GuiObject): State<boolean>
	local guiMaid = self._Maid:GiveTask(Maid.new())
	
	local _fuse = ColdFusion.fuse(guiMaid)

	local _new = _fuse.new
	local _import = _fuse.import
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local PrivateHoverState = _Value(false)

	guiMaid:GiveTask(RunService.RenderStepped:Connect(function()
		PrivateHoverState:Set(self:GetIfOverGuiObject(guiObject))
	end))

	guiMaid:GiveTask(guiObject.Destroying:Connect(function()
		guiMaid:Destroy()
	end))

	return _Computed(function(isHover: boolean)
		return isHover
	end, PrivateHoverState)
end

function CursorTracer:GetClickState(guiObject: GuiObject): State<boolean>
	local guiMaid = self._Maid:GiveTask(Maid.new())
	
	local _fuse = ColdFusion.fuse(guiMaid)
	local _new = _fuse.new
	local _import = _fuse.import
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local IsClicking = _Value(getIfClicking())
	local IsHovering = self:GetHoverState(guiObject)
	guiMaid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		if IsHovering:Get() then
			local isClick = getIfClicking()

			-- print("hover", IsHovering:Get(), "click", isClick)
			IsClicking:Set(isClick)
		end

	end))

	guiMaid:GiveTask(guiObject.Destroying:Connect(function()
		guiMaid:Destroy()
	end))

	return _Computed(function(isClick: boolean, isHover: boolean): boolean
		return isClick and isHover
	end, IsClicking, IsHovering)
end

function CursorTracer.getIfPositionOverGuiObject(guiObject: GuiObject, cursorAbsolutePosition: Vector2)
	local absPos = guiObject.AbsolutePosition
	local absSize = guiObject.AbsoluteSize

	local startX = absPos.X
	local startY = absPos.Y
	local finX = startX + absSize.X
	local finY = startY + absSize.Y

	return cursorAbsolutePosition.X > startX
		and cursorAbsolutePosition.X < finX
		and cursorAbsolutePosition.Y > startY
		and cursorAbsolutePosition.Y < finY
end

function CursorTracer.new(surfaceGui: SurfaceGui)
	local self: CursorTracer = setmetatable({}, CursorTracer) :: any
	self._IsAlive = true
	self._Maid = Maid.new()

	local _fuse = ColdFusion.fuse(self._Maid)
	local _new = _fuse.new
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed
	local _CHILDREN = _fuse.CHILDREN

	local CursorAbsolutePosition: ValueState<Vector2?> = _Value(nil) :: any

	self.CursorAbsolutePosition = _Computed(function(absPos: Vector2?)
		return absPos
	end, CursorAbsolutePosition)

	self.IsCursorOverBoard = _Computed(function(absPos: Vector2?)
		return absPos ~= nil
	end, self.CursorAbsolutePosition)

	if DEBUG_ENABLED then
		_new("Frame")({
			Parent = surfaceGui,
			Size = UDim2.fromOffset(20,20),
			BackgroundColor3 = Color3.new(1,0,0),
			AnchorPoint = Vector2.new(0.5,0.5),
			Visible = _Computed(function(pos: Vector2?)
				return pos ~= nil
			end, CursorAbsolutePosition),
			Position = _Computed(function(pos: Vector2?)
				if pos then
					return UDim2.fromOffset(pos.X, pos.Y)
				else
					return UDim2.fromOffset(0,0)
				end
			end, CursorAbsolutePosition),
			[_CHILDREN] = {
				_new("UICorner")({
					CornerRadius = UDim.new(1,0),
				})
			}
		})
	end	

	self._Maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		-- get part
		local part = (surfaceGui.Adornee or surfaceGui.Parent) :: Part?
		if not part then return end
		assert(part)

		local screenPoint = UserInputService:GetMouseLocation()
		local camRay = workspace.CurrentCamera:ViewportPointToRay(screenPoint.X, screenPoint.Y)
		local surfaceCF = part.CFrame * CFrame.new(0, 0, -part.Size.Z / 2)

		local hitPoint = GeometryUtil.getPlaneIntersection(
			camRay.Origin,
			camRay.Direction.Unit,
			surfaceCF.Position,
			-surfaceCF.LookVector
		)
		if DEBUG_ENABLED then
			local debugMaid = Maid.new()
			self._Maid._debug = debugMaid

			local debugPart = debugMaid:GiveTask(Instance.new("Part"))
			debugPart.Position = hitPoint
			debugPart.Size = Vector3.new(1,1,1)
			debugPart.Shape = Enum.PartType.Ball
			debugPart.Transparency = 0.5
			debugPart.Color = Color3.new(0,1,1)
			debugPart.Anchored = true
			debugPart.CanQuery = false
			debugPart.CanCollide = false
			debugPart.CanTouch = false
			debugPart.Parent = workspace
		end

		local offset = (surfaceCF:Inverse() * CFrame.new(hitPoint)).Position * -1

		if math.abs(offset.Y) < part.Size.Y / 2 and math.abs(offset.X) < part.Size.X / 2 then
			local scaleY = (offset.Y - part.Size.Y / 2) / part.Size.Y + 1
			local scaleX = (offset.X - part.Size.X / 2) / part.Size.X + 1

			local pixelY = scaleY * surfaceGui.AbsoluteSize.Y
			local pixelX = scaleX * surfaceGui.AbsoluteSize.X

			CursorAbsolutePosition:Set(Vector2.new(pixelX, pixelY))
		else
			CursorAbsolutePosition:Set(nil)
		end
	end))

	return self
end

return CursorTracer

	