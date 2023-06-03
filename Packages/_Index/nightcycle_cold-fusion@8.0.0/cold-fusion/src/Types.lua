--!strict
local Package = script.Parent
local Packages = Package.Parent

-- Packages
local Maid = require(Packages:WaitForChild("Maid"))
local TableUtil = require(Packages:WaitForChild("TableUtil"))

-- Types
type Maid = Maid.Maid
type List<V> = TableUtil.List<V>
type Dict<K, V> = TableUtil.Dict<K, V>

export type BaseState<T> = {
	Get: (any) -> T,
}
export type CanBeState<T> = (BaseState<T> | T)

--- @type CanBeState<T> (State | T)
--- @within ColdFusion

export type State<T> = BaseState<T> & {
	-- Animation
	Tween: (
		self: any,
		duration: CanBeState<number>?,
		easingStyle: CanBeState<Enum.EasingStyle>?,
		easingDirection: CanBeState<Enum.EasingDirection>?,
		repetitions: CanBeState<number>?,
		reverses: CanBeState<boolean>?,
		delayTime: CanBeState<number>?
	) -> State<T>,
	Spring: (self: any, speed: CanBeState<number>?, dampingRatio: CanBeState<number>?) -> State<T>,
	
	-- Tables
	ForKeys: <KI, KO>(self: any, processor: (key: KI, maid: Maid) -> KO) -> BaseState<{ [KO]: any }>
		& State<T>,
	ForValues: <VI, VO>(
		self: any,
		processor: (val: VI, maid: Maid) -> VO
	) -> BaseState<{ [any]: VO }> & State<T>,
	ForPairs: <KI, VI, KO, VO>(
		self: any,
		processor: (key: KI, val: VI, maid: Maid) -> VO
	) -> BaseState<{ [KO]: VO }> & State<T>,

	Connect: (self: any, func: (cur: T, prev: T?) -> nil) -> () -> nil,
	Destroy: (self: any) -> nil,
	Read: <K>(self: any, key: CanBeState<any>) -> State<T> & BaseState<K>,

	-- Math
	Add: (self: any, other: CanBeState<T>) -> State<T>,
	Subract: (self: any, other: CanBeState<T>) -> State<T>,
	Multiply: (self: any, other: CanBeState<T>) -> State<T>,
	Divide: (self: any, other: CanBeState<T>) -> State<T>,
	-- Modulus: (self: any, other: CanBeState<T>) -> State<T>,
	-- Power: (self: any, other: CanBeState<T>) -> State<T>,
	-- Sign: (self: any) -> BaseState<number> & State<T>,
	-- Clamp: (
	-- 	self: any,
	-- 	min: CanBeState<number>, 
	-- 	max: CanBeState<number>
	-- ) -> BaseState<number> & State<T>,
	-- Min: (
	-- 	self: any,
	-- 	other: CanBeState<number>
	-- ) -> BaseState<number> & State<T>,
	-- Max: (
	-- 	self: any,
	-- 	other: CanBeState<number>
	-- ) -> BaseState<number> & State<T>,
	-- Degree: (
	-- 	self: any
	-- ) -> BaseState<number> & State<T>,
	-- Radian: (
	-- 	self: any
	-- ) -> BaseState<number> & State<T>,
	Round: (
		self: any
	) -> BaseState<number> & State<T>,	
	-- Floor: (
	-- 	self: any
	-- ) -> BaseState<number> & State<T>,	
	-- Ceil: (
	-- 	self: any
	-- ) -> BaseState<number> & State<T>,	
	-- Log: (
	-- 	self: any, 
	-- 	base: CanBeState<T>
	-- ) -> BaseState<number> & State<T>,	
	-- Log10: (
	-- 	self: any
	-- ) -> BaseState<number> & State<T>,	
	-- IfNaN: (self: BaseState<any>, alt: CanBeState<T>) -> BaseState<boolean> & State<T>,

	-- Boolean
	-- Equal: (self: any, other: CanBeState<T>) -> BaseState<boolean> & State<T>,
	-- Not: (self: any) -> BaseState<boolean> & State<T>,
	-- And: (self: any, other: CanBeState<boolean>) -> BaseState<boolean> & State<T>,
	-- Or: (self: any, other: CanBeState<boolean>) -> BaseState<boolean> & State<T>,
	-- XOr: (self: any, other: CanBeState<boolean>) -> BaseState<boolean> & State<T>,
	
	-- LessThan: (self: any, other: CanBeState<number>) -> BaseState<boolean> & State<T>,
	-- LessThanEqualTo: (self: any, other: CanBeState<number>) -> BaseState<boolean> & State<T>,
	-- GreaterThan: (self: any, other: CanBeState<number>) -> BaseState<boolean> & State<T>,
	-- GreaterThanEqualTo: (self: any, other: CanBeState<number>) -> BaseState<boolean> & State<T>,
	
	-- Logic
	-- Else: (self: any, alt: CanBeState<T>) -> State<T>,
	-- Then: (self: any, value: CanBeState<T>) -> BaseState<T?> & State<T>,

	-- Table
	-- Len: (self: any) -> BaseState<number> & State<T>,
	-- Keys: <K>(self: any) -> BaseState<{[number]: K}> & State<T>,
	-- Values: <V>(self: any) -> BaseState<{[number]: V}> & State<T>,
	-- Sort: <V>(self: any, filter: (a: V, b: V) -> boolean) -> BaseState<{[number]: V}> & State<T>,
	-- Randomize: <V>(self: any) -> BaseState<{[number]: V}> & State<T>,

	-- String
	-- Concat: (self: any, other: CanBeState<string>) -> BaseState<string> & State<T>,
	ToString: (self: any) -> BaseState<string> & State<T>,
	Upper: (self: any) -> BaseState<string> & State<T>,
	-- Split: (self: any, separator: CanBeState<string>) -> BaseState<{[number]: string}> & State<T>,
	-- Sub: (self: any, start: CanBeState<number>, finish: CanBeState<number>?) -> BaseState<string> & State<T>,
	-- GSub: (self: any, pattern: CanBeState<string>, replacement: CanBeState<string>) -> BaseState<string> & State<T>,
	-- Rep: (self: any, count: CanBeState<number>) -> BaseState<string> & State<T>,
	-- Reverse: <V>(self: any) -> BaseState<any> & State<T>,

}

export type ValueState<T> = State<T> & {
	Set: (any, T) -> nil,
}


return {}
