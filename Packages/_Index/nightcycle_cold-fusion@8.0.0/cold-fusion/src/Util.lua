--!strict
local _Package = script.Parent
local _Packages = _Package.Parent

-- Packages
-- local TableUtil = require(_Packages:WaitForChild("TableUtil"))

-- Fusion references
local FusionFolder = _Package.Fusion

-- Fusion states
local FusionStateFolder = FusionFolder.State
local _FusionValue = require(FusionStateFolder.Value) :: (...any) -> any
local _FusionComputed = require(FusionStateFolder.Computed) :: (...any) -> any
-- local _FusionForKeys = require(FusionStateFolder.ForKeys) :: (...any) -> any
-- local _FusionForPairs = require(FusionStateFolder.ForPairs) :: (...any) -> any
-- local _FusionForValues = require(FusionStateFolder.ForValues) :: (...any) -> any
local _FusionObserver = require(FusionStateFolder.Observer) :: (...any) -> any

-- Fusion animations
local FusionAnimationFolder = FusionFolder.Animation
local _FusionSpringScheduler = require(FusionAnimationFolder.SpringScheduler)
local _FusionTweenScheduler = require(FusionAnimationFolder.TweenScheduler)
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

-- Fusion types

-- Packages
local Maid = require(_Packages.Maid)

-- Import types
type PrivateState = any
type Maid = Maid.Maid

-- type StateUtil<Self> = {
-- 	__index: StateUtil<Self>,
-- 	Destroy: (Self) -> nil,
-- 	Connect:<any>(Self, func: (cur: any, prev: any?) -> nil) -> (() -> nil),
-- 	Get: <any>(Self) -> any,
-- 	Tween: (Self, ...any) -> PrivateState,
-- 	Spring: (Self, ...any) -> PrivateState,
-- 	Else: (Self, ...any) -> PrivateState,
-- 	ForPairs: (Self, ...any) -> nil,
-- 	ForKeys: (Self, ...any) -> nil,
-- 	ForValues: (Self) -> nil,
-- 	Subtract: (Self, other: any) -> PrivateState,
-- 	Add: (Self, other: any) -> PrivateState,
-- 	Multiply: (Self, other: any) -> PrivateState,
-- 	Divide: (Self, other: any) -> PrivateState,
-- 	Modulus: (Self, other: any) -> PrivateState,
-- 	Power: (Self, other: any) -> PrivateState,
-- 	Equal: (Self, other: any) -> PrivateState,
-- 	Length: (Self) -> PrivateState,
-- 	LessThan: (Self, other: any) -> PrivateState,
-- 	LessThanEqualTo: (Self, other: any) -> PrivateState,
-- 	Concat: (Self, other: any) -> PrivateState,
-- 	Index: (Self, key: any) -> PrivateState,
-- }


