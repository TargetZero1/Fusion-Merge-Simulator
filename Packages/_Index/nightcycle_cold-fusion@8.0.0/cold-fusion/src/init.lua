--!strict
local Package = script
local Packages = Package.Parent

local Maid = require(Packages:WaitForChild("Maid"))
local TableUtil = require(Packages:WaitForChild("TableUtil"))

-- Import types
local Types = require(Package:WaitForChild("Types"))
local InstanceTypes = require(Package:WaitForChild("InstanceTypes"))
export type State<T> = Types.State<T>
export type ValueState<T> = Types.ValueState<T>
export type CanBeState<T> = Types.CanBeState<T>
-- export type TableState<KI, VI, KO, VO> = Types.TableState<KI, VI, KO, VO>
-- export type TableValueState<KI, VI, KO, VO> = Types.TableValueState<KI, VI, KO, VO>
-- export type CanBeTableState<KI, VI, KO, VO> = Types.CanBeTableState<KI, VI, KO, VO>

type Maid = Maid.Maid
type Dict<K, V> = TableUtil.Dict<K, V>

-- Fusion references
local FusionFolder = Package:WaitForChild("Fusion")

-- Fusion states
local FusionStateFolder = FusionFolder.State
local FusionValue = require(FusionStateFolder.Value) :: (...any) -> any
local FusionComputed = require(FusionStateFolder.Computed) :: (...any) -> any
local FusionForKeys = require(FusionStateFolder.ForKeys) :: (...any) -> any
local FusionForPairs = require(FusionStateFolder.ForPairs) :: (...any) -> any
local FusionForValues = require(FusionStateFolder.ForValues) :: (...any) -> any
-- local _FusionObserver = require(FusionStateFolder.Observer) :: (...any) -> any

-- Fusion animations
local FusionAnimationFolder = FusionFolder.Animation
local FusionSpring = require(FusionAnimationFolder.Spring) :: (...any) -> any
local FusionTween = require(FusionAnimationFolder.Tween) :: (...any) -> any

-- Modules
local Interface = require(Package:WaitForChild("Interface"))
local Util = require(Package:WaitForChild("Util"))

export type Fuse = {
	-- Instance related
	new: InstanceTypes.InstanceConstructor,
	bind: InstanceTypes.InstanceMounter,
	clone: InstanceTypes.InstanceMounter,
	import: <T>(maybeState: CanBeState<T>?, CanBeState<T>) -> State<T>,
	fuse: (Maid?) -> Fuse,

	-- States
	Value: <T>(initialValue: T) -> ValueState<T>,
	Computed: (<T, A, B, C, D, E, F, G, H, I, J, K, L>(
		(A, B, C, D, E, F, G, H, I, J, K, L, ...any) -> T,
		(State<A>)?,
		(State<B>)?,
		(State<C>)?,
		(State<D>)?,
		(State<E>)?,
		(State<F>)?,
		(State<G>)?,
		(State<H>)?,
		(State<I>)?,
		(State<J>)?,
		(State<K>)?,
		(State<L>)?,
		...(State<any>)
	) -> State<T>) & (<T, A, B, C, D, E, F, G, H, I, J, K, L>(
		(A, B, C, D, E, F, G, H, I, J, K, L, ...any) -> T,
		(T) -> nil,
		(State<A>)?,
		(State<B>)?,
		(State<C>)?,
		(State<D>)?,
		(State<E>)?,
		(State<F>)?,
		(State<G>)?,
		(State<H>)?,
		(State<I>)?,
		(State<J>)?,
		(State<K>)?,
		(State<L>)?,
		...(State<any>)
	) -> State<T>),
}

-- References

-- Constants
local WEAK_KEYS_METATABLE = { __mode = "k" }

local Fuse = {}
Fuse.__index = Fuse

function Fuse:Destroy()
	if not self._IsAlive then
		return
	end
	self._IsAlive = false
	for k, state: any in pairs(self._States) do
		self._States[k] = nil
		state:Destroy()
		-- setmetatable(state, nil)
		-- for k, v in pairs(state) do
		-- 	state[k] = nil
		-- end
	end
	setmetatable(self._States, nil)
	for k, v in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
end

function Fuse.fuse(maid: Maid?): Fuse
	maid = maid or Maid.new()
	assert(maid ~= nil)

	local states = {} :: any
	setmetatable(states, WEAK_KEYS_METATABLE)

	local _interface = Interface(maid)

	local _FusionMetatables: { [any]: any } = {}

	_interface._init = function<T>(state: State<T>, fusionConstructor: (...any) -> State<T>): State<T>
		table.insert(states, state)
		setmetatable(state, _FusionMetatables[fusionConstructor])
		return state
	end

	_FusionMetatables[FusionValue] = setmetatable(Util(_interface), getmetatable(FusionValue(0)))
	_FusionMetatables[FusionComputed] = setmetatable(
		Util(_interface),
		getmetatable(FusionComputed(function()
			return nil
		end))
	)
	_FusionMetatables[FusionTween] = setmetatable(Util(_interface), getmetatable(FusionTween(FusionValue(0))))
	_FusionMetatables[FusionSpring] = setmetatable(Util(_interface), getmetatable(FusionSpring(FusionValue(0))))
	_FusionMetatables[FusionForKeys] =
		setmetatable(Util(_interface), getmetatable(FusionForKeys(FusionValue({}), function() end)))
	_FusionMetatables[FusionForPairs] =
		setmetatable(Util(_interface), getmetatable(FusionForPairs(FusionValue({}), function() end)))
	_FusionMetatables[FusionForValues] =
		setmetatable(Util(_interface), getmetatable(FusionForValues(FusionValue({}), function() end)))

	local self = {
		_IsAlive = true,
		_States = states :: { [number]: any },
		Interface = _interface,
	}
	setmetatable(self, Fuse)

	self.Computed = function(...)
		return _interface.Computed(...)
	end

	self.Value = function(...)
		local val = _interface.Value(...)
		val.Set = function(s: any, v: any)
			s:set(v)
		end
		return val
	end

	self.new = function<Out>(className: string): Out
		return _interface.new(className) :: any
	end

	self.bind = function<Out>(inst: Out & Instance): Out & Instance
		return _interface.bind(inst :: any) :: any
	end

	self.clone = function<Out>(inst: Out & Instance): Out & Instance
		return _interface.clone(inst :: any) :: any
	end

	self.import = function<T>(...)
		return _interface.import(...)
	end

	return self :: any
end

return Fuse.fuse()
