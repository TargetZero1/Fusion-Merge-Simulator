--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--modules
local PetsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetsUtil"))
local BarFrame =
	require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("MainSysClient"):WaitForChild("BarFrame"))

--types
type Maid = Maid.Maid

--constants

--variables

--references

--local functions

local function onPetAdded(maid: Maid, petModel: Model)
	assert(petModel:IsA("Model"), "Pet model is not a model")

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _import = _fuse.import
	local _mount = _fuse.mount

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local self = setmetatable({}, BarFrame) :: any
	self._Maid = maid
	self._Fuse = _fuse

	local ratioValue: ColdFusion.ValueState<number> =
		_Value((petModel:GetAttribute("Energy") or 0) / (petModel:GetAttribute("MaxEnergy") or 100))

	local billboardGui = _new("BillboardGui")({
		Parent = petModel,
		MaxDistance = 35,
		Size = UDim2.fromScale(15, 15),
		Name = "Stats",
	})

	local energyBar = BarFrame.new(
		ratioValue,
		"⚡",
		nil,
		_Computed(function(ratioValueVal: number)
			return tostring(petModel:GetAttribute("Energy") or 0)
				.. "/"
				.. tostring(petModel:GetAttribute("MaxEnergy") or 100)
		end, ratioValue)
	)

	energyBar.Instance.Parent = billboardGui

	petModel:GetAttributeChangedSignal("Energy"):Connect(function()
		ratioValue:Set((petModel:GetAttribute("Energy") or 0) / (petModel:GetAttribute("MaxEnergy") or 100))
	end)
end

--module
local Pet = {}

function Pet.init(maid: Maid)
	for _, petModel in pairs(CollectionService:GetTagged("Pet" :: PetsUtil.PetTag)) do
		onPetAdded(maid, petModel)
	end
	maid:GiveTask(CollectionService:GetInstanceAddedSignal("Pet" :: PetsUtil.PetTag):Connect(function(petModel: Model)
		onPetAdded(maid, petModel)
	end))
end
return Pet
