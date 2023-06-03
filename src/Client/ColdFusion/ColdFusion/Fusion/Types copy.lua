--!strict
local _Package = script.Parent
local _Packages = _Package.Parent

-- Packages
local _Maid = require(_Packages.Maid)
local _NetworkUtil = require(_Packages.NetworkUtil)

local FusionFolder = _Package.Fusion
local FusionPubTypes = require(FusionFolder.PubTypes)
-- local FusionTypes = require(FusionFolder.Types)

-- Types
type Maid = _Maid.Maid
export type BaseState<T> = {
	Get: (any) -> T,
}
export type CanBeState<T> = (BaseState<T> | T)

--- @type CanBeState<T> (State | T)
--- @within ColdFusion

export type State<T> = BaseState<T> & {
	Tween: (
		self: BaseState<T>,
		duration: CanBeState<number>?,
		easingStyle: CanBeState<Enum.EasingStyle>?,
		easingDirection: CanBeState<Enum.EasingDirection>?,
		repetitions: CanBeState<number>?,
		reverses: CanBeState<boolean>?,
		delayTime: CanBeState<number>?
	) -> State<T>,
	Spring: (self: BaseState<T>, speed: number?, dampingRatio: number?) -> State<T>,
	ForKeys: <KI, KO>(self: BaseState<T>, processor: (key: KI, maid: Maid) -> KO) -> BaseState<{ [KO]: any }>
		& State<T>,
	ForValues: <VI, VO>(
		self: BaseState<T>,
		processor: (val: VI, maid: Maid) -> VO
	) -> BaseState<{ [any]: VO }> & State<T>,
	ForPairs: <KI, VI, KO, VO>(
		self: BaseState<T>,
		processor: (key: KI, val: VI, maid: Maid) -> VO
	) -> BaseState<{ [KO]: VO }> & State<T>,
	Else: (self: BaseState<T?>, alt: CanBeState<T>) -> State<T>,
	Transmit: (
		self: any,
		remoteName: string,
		id: string?,
		rate: number?,
		player: Player?
	) -> State<T>,
	Receive: (self: any, remoteName: string, id: string?, player: Player?) -> State<T>,
	CleanUp: (self: BaseState<T>) -> State<T>,
	Delay: (self: BaseState<T>, val: CanBeState<number>) -> State<T>,
	Connect: (self: BaseState<T>, func: (cur: T, prev: T?) -> nil) -> nil,
	Destroy: (self: BaseState<T>) -> nil,
	Index: <K>(self: BaseState<T>, key: CanBeState<any>) -> State<T> & BaseState<K>,
	Add: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Subract: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Multiply: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Divide: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Modulus: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Power: (self: BaseState<T>, other: CanBeState<T>) -> State<T>,
	Equal: (self: BaseState<T>, other: CanBeState<T>) -> BaseState<boolean> & State<T>,
	LessThan: (self: BaseState<T>, other: CanBeState<T>) -> BaseState<boolean> & State<T>,
	LessThanEqualTo: (self: BaseState<T>, other: CanBeState<T>) -> BaseState<boolean> & State<T>,
	Length: (self: BaseState<T>, other: CanBeState<T>) -> BaseState<number> & State<T>,
	Concatenate: (self: BaseState<T>, other: CanBeState<T>) -> BaseState<string> & State<T>,
}

export type ValueState<T> = State<T> & {
	Set: (any, T) -> nil,
}

export type FusionSpecialKey = FusionPubTypes.SpecialKey
export type FusionPropertyTable = FusionPubTypes.PropertyTable
export type FusionKey = string | FusionSpecialKey

return {}
