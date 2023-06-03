--!strict
-- https://github.com/EmeraldSlash/self
-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Maid)
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").ServiceProxy)
-- Modules
local PlayerModule = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")) :: any
-- Types
type Maid = Maid.Maid
export type MouseFilter = (
	result: RaycastResult,
	raycastParams: RaycastParams,
	origin: Vector3,
	direction: Vector3
) -> boolean
export type RbxMouse = {
	_Maid: Maid,
	__index: RbxMouse,
	init: (maid: Maid) -> nil,
	new: () -> RbxMouse,
	absoluteToInset: ((pos: Vector2) -> Vector2) & ((pos: UDim2) -> UDim2),
	insetToAbsolute: ((pos: Vector2) -> Vector2) & ((pos: UDim2) -> UDim2),

	_DeltaSensitivity: number,
	_CurrentFrameId: number,
	_LastRecordedDelta: Vector2,
	_LastRecordedDeltaId: number,

	Position: Vector2,
	InsetPosition: Vector2,

	Button1Pressed: RBXScriptSignal,
	Button1Released: RBXScriptSignal,
	Button2Pressed: RBXScriptSignal,
	Button2Released: RBXScriptSignal,
	Button3Pressed: RBXScriptSignal,
	Button3Released: RBXScriptSignal,
	Scrolled: RBXScriptSignal,
	ScrolledUp: RBXScriptSignal,
	ScrolledDown: RBXScriptSignal,
	Moved: RBXScriptSignal,

	Button1KeyCode: Enum.KeyCode,
	Button2KeyCode: Enum.KeyCode?,
	Button3KeyCode: Enum.KeyCode?,

	Button1: boolean,
	Button2: boolean,
	Button3: boolean,

	Button1Inputs: { [number]: InputObject },
	Button2Inputs: { [number]: InputObject },
	Button3Inputs: { [number]: InputObject },

	FireButton1Pressed: (self: RbxMouse, input: InputObject, gameProcessed: boolean) -> nil,
	FireButton2Pressed: (self: RbxMouse, input: InputObject, gameProcessed: boolean) -> nil,
	FireButton3Pressed: (self: RbxMouse, input: InputObject, gameProcessed: boolean) -> nil,

	FireButton1Released: (self: RbxMouse, duration: number, input: InputObject, gameProcessed: boolean) -> nil,
	FireButton2Released: (self: RbxMouse, duration: number, input: InputObject, gameProcessed: boolean) -> nil,
	FireButton3Released: (self: RbxMouse, duration: number, input: InputObject, gameProcessed: boolean) -> nil,
	FireMoved: (self: RbxMouse, deltaPosition: Vector2, input: InputObject, gameProcessed: boolean) -> nil,
	FireScrolled: (self: RbxMouse, offset: number, input: InputObject, gameProcessed: boolean) -> nil,
	FireScrolledUp: (self: RbxMouse, offset: number, input: InputObject, gameProcessed: boolean) -> nil,
	FireScrolledDown: (self: RbxMouse, offset: number, input: InputObject, gameProcessed: boolean) -> nil,

	GetVisible: (self: RbxMouse) -> boolean,
	SetVisible: (self: RbxMouse, val: boolean) -> nil,
	GetBehavior: (self: RbxMouse) -> Enum.MouseBehavior,
	SetBehavior: (self: RbxMouse, behavior: Enum.MouseBehavior) -> nil,
	SetBehaviorEveryFrame: (self: RbxMouse, behavior: Enum.MouseBehavior, priority: number) -> nil,
	StopSettingBehaviorEveryFrame: (self: RbxMouse) -> nil,
	GetSensitivity: (self: RbxMouse) -> number,
	SetSensitivity: (self: RbxMouse, sensitivity: number) -> nil,
	GetEnabled: (self: RbxMouse) -> boolean,
	GetDelta: (self: RbxMouse) -> Vector2,
	GetButtonsPressed: (self: RbxMouse) -> { [number]: Enum.KeyCode },
	IsButtonPressed: (self: RbxMouse, mouseButton: Enum.UserInputType) -> boolean,
	IsTouchUsingThumbstick: (self: RbxMouse, input: InputObject) -> boolean,
	IsInputNew: (self: RbxMouse, input: InputObject) -> boolean,
	GetIcon: (self: RbxMouse) -> string,
	SetIcon: (self: RbxMouse, icon: string) -> nil,
	PushIcon: (self: RbxMouse, icon: string) -> nil,
	PopIcon: (self: RbxMouse, icon: string) -> nil,
	ClearAllIcons: (self: RbxMouse) -> nil,
	ClearIconStack: (self: RbxMouse) -> nil,
	GetRay: (self: RbxMouse, maxDistance: number?, position: Vector2?) -> Ray,
	Cast: (
		self: RbxMouse,
		origin: Vector3,
		direction: Vector3,
		raycastParams: RaycastParams,
		filter: MouseFilter?,
		mutateParams: boolean?
	) -> RaycastResult,
	GetTargetIgnore: (self: RbxMouse, ignoreList: { [number]: Instance }?) -> RaycastResult,
	GetTarget: (
		self: RbxMouse,
		params: RaycastParams?,
		filter: MouseFilter?,
		ray: Ray?,
		mutateParams: boolean?
	) -> RaycastResult,
	GetIsFilterVisible: (self: RbxMouse, result: RaycastResult) -> boolean,
	GetIsFilterCanCollide: (self: RbxMouse, result: RaycastResult) -> boolean,
	BeginSingleInput: (self: RbxMouse, key: Enum.KeyCode, input: InputObject) -> boolean,
	EndSingleInput: (self: RbxMouse, key: Enum.KeyCode, input: InputObject?) -> nil,
	Destroy: (self: RbxMouse) -> nil,
}
-- Constants