-- interface constructor
return function(interface: any)
	local Util = {} :: any
	Util.__index = Util

	-- private functions
	local function singleParamProcess(processor: (a: any, b: any) -> any, self: any, other: any)
		if interface._getIfState(other) then
			return interface.Computed(processor, self, other)
		else
			return interface.Computed(function(a: any): any
				return processor(a, other)
			end, self)
		end
	end
	
	local function noParamProcess(processor: (a: any) -> any, self: any)
		return interface.Computed(processor, self)
	end

	-- local function doubleParamProcess(processor: (a: any, b: any, c: any) -> any, self: any, b: any, c: any)
		
	-- 	if interface._getIfState(b) and interface._getIfState(c) then
	-- 		return interface.Computed(processor, self, b, c)
	-- 	elseif interface._getIfState(b) and not interface._getIfState(c) then
	-- 		return interface.Computed(function(a: any, bVal: any): any
	-- 			return processor(a, bVal, c)
	-- 		end, self, b)	
	-- 	elseif not interface._getIfState(b) and interface._getIfState(c) then
	-- 		return interface.Computed(function(a: any, cVal: any): any
	-- 			return processor(a, b, cVal)
	-- 		end, self, b)	
	-- 	else
	-- 		return interface.Computed(function(a: any): any
	-- 			return processor(a, b, c)
	-- 		end, self)
	-- 	end
	-- end

	function Util:Destroy()
		if self["kind"] == "Spring" then
			_FusionSpringScheduler.remove(self :: any)
		end
		if self["kind"] == "Tween" then
			_FusionTweenScheduler.remove(self :: any)
		end

		-- remove dependency references
		if self.dependentSet then
			for state: any in pairs(self.dependentSet) do
				state.dependencySet[self] = nil
			end
		end
		for k, v in pairs(self) do
			self[k] = nil
		end
		setmetatable(self, nil)
		return nil
	end

	-- function Util:Set<any>(initial: any): nil
	-- 	return self:set(initial)
	-- end

	function Util:Get<any>(): any --so that inherited states can still access this functionality
		return self:_peek()
	end


	function Util:Tween(...)
		return interface.Tween(self, ...) :: any
	end

	function Util:Spring(...)
		return interface.Spring(self, ...)
	end


	function Util:ForPairs(...)
		return interface.ForPairs(self, ...)
	end

	function Util:ForKeys(...)
		return interface.ForKeys(self, ...)
	end

	function Util:ForValues(...)
		return interface.ForValues(self, ...)
	end

	function Util:Subtract(other: any): any
		return singleParamProcess(function(a: any, b: any)
			return a - b
		end, self, other)
	end

	function Util:Add(other: any): any
		return singleParamProcess(function(a: any, b: any)
			return a + b
		end, self, other)
	end

	function Util:Multiply(other: any): any
		return singleParamProcess(function(a: any, b: any)
			return a * b
		end, self, other)
	end

	function Util:Divide(other: any): any
		return singleParamProcess(function(a: any, b: any)
			return a / b
		end, self, other)
	end

	-- function Util:Modulus(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a % b
	-- 	end, self, other)
	-- end

	-- function Util:Power(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a ^ b
	-- 	end, self, other)
	-- end

	-- function Util:Sign(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return math.sign(a)
	-- 	end, self)
	-- end

	-- function Util:Clamp(min: number, max: number): any
	-- 	return doubleParamProcess(function(a: any, b: any, c: any)
	-- 		return math.clamp(a, b, c)
	-- 	end, self, min, max)
	-- end

	-- function Util:Min(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return math.min(a,b)
	-- 	end, self, other)
	-- end

	-- function Util:Max(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return math.max(a,b)
	-- 	end, self, other)
	-- end

	-- function Util:Degree(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return math.deg(a)
	-- 	end, self)
	-- end

	-- function Util:Radian(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return math.rad(a)
	-- 	end, self)
	-- end
	
	function Util:Round(): any
		return noParamProcess(function(a: any)
			return math.round(a)
		end, self)
	end

	-- function Util:Ceil(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return math.ceil(a)
	-- 	end, self)
	-- end

	-- function Util:Log(base: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return math.log(a,b)
	-- 	end, self, base)
	-- end

	-- function Util:Log10(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return math.log10(a)
	-- 	end, self)
	-- end

	-- function Util:IfNaN(other: any, alt: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return if a == a then a else b
	-- 	end, self, alt)
	-- end

	-- function Util:Equal(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a == b
	-- 	end, self, other)
	-- end

	-- function Util:Not(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return not a
	-- 	end, self)
	-- end

	-- function Util:And(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a and b
	-- 	end, self, other)
	-- end

	-- function Util:Or(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a or b
	-- 	end, self, other)
	-- end


	-- function Util:XOr(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return not (a == b)
	-- 	end, self, other)
	-- end

	-- function Util:LessThan(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a < b
	-- 	end, self, other)
	-- end

	-- function Util:LessThanEqualTo(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a <= b
	-- 	end, self, other)
	-- end

	-- function Util:GreaterThan(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a > b
	-- 	end, self, other)
	-- end

	-- function Util:GreaterThanEqualTo(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a >= b
	-- 	end, self, other)
	-- end

	-- function Util:Then(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return if a then b else nil
	-- 	end, self, other)
	-- end

	-- function Util:Else(other: any)
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		if a then
	-- 			return a
	-- 		else
	-- 			return b
	-- 		end
	-- 	end, self, other)
	-- end

	-- function Util:Len(): any
	-- 	return noParamProcess(function(a: any)
	-- 		if type(a) == "table" then
	-- 			return #a
	-- 		else
	-- 			return string.len(a)
	-- 		end
	-- 	end, self)
	-- end

	-- function Util:Keys(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return TableUtil.keys(a)
	-- 	end, self)
	-- end

	-- function Util:Values(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return TableUtil.values(a)
	-- 	end, self)
	-- end


	-- function Util:Sort(processor: (a: any, b: any) -> boolean): any
	-- 	return noParamProcess(function(a: any)
	-- 		local out = table.clone(a)
	-- 		table.sort(out, processor)
	-- 		return out
	-- 	end, self)
	-- end

	-- function Util:Randomize(seed: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return TableUtil.randomize(a, b)
	-- 	end, self, seed)
	-- end

	-- function Util:Concat(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return a .. b
	-- 	end, self, other)
	-- end

	function Util:ToString(): any
		return noParamProcess(function(a: any)
			return tostring(a)
		end, self)
	end

	function Util:Upper(): any
		return noParamProcess(function(a: any)
			return string.upper(a)
		end, self)
	end

	-- function Util:Lower(): any
	-- 	return noParamProcess(function(a: any)
	-- 		return string.lower(a)
	-- 	end, self)
	-- end

	-- function Util:Split(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return string.split(a, b)
	-- 	end, self, other)
	-- end

	-- function Util:Sub(start: any, finish: any): any
	-- 	return doubleParamProcess(function(a: any, b: any, c: any)
	-- 		return string.sub(a, b, c)
	-- 	end, self, start, finish)
	-- end

	-- function Util:GSub(pattern: any, rep: any): any
	-- 	return doubleParamProcess(function(a: any, b: any, c: any)
	-- 		return string.gsub(a, b, c)
	-- 	end, self, pattern, rep)
	-- end

	-- function Util:Rep(other: any): any
	-- 	return singleParamProcess(function(a: any, b: any)
	-- 		return string.rep(a, b)
	-- 	end, self, other)
	-- end

	-- function Util:Reverse(): any
	-- 	return noParamProcess(function(a: any)
	-- 		if type(a) == "table" then
	-- 			return TableUtil.reverse(a)
	-- 		else
	-- 			return string.reverse(a)
	-- 		end
	-- 	end, self)
	-- end

	function Util:Read(key: any): any
		if interface._getIfState(key) then
			return interface.Computed(function(a: any, b: any): string
				return a[b]
			end, self, key)
		else
			return interface.Computed(function(a: any): string
				return a[key]
			end, self)
		end
	end

	function Util:Connect<any>(processor: (cur: any, prev: any?) -> nil): (() -> nil)
		-- local observer = _FusionObserver(self)
		local prev: any?
		local isFirstRun = true
		local compState = interface.Computed(function(cur: any): nil
			if isFirstRun then
				isFirstRun = false
			else
				processor(cur, prev)			
			end
			prev = cur
			return nil
		end, self)

		-- local connection = observer:onChange(function(out)
		-- 	print("out", out)
		-- 	local cur = self:Get()
		-- 	func(cur, prev)
		-- 	prev = cur
		-- end)
		-- observer:update()
		-- print("OB", observer, "vs", ({[self] = true}))

		local isDead = false
		local cleanUp = function()
			if isDead then return end
			isDead = true
			compState:Destroy()
		end

		if interface.Maid then
			interface.Maid:GiveTask(cleanUp)
		end

		return cleanUp
	end

	return Util
end
