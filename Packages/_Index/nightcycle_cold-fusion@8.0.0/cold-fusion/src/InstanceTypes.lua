--!strict
type State<T> = {
	_Value: T,
	Get: (self: any) -> T,
}
type CanBeState<T> = State<T> | T

export type InstanceConstructor = (
((className: string) -> (properties: {
	[string]: CanBeState<any>,
	Children: {[number]: any}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
}) -> Instance)
)

export type InstanceMounter = (
((inst: Instance) -> (properties: {
	Children: {[number]: CanBeState<Instance?>}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
	[string]: CanBeState<any>,
}) -> Instance)
)
return {}
