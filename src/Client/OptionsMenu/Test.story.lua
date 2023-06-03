--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))

--modules
local OptionsMenu = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("OptionsMenu"))

return function(target)
	local _maid = Maid.new()

	local _fuse = ColdFusion.fuse(_maid)
	local _new = _fuse.new

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local musicState = _Value(true)
	local soundFXState = _Value(true)
	local plotPublicState = _Value(true)

	local musicSignal = _maid:GiveTask(Signal.new())
	local soundFXSignal = _maid:GiveTask(Signal.new())
	local plotPublicSignal = _maid:GiveTask(Signal.new())
	local OnBack = _maid:GiveTask(Signal.new())

	local optionsMenu = OptionsMenu(
		_maid,
		musicState,
		soundFXState,
		plotPublicState,
		musicSignal,
		soundFXSignal,
		plotPublicSignal,
		OnBack
	)
	optionsMenu.Parent = target

	musicSignal:Connect(function()
		musicState:Set(not musicState:Get())
	end)

	soundFXSignal:Connect(function()
		soundFXState:Set(not soundFXState:Get())
	end)

	plotPublicSignal:Connect(function()
		plotPublicState:Set(not plotPublicState:Get())
	end)

	return function()
		_maid:Destroy()
	end
end