local DEFAULT_MAX_DISTANCE = 1000

-- Variables
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local iconStack = { "" }
local iconStackCount = 1
local activeInputs: { [Enum.KeyCode]: InputObject? } = {}
-- References
-- Private functions
local function invalidArgument(index: number, name: string, correctType: string, value: any, depth: number)
	error(
		("Argument %d '%s' must be a %s (received value %s of type %s)."):format(
			index,
			name,
			correctType,
			tostring(value),
			typeof(value)
		),
		depth + 1
	)
end
-- Class

local RbxMouse: RbxMouse = {} :: any
RbxMouse.__index = RbxMouse

function RbxMouse.absoluteToInset(position: any): any
	local topLeft = GuiService:GetGuiInset()
	if typeof(position) == "Vector2" then
		position -= topLeft
	elseif typeof(position) == "UDim2" then
		position -= UDim2.fromOffset(topLeft.X, topLeft.Y)
	end
	return position
end

function RbxMouse.insetToAbsolute(position: any): any
	local topLeft = GuiService:GetGuiInset()
	if typeof(position) == "Vector2" then
		position += topLeft
	elseif typeof(position) == "UDim2" then
		position += UDim2.fromOffset(topLeft.X, topLeft.Y)
	end
	return position
end

function RbxMouse.new()
	local UIT = Enum.UserInputType
	local UIT_MM = UIT.MouseMovement
	local UIT_M1 = UIT.MouseButton1
	local UIT_M2 = UIT.MouseButton2
	local UIT_M3 = UIT.MouseButton3
	local UIT_MW = UIT.MouseWheel
	local UIT_T = UIT.Touch

	local self: RbxMouse = setmetatable({}, RbxMouse) :: any

	local function addSignal(name)
		local bindable = Instance.new("BindableEvent")
		self[name] = bindable.Event
		self["Fire" .. name] = function(_, ...)
			bindable:Fire(...)
		end
	end

	addSignal("Button1Pressed")
	addSignal("Button1Released")
	addSignal("Button2Pressed")
	addSignal("Button2Released")
	addSignal("Button3Pressed")
	addSignal("Button3Released")
	addSignal("Scrolled")
	addSignal("ScrolledUp")
	addSignal("ScrolledDown")
	addSignal("Moved")

	self.Button1KeyCode = Enum.KeyCode.ButtonA
	self.Button2KeyCode = nil
	self.Button3KeyCode = nil

	self.Button1 = false
	self.Button2 = false
	self.Button3 = false

	self.Button1Inputs = {}
	self.Button2Inputs = {}
	self.Button3Inputs = {}

	self._CurrentFrameId = 0
	self._DeltaSensitivity = 0

	local button1DownAt = 0
	local button2DownAt = 0
	local button3DownAt = 0

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if
			(input.UserInputType == UIT_M1)
			or (input.UserInputType == UIT_T)
			or (input.KeyCode == self.Button1KeyCode)
		then
			button1DownAt = os.clock()
			self.Button1 = true
			self.Button1Inputs[#self.Button1Inputs + 1] = input
			self:FireButton1Pressed(input, gameProcessed)
		elseif (input.UserInputType == UIT_M2) or (input.KeyCode == self.Button2KeyCode) then
			button2DownAt = os.clock()
			self.Button2 = true
			self.Button2Inputs[#self.Button2Inputs + 1] = input
			self:FireButton2Pressed(input, gameProcessed)
		elseif (input.UserInputType == UIT_M3) or (input.KeyCode == self.Button3KeyCode) then
			button3DownAt = os.clock()
			self.Button3 = true
			self.Button3Inputs[#self.Button3Inputs + 1] = input
			self:FireButton3Pressed(input, gameProcessed)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if
			(input.UserInputType == UIT_M1)
			or (input.UserInputType == UIT_T)
			or (input.KeyCode == self.Button1KeyCode)
		then
			self.Button1 = false
			table.remove(self.Button1Inputs, table.find(self.Button1Inputs, input))
			self:FireButton1Released(os.clock() - button1DownAt, input, gameProcessed)
		elseif (input.UserInputType == UIT_M2) or (input.KeyCode == self.Button2KeyCode) then
			self.Button2 = false
			table.remove(self.Button2Inputs, table.find(self.Button2Inputs, input))
			self:FireButton2Released(os.clock() - button2DownAt, input, gameProcessed)
		elseif (input.UserInputType == UIT_M3) or (input.KeyCode == self.Button3KeyCode) then
			self.Button3 = false
			table.remove(self.Button1Inputs, table.find(self.Button2Inputs, input))
			self:FireButton3Released(os.clock() - button3DownAt, input, gameProcessed)
		end
	end)

	self.Position = UserInputService:GetMouseLocation()
	self.InsetPosition = self.absoluteToInset(self.Position)

	local lastPosition = self.Position
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if (input.UserInputType == UIT_MM) or (input.UserInputType == UIT_T) then
			self.InsetPosition = Vector2.new(input.Position.X, input.Position.Y)
			self.Position = self.insetToAbsolute(self.InsetPosition)

			local delta = Vector2.new(input.Delta.X, input.Delta.Y)
			if delta.Magnitude == 0 then
				delta = (self.Position - lastPosition) * UserInputService.MouseDeltaSensitivity
			end
			delta *= self._DeltaSensitivity
			lastPosition = self.Position
			self._LastRecordedDelta = delta
			self._LastRecordedDeltaId = self._CurrentFrameId

			self:FireMoved(delta, input, gameProcessed)
		elseif input.UserInputType == UIT_MW then
			self:FireScrolled(input.Position.Z, input, gameProcessed)
			if input.Position.Z > 0 then
				self:FireScrolledUp(input.Position.Z, input, gameProcessed)
			elseif input.Position.Z < 0 then
				self:FireScrolledDown(input.Position.Z, input, gameProcessed)
			end
		end
	end)

	RunService:BindToRenderStep("RbxMouseFrame", Enum.RenderPriority.First.Value, function()
		self._CurrentFrameId += 1
	end)
	return self
end

function RbxMouse:GetVisible()
	return UserInputService.MouseIconEnabled
end
function RbxMouse:SetVisible(visible)
	UserInputService.MouseIconEnabled = visible
	return nil
end

function RbxMouse:GetBehavior()
	return UserInputService.MouseBehavior
end
function RbxMouse:SetBehavior(behavior)
	if behavior ~= nil and typeof(behavior) ~= "EnumItem" then
		invalidArgument(1, "behavior", "MouseBehavior enum", behavior, 2)
	end
	UserInputService.MouseBehavior = behavior
	return nil
end

function RbxMouse:SetBehaviorEveryFrame(behavior, priority)
	if behavior ~= nil and typeof(behavior) ~= "EnumItem" then
		invalidArgument(1, "behavior", "MouseBehavior enum", behavior, 2)
	end
	if priority ~= nil and type(priority) ~= "number" then
		invalidArgument(2, "priority", "integer", priority, 2)
	end
	behavior = behavior or UserInputService.MouseBehavior
	priority = priority or Enum.RenderPriority.Camera.Value - 1
	RunService:BindToRenderStep("RbxMouseBehavior", priority, function()
		UserInputService.MouseBehavior = behavior
	end)
	return nil
end

function RbxMouse:StopSettingBehaviorEveryFrame()
	RunService:UnbindFromRenderStep("RbxMouseBehavior")
	return nil
end

function RbxMouse:GetSensitivity()
	return self._DeltaSensitivity
end
function RbxMouse:SetSensitivity(sensitivity)
	self._DeltaSensitivity = sensitivity
	return nil
end

function RbxMouse:GetEnabled()
	return UserInputService.MouseEnabled
end

function RbxMouse:GetDelta()
	local delta = UserInputService:GetMouseDelta()
	if delta.Magnitude == 0 then
		-- Only return the unlocked MouseDelta if it was updated this frame
		if self._LastRecordedDeltaId == self._CurrentFrameId - 1 then
			delta = self._LastRecordedDelta
		end
	else
		delta *= self._DeltaSensitivity
	end
	return delta
end

function RbxMouse:GetButtonsPressed()
	return UserInputService:GetMouseButtonsPressed()
end
function RbxMouse:IsButtonPressed(mouseButton)
	return UserInputService:IsMouseButtonPressed(mouseButton)
end

function RbxMouse:IsTouchUsingThumbstick(inputObject)
	local result = false
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		local controls = PlayerModule:GetControls()
		if controls then
			local controller = controls:GetActiveController()
			if controller then
				result = (inputObject == controller.moveTouchObject)
			end
		end
	end
	return result
end

function RbxMouse:IsInputNew(inputObject)
	return inputObject.UserInputState == Enum.UserInputState.Begin
end

function RbxMouse:BeginSingleInput(key, inputObject)
	local valid = not activeInputs[key]
	if valid then
		activeInputs[key] = inputObject
	end
	return valid
end

function RbxMouse:EndSingleInput(key, inputObject)
	local active = activeInputs[key]
	if (active ~= nil) and (inputObject == nil or active == inputObject) then
		activeInputs[key] = nil
	end
	return nil
end

function RbxMouse:GetIcon()
	return mouse.Icon
end

function RbxMouse:SetIcon(icon)
	if type(icon) == "string" or icon == nil then
		iconStack[1] = icon or ""
		if iconStackCount == 1 then
			mouse.Icon = iconStack[1]
		end
	else
		invalidArgument(1, "icon", "string", icon, 2)
	end
	return nil
end

function RbxMouse:PushIcon(icon)
	if type(icon) == "string" or icon == nil then
		iconStackCount += 1
		iconStack[iconStackCount] = icon or ""
		mouse.Icon = iconStack[iconStackCount]
	else
		invalidArgument(1, "icon", "string", icon, 2)
	end
	return nil
end

function RbxMouse:PopIcon(icon)
	if icon == nil or type(icon) == "string" then
		if iconStackCount > 1 then
			if icon then
				for index = iconStackCount, 1, -1 do
					if iconStack[index] == icon then
						table.remove(iconStack, index)
						iconStackCount -= 1
						break
					end
				end
			else
				iconStack[iconStackCount] = nil
				iconStackCount -= 1
			end
		end
		mouse.Icon = iconStack[iconStackCount]
	else
		invalidArgument(1, "icon", "string", icon, 2)
	end
	return nil
end

function RbxMouse:ClearAllIcons()
	iconStackCount = 1
	iconStack = { "" }
	mouse.Icon = iconStack[1]
	return nil
end

function RbxMouse:ClearIconStack()
	iconStackCount = 1
	iconStack = { iconStack[1] }
	mouse.Icon = iconStack[1]
	return nil
end

function RbxMouse:GetRay(maxDistance, position)
	local camera = workspace.CurrentCamera

	if maxDistance then
		if type(maxDistance) ~= "number" then
			invalidArgument(1, "maxDistance", "number", maxDistance, 2)
		end
	else
		maxDistance = DEFAULT_MAX_DISTANCE
	end

	if position then
		if typeof(position) == "UDim2" then
			position = Vector2.new(
				camera.ViewportSize.X * position.X.Scale + position.X.Offset,
				camera.ViewportSize.Y * position.Y.Scale + position.Y.Offset
			)
		elseif typeof(position) == "Vector2" then
			position = position
		else
			invalidArgument(2, "position", "Vector2 or UDim2", position, 2)
		end
	else
		position = self.Position
	end
	assert(position ~= nil)
	local ray = camera:ViewportPointToRay(position.X, position.Y).Unit
	return Ray.new(ray.Origin, ray.Direction * maxDistance)
end

function RbxMouse:GetTargetIgnore(ignoreList)
	if ignoreList ~= nil and type(ignoreList) ~= "table" then
		invalidArgument(1, "ignoreList", "list of Instances to ignore", ignoreList, 2)
	end
	local params = RaycastParams.new()
	if ignoreList then
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList
	end
	local ray = self:GetRay()
	return self:Cast(ray.Origin, ray.Direction, params, nil, true)
end

function RbxMouse:GetTarget(params, filter, ray, mutateParams)
	if params == nil then
		params = RaycastParams.new()
		mutateParams = true
	elseif typeof(params) ~= "RaycastParams" then
		invalidArgument(1, "params", "RaycastParams instance", params, 2)
	end

	if filter ~= nil and type(filter) ~= "function" then
		invalidArgument(2, "filter", "function", filter, 2)
	end

	if ray ~= nil and typeof(ray) ~= "Ray" then
		invalidArgument(3, "ray", "Ray instance", ray, 2)
	else
		ray = self:GetRay()
	end
	assert(ray ~= nil and params ~= nil)
	return self:Cast(ray.Origin, ray.Direction, params, filter, mutateParams)
end

local function removeFromWhitelist(list: { [number]: Instance }, instance: Instance): { [number]: Instance }
	-- Find and remove from the whitelist the ancestor that contains instance.
	local ancestor
	for index, item in pairs(list) do
		if item == instance or instance:IsDescendantOf(item) then
			ancestor = item
			table.remove(list, index)
			break
		end
	end
	if ancestor then
		-- Traverse the game tree from instance to ancestor, adding all children
		-- within the same ancestor to the whitelist except for the ancestors
		-- of the instance we're removing.
		local current = instance
		local listCount = #list
		while current and current ~= ancestor do
			local parent = current.Parent
			assert(parent ~= nil)
			for _, child in pairs(parent:GetChildren()) do
				if child ~= current then
					listCount += 1
					list[listCount] = current
				end
			end
			current = parent
		end
	end
	return list
end

function RbxMouse:Cast(origin, direction, raycastParams, filter, mutateParams)
	local originalInstances = if not mutateParams and raycastParams
		then raycastParams.FilterDescendantsInstances
		else {}
	local currentOrigin = origin
	local currentDirection = direction
	local result
	while true do
		result = workspace:Raycast(currentOrigin, currentDirection, raycastParams)
		if not result or not filter or filter(result, raycastParams, origin, direction) then
			break
		else
			-- Reduce the length of the ray so that it won't exceed the distance
			-- of the original ray.
			currentOrigin = result.Position
			currentDirection = direction - (currentOrigin - origin)

			-- Make the instance be ignored in the next raycast.
			if raycastParams.FilterType == Enum.RaycastFilterType.Exclude then
				local newInstances = raycastParams.FilterDescendantsInstances
				newInstances[#newInstances + 1] = result.Instance
				raycastParams.FilterDescendantsInstances = newInstances
			elseif raycastParams.FilterType == Enum.RaycastFilterType.Include then
				raycastParams.FilterDescendantsInstances =
					removeFromWhitelist(raycastParams.FilterDescendantsInstances, result.Instance)
			end
		end
	end
	if originalInstances then
		raycastParams.FilterDescendantsInstances = originalInstances
	end
	return result
end

function RbxMouse:GetIsFilterVisible(result)
	local part = result.Instance :: BasePart
	return part.Transparency < 1
end

function RbxMouse:GetIsFilterCanCollide(result)
	local part = result.Instance :: BasePart
	return part.CanCollide
end

function RbxMouse:Destroy()
	self._Maid:Destroy()
	local t = self :: any
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)

	return nil
end

local currentMouse = nil
local proxy = ServiceProxy(function()
	return currentMouse or RbxMouse
end)

function RbxMouse.init(maid: Maid)
	currentMouse = maid:GiveTask(RbxMouse.new())
	return nil
end

return proxy
