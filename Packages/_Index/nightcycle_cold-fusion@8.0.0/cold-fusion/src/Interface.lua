--!strict
local Package = script.Parent
local Packages = Package.Parent

-- Packages
local Maid = require(Packages:WaitForChild("Maid"))

-- Import types
local Types = require(Package:WaitForChild("Types"))
type State<T> = Types.State<T>
type ValueState<T> = Types.ValueState<T>
type CanBeState<T> = Types.CanBeState<T>
type Maid = Maid.Maid

-- Fusion references
local FusionFolder = Package:WaitForChild("Fusion")

-- Fusion states
local FusionStateFolder = FusionFolder.State
local FusionValue = require(FusionStateFolder.Value) :: (...any) -> any
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
local FusionNew = require(FusionInstanceFolder.New)
local FusionHydrate = require(FusionInstanceFolder.Hydrate)
local makeUseCallback = require(FusionStateFolder:WaitForChild("makeUseCallback"))

-- Fusion Utils
local Fusion = require(FusionFolder)


-- Constants
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
			_FusionForKeys(input, function(use: () -> any, key: KI): (KO, Maid)
				local _maid = Maid.new()
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
			-- there seems to be an error in fusion for this specifically, 
			-- in the future once it's fixed you need to add use() as the first parameter
			_FusionForValues(input, function(val: VI): (VO, Maid)
				local _maid = Maid.new()
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
			_FusionForPairs(input, function(use: () -> any, key: KI, val: VI): (KO, VO, Maid)
				local _maid = Maid.new()
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

		local compState = _FusionComputed(function(use: (any) -> any)
			local vals = {}
			for i, paramState in ipairs(paramStates) do
				if paramState.Get then
					vals[i] = use(paramState)
				else
					vals[i] = nil
				end
			end
			local val = processor(table.unpack(vals, 1, #paramStates))
			return val
		end, if hasDestructor then possibleDestructor else function() end)
		
		for i, dependency in ipairs(paramStates) do
			dependency.dependentSet[compState] = true
		end
		
		return Interface._init(compState, _FusionComputed) :: any
	end

	function Interface.Value<T>(initalVal: T): ValueState<T>
		local valState = FusionValue(initalVal)

		return Interface._init(valState, FusionValue) :: any
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

	function Interface.Spring<T>(goal: State<T>, speed: CanBeState<number>?, dampingRatio: CanBeState<number>?): State<T>
		local springState = _FusionSpring(goal, speed, dampingRatio)
		return Interface._init(springState, _FusionSpring) :: any
	end

	local function getFusionTable<Out>(propertyTable: any): {[any]: any}
		local fusionTable = {
			[Fusion.Children] = propertyTable.Children or {},
		}

		for k, v in pairs(propertyTable) do
			if k ~= "Events" and k ~= "Attributes"and k ~= "Children" then
				fusionTable[k] = v
			end
		end

		if propertyTable.Events then
			for k, v in pairs(propertyTable.Events :: any) do
				fusionTable[Fusion.OnEvent(k)] = v
			end
		end

		if propertyTable.Attributes then
			for k, v in pairs(propertyTable.Attributes :: any) do
				fusionTable[Fusion.Attribute(k)] = v
			end
		end

		return fusionTable
	end

	function Interface.new<Out>(className: string): (propertyTable: any) -> Out
		local instConstructor = FusionNew(className)
		return function(propertyTable: any): Out
			local inst = instConstructor(getFusionTable(propertyTable))
			maid:GiveTask(inst)
			return inst
		end
	end

	function Interface.bind<Out>(inst: Out & Instance): (propertyTable: any) -> Out & Instance
		local instBinder = FusionHydrate(inst :: any)
		return function(propertyTable: any): Out & Instance
			local inst = instBinder(getFusionTable(propertyTable))
			return inst
		end
	end

	function Interface.clone<Out>(template: Out & Instance): (propertyTable: any) -> Out & Instance
		local inst = maid:GiveTask(template:Clone())
		return Interface.bind(inst)
	end

	function Interface._init<T>(state: State<T>, fusionConstructor: (...any) -> State<T>): State<T>
		return nil :: any
	end

	-- Interface.OUT = FusionOut :: any
	-- Interface.REF = FusionRef :: any
	-- Interface.CHILDREN = FusionChildren :: any
	-- Interface.ON_EVENT = FusionOnEvent :: any
	-- Interface.PROPERTY_CHANGED = FusionOnChange :: any

	return Interface
end
