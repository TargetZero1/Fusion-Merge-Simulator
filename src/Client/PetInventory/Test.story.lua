--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local Pet = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))
-- local MergeIndex = require(
-- 	game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("PetInventory"):WaitForChild("MergeIndex")
-- )

-- Types
type Maid = Maid.Maid
type PetData = Pet.PetData
-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()

	task.spawn(function()
		local PetInventory = require(script.Parent)

		local function randomPet(): PetData
			local petModels = game.ReplicatedStorage.Assets.PetModels:GetChildren()

			local petModel = petModels[math.random(#petModels)]

			return {
				Equipped = math.random() < 0.05,
				Level = math.random(1, 4),
				Name = petModel.Name,
				Class = petModel.Name:gsub("%d+", ""),
				PetId = "",
				UserId = "",
			}
		end

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

		local OnBack = maid:GiveTask(Signal.new())
		local OnEquip = maid:GiveTask(Signal.new())
		local OnDelete = maid:GiveTask(Signal.new())
		local OnMerge = maid:GiveTask(Signal.new())

		-- local IsVisible = _Value(true)
		local IndexSelection = _Value(nil) :: any
		local Selection = _Value(nil) :: any
		local Pets = _Value({
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
			randomPet(),
		})

		maid:GiveTask(OnBack:Connect(function()
			print("Back")
		end))
		maid:GiveTask(OnEquip:Connect(function()
			print("Equip")
		end))
		maid:GiveTask(OnDelete:Connect(function()
			print("OnDelete")
		end))

		local inventory = maid:GiveTask(
			PetInventory(maid, Selection, Pets, _Value(2), IndexSelection, OnBack, OnEquip, OnDelete, OnMerge, coreGui)
		)

		maid:GiveTask(OnMerge:Connect(function(petDatas: { PetData })
			print(petDatas)
		end))
		IndexSelection:Set(inventory)
	end)

	return function()
		maid:Destroy()
	end
end
