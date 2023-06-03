---@diagnostic disable: undefined-type
--!strict
local RunService = game:GetService("RunService")

local _Package = script.Parent
local _Packages = _Package.Parent

-- Packages
local _Maid = require(_Packages.Maid)
local _NetworkUtil = require(_Packages.NetworkUtil)

-- Import types
local _Types = require(_Package.Types)
type State<T> = _Types.State<T>
type ValueState<T> = _Types.ValueState<T>
type CanBeState<T> = _Types.CanBeState<T>
type Maid = _Maid.Maid
type FusionSpecialKey = _Types.FusionSpecialKey
type FusionKey = _Types.FusionKey
type FusionPropertyTable = _Types.FusionPropertyTable

-- Fusion references
local FusionFolder = _Package.Fusion

-- Fusion states
local FusionStateFolder = FusionFolder.State
local _FusionValue = require(FusionStateFolder.Value) :: (...any) -> any
local _FusionComputed = require(FusionStateFolder.Computed) :: (...any) -> any
local _FusionObserver = require(FusionStateFolder.Observer) :: (...any) -> any
local _FusionForKeys = require(FusionStateFolder.ForKeys) :: (...any) -> any
local _FusionForPairs = require(FusionStateFolder.ForPairs) :: (...any) -> any
local _FusionForValues = require(FusionStateFolder.ForValues) :: (...any) -> any

-- Fusion animations
local FusionAnimationFolder = FusionFolder.Animation
local _FusionSpring = require(FusionAnimationFolder.Spring) :: (...any) -> any
local _FusionTween = require(FusionAnimationFolder.Tween) :: (...any) -> any

-- Fusion symbols
local FusionInstanceFolder = FusionFolder.Instances
local _FusionChildren = require(FusionInstanceFolder.Children)
local _FusionOnChange = require(FusionInstanceFolder.OnChange)
local _FusionOnEvent = require(FusionInstanceFolder.OnEvent)
local _FusionOut = require(FusionInstanceFolder.Out)
local _FusionRef = require(FusionInstanceFolder.Ref)
local _FusionNew = require(FusionInstanceFolder.New)
local _FusionHydrate = require(FusionInstanceFolder.Hydrate)

-- Fusion Utils
local FusionUtil = FusionFolder.Utility
local _FusionCleanUp = require(FusionUtil.cleanup)

-- Fusion types
local _FusionPubTypes = require(FusionFolder.PubTypes)
local _FusionTypes = require(FusionFolder.Types)

-- Constants
local DEFAULT_REMOTE_RATE = 60
local DEFAULT_REMOTE_ID = ""

function setDependencies(state: any, dependencies: {[number]: any})
	for i, dependency in ipairs(dependencies) do
		dependency.dependentSet[state] = true
	end
end

