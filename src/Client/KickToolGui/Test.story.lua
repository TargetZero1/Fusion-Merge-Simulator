--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local ToolGui = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("KickToolGui"))
--types
type Maid = Maid.Maid
type Signal = Signal.Signal
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

--frame
return function(target)
	local maid = Maid.new()
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	--states
	local kickMode: ValueState<MainSysUtil.KickMode> = _Value("Kick" :: any)

	local toolSignal = maid:GiveTask(Signal.new())

	local toolGui = maid:GiveTask(ToolGui(maid, kickMode, toolSignal))
	toolGui.Parent = target

	toolSignal:Connect(function(kickModeVal: MainSysUtil.KickMode)
		print(kickModeVal)
	end)
	--[[kickSignal:Connect(function()
        print("Kick")
    end)
    puntSignal:Connect(function()
        print("Punt")
    end)
    tapSignal:Connect(function()
        print("Tap")
    end)]]

	return function()
		maid:Destroy()
	end
end
