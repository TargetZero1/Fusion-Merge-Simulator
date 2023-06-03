local REQUIRED_MODULE = require(script:WaitForChild("ColdFusion"))
export type State<T> = REQUIRED_MODULE.State<T>
export type ValueState<T> = REQUIRED_MODULE.ValueState<T>
export type CanBeState<T> = REQUIRED_MODULE.CanBeState<T>
export type Fuse = REQUIRED_MODULE.Fuse 
return REQUIRED_MODULE