return function(maid: Maid)
	local Interface = {}
	Interface.__index = Interface

	Interface._Maid = maid

	function Interface._getIfState(possibleState: any): boolean
		if typeof(possibleState) == "table" then
			if possibleState["type"] == "State" then
				return true
			end
		end
		return false
	end

	function Interface.import<T>(state: CanBeState<T>?, alt: CanBeState<T>): State<T>
		if state == nil then
			if Interface._getIfState(alt) then
				return alt :: State<T>
			else
				return Interface.Value(alt) :: any
			end
		else
			if Interface._getIfState(state) then
				return state :: State<T>
			else
				return Interface.Value(state :: T)
			end
		end
	end

	function Interface.ForKeys<KI, KO>(
		input: CanBeState<{ [KI]: any }>,
		processor: (key: KI, maid: Maid) -> KO
	): State<{ [KO]: any }>
		return Interface._init(
			_FusionForKeys(input, function(key: KI): (KO, Maid)
				local _maid = _Maid.new()
				maid:GiveTask(_maid)
				return processor(key, _maid), _maid
			end, function(key: KO, _maid: Maid)
				_maid:Destroy()
			end),
			_FusionForKeys
		)
	end

	function Interface.ForValues<VI, VO>(
		input: CanBeState<{ [any]: VI }>,
		processor: (val: VI, maid: Maid) -> VO
	): State<{ [any]: VO }>
		return Interface._init(
			_FusionForValues(input, function(val: VI): (VO, Maid)
				local _maid = _Maid.new()
				maid:GiveTask(_maid)
				return processor(val, _maid), _maid
			end, function(val: VO, _maid: Maid)
				_maid:Destroy()
			end),
			_FusionForValues
		)
	end

	function Interface.ForPairs<KI, VI, KO, VO>(
		input: CanBeState<{ [KI]: VI }>,
		processor: (key: KI, val: VI, maid: Maid) -> (KO, VO)
	): State<{ [any]: VO }>
		return Interface._init(
			_FusionForPairs(input, function(key: KI, val: VI): (KO, VO, Maid)
				local _maid = _Maid.new()
				maid:GiveTask(_maid)
				local kOut, vOut = processor(key, val, _maid)
				return kOut, vOut, _maid
			end, function(key: KO, val: VO, _maid: Maid)
				_maid:Destroy()
			end),
			_FusionForPairs
		)
	end

	function Interface.Computed<T>(processor: (...any) -> T, ...: any): State<T>
		local paramStates = {} :: { [number]: any }

		for i, state: State<any> in ipairs({ ... }) do
			if Interface._getIfState(state) then
				table.insert(paramStates, state)
			end
		end

		local possibleDestructor = ({ ... })[1]
		local hasDestructor: boolean = typeof(possibleDestructor) == "function"

		local compState = _FusionComputed(function()
			local vals = {}
			for i, paramState in ipairs(paramStates) do
				if paramState.Get then
					vals[i] = paramState:Get()
				else
					vals[i] = nil
				end
			end
			local val = processor(table.unpack(vals, 1, #paramStates))
			return val
		end, if hasDestructor then possibleDestructor else function() end)

		setDependencies(compState, paramStates)

		return Interface._init(compState, _FusionComputed) :: any
	end

	function Interface.Value<T>(initalVal: T): ValueState<T>
		local valState = _FusionValue(initalVal)

		return Interface._init(valState, _FusionValue) :: any
	end

	function Interface.Tween<T>(
		goal: State<T>,
		durationState: CanBeState<number>?,
		easingStyleState: CanBeState<Enum.EasingStyle>?,
		easingDirectionState: CanBeState<Enum.EasingDirection>?,
		repetitionsState: CanBeState<number>?,
		reversesState: CanBeState<boolean>?,
		delayTimeState: CanBeState<number>?
	): State<T>
		durationState = Interface.import(durationState, 0.2)
		easingStyleState = Interface.import(easingStyleState, Enum.EasingStyle.Quad)
		easingDirectionState = Interface.import(easingDirectionState, Enum.EasingDirection.InOut)
		repetitionsState = Interface.import(repetitionsState, 0)
		reversesState = Interface.import(reversesState, false)
		delayTimeState = Interface.import(delayTimeState, 0)

		local tweenInfoState = Interface.Computed(
			function(
				duration: number,
				easingStyle: Enum.EasingStyle,
				easingDirection: Enum.EasingDirection,
				repetitions: number,
				reverses: boolean,
				delayTime: number
			): TweenInfo
				return TweenInfo.new(duration, easingStyle, easingDirection, repetitions, reverses, delayTime)
			end,
			durationState,
			easingStyleState,
			easingDirectionState,
			repetitionsState,
			reversesState,
			delayTimeState
		)

		local tweenState = _FusionTween(goal, tweenInfoState)

		return Interface._init(tweenState, _FusionTween) :: any
	end

	function Interface.Spring<T>(goal: State<T>, speed: number?, dampingRatio: number?): State<T>
		local springState = _FusionSpring(goal, speed, dampingRatio)
		return Interface._init(springState, _FusionSpring) :: any
	end

	function Interface.new(className: string)
		local instConstructor = _FusionNew(className)
		return function(parameters: { [any]: any })
			local inst = instConstructor(parameters)
			maid:GiveTask(inst)
			return inst
		end
	end

	function Interface.mount(inst: Instance)
		local instBinder = _FusionHydrate(inst)
		return function(parameters: { [any]: any })
			instBinder(parameters)
			return inst
		end
	end

	function Interface.receive<T>(remoteName: string, id: string?, rate: number?, player: Player?): State<T>
		id = id or DEFAULT_REMOTE_ID
		assert(id ~= nil)

		rate = rate or DEFAULT_REMOTE_RATE
		assert(rate ~= nil)

		local valState = Interface.Value(nil) :: any

		local remoteEvent = _NetworkUtil.getRemoteEvent(remoteName)
		local promptFunction = _NetworkUtil.getRemoteFunction(remoteName)

		local lastUpdate = 0
		local function onReceive(rPlayer: Player?, rId: string, val: any)
			if rId ~= id then
				return
			end
			if tick() - lastUpdate >= 1 / rate then
				lastUpdate = tick()
				valState:Set(val)
			end
		end

		if RunService:IsServer() then
			maid:GiveTask(remoteEvent.OnServerEvent:Connect(function(...: any)
				onReceive(...)
			end))

			if player then
				valState:Set(promptFunction:InvokeClient(player))
			end
		else
			maid:GiveTask(remoteEvent.OnClientEvent:Connect(function(...: any)
				onReceive(game.Players.LocalPlayer, ...)
			end))

			if player then
				valState:Set(promptFunction:InvokeServer(player))
			end
		end

		return valState
	end

	function Interface.transmit<T>(
		state: State<T>,
		remoteName: string,
		id: string?,
		rate: number?,
		player: Player?
	): RBXScriptConnection
		id = id or DEFAULT_REMOTE_ID
		assert(id ~= nil)

		rate = rate or DEFAULT_REMOTE_RATE
		assert(rate ~= nil)

		local remoteEvent = _NetworkUtil.getRemoteEvent(remoteName)
		local promptFunction = _NetworkUtil.getRemoteFunction(remoteName)
		local lastUpdate = 0

		local function transmit(tPlayer: Player?, val: any?, tId: string, tRate: number)
			if tId ~= id then
				return
			end
			if tick() - lastUpdate >= 1 / rate then
				lastUpdate = tick()
				if RunService:IsServer() then
					if tPlayer then
						remoteEvent:FireClient(tPlayer, tId, val)
					else
						remoteEvent:FireAllClients(tId, val)
					end
				else
					remoteEvent:FireServer(tId, val)
				end
			end
		end

		if RunService:IsServer() then
			promptFunction.OnServerInvoke = function(tPlayer: Player, tId: string)
				if tId ~= id then
					return
				end
				return state:Get()
			end
		else
			promptFunction.OnClientInvoke = function(tPlayer: Player, tId: string)
				if tId ~= id then
					return
				end
				return state:Get()
			end
		end

		local connection: any = state:Connect(function(cur: T, prev: T?)
			transmit(player, state:Get(), id, rate)
		end)

		return connection
	end

	function Interface._init<T>(state: State<T>, fusionConstructor: (...any) -> State<T>): State<T>
		return nil :: any
	end

	Interface.OUT = _FusionOut :: any
	Interface.REF = _FusionRef :: any
	Interface.CHILDREN = _FusionChildren :: any
	Interface.ON_EVENT = _FusionOnEvent :: any
	Interface.PROPERTY_CHANGED = _FusionOnChange :: any

	return Interface
end
