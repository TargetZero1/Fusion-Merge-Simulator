--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--modules
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))

--types
type Maid = Maid.Maid

export type PetTag = "Pet"

export type PetClass = "Dog" | "Mouse" | "Cat"

export type PetStats = {
	Equipped: boolean,
	Energy: number,
	Speed: number,
	BreakTime: number,
}

export type PetData = {
	Name: string,
	UserId: string,
	Class: PetClass,
	Level: number,
	Equipped: boolean,
	PetId: string,
}

export type PetProperties = {
	__index: any,
	_Animation: AnimationTrack?,
	_isActive: boolean,
	Maid: Maid,
	Id: string,
	PetModel: Model,
	Parent: Model,
	Player: Player,
	Stats: PetStats,
	Level: number,
	Class: PetClass?,
	Rarity: RarityUtil.Rarity<RarityUtil.RarityName>,
}
export type AnimationActions = "Walk" | "WalkObject" | "Sit" | "Bored" | "Sleep"

export type PetFunctions<Self> = {
	new: (model: Model, player: Player, cframe: CFrame, parent: Model, level: number?, equipped: boolean?) -> Self,
	SetEquip: (Self, bool: boolean) -> nil,
	SetPetModel: (Self, class: PetClass, level: number) -> Model?,
	MoveTo: (Self, object: BasePart) -> nil,
	Stand: (Self) -> nil,
	Sleep: (Self) -> nil,
	Wake: (Self) -> nil,
	AttachTo: (Self, object: BasePart, modelToPivot: Model?) -> nil,
	Detach: (Self) -> nil,
	Upgrade: (Self) -> nil,
	Update: (Self) -> nil,
	SetAnimation: (Self, actionName: AnimationActions?) -> nil,
	Destroy: (Self) -> nil,
	GetMaxEnergy: (Self) -> number,
	GetMaxLevel: (Self) -> number,
	getMaxEquipped: (plr: Player) -> number,
	init: (maid: Maid) -> nil,
	merge: ({ PetData }) -> nil,
	get: (model: Model) -> Self?,
	getPets: (player: Player?, withEquipped: boolean?) -> { [number]: Self },
	getById: (id: string) -> Self?,

	clear: (player: Player?) -> nil,
	hatch: (petClass: PetClass, isPremium: boolean, isLucky: boolean, isSuperLucky: boolean) -> string,
}

export type EmptyPetModule<Self> = PetProperties & PetFunctions<Self>

export type Pet = EmptyPetModule<EmptyPetModule<any>>

--module
local PetsUtil = {}

--pet data
function PetsUtil.newPetData(
	class: PetClass,
	petModel: Model,
	userId: number,
	level: number?,
	equipped: boolean?,
	petId: string?
): PetData
	return {
		Name = petModel.Name,
		UserId = tostring(userId),
		Class = class,
		Level = level or 1,
		Equipped = if equipped ~= nil then equipped else false,
		PetId = petId or game:GetService("HttpService"):GenerateGUID(false),
	}
end

function PetsUtil.applyPetData(petModel: Model, petData: PetData)
	petModel:SetAttribute("UserId", petData.UserId)
	petModel:SetAttribute("Level", petData.Level)
	petModel:SetAttribute("PetId", petData.PetId)
	petModel:SetAttribute("Equipped", petData.Equipped)
	petModel:SetAttribute("Class", petData.Class)
	petModel.Name = petData.Name
	return nil
end

function PetsUtil.getPetData(petModel: Model): PetData
	return {
		UserId = petModel:GetAttribute("UserId"),
		Class = petModel:GetAttribute("Class"),
		Level = petModel:GetAttribute("Level"),
		Equipped = petModel:GetAttribute("Equipped"),
		PetId = petModel:GetAttribute("PetId"),
		Name = petModel.Name,
	}
end

function PetsUtil.getPetModelById(id: string): Model?
	for _, pet: Model in pairs(CollectionService:GetTagged("Pet" :: PetTag)) do
		local petData = PetsUtil.getPetData(pet)
		if petData.PetId == id then
			return pet
		end
	end
	return nil
end

function PetsUtil.getPets(player: Player?, isEquipped: boolean?): { [number]: PetData }
	local array = {}
	for _, pet: Model in pairs(CollectionService:GetTagged("Pet" :: PetTag)) do
		local petData = PetsUtil.getPetData(pet)
		if
			((player and (petData.UserId == tostring(player.UserId))) or not player)
			and ((isEquipped and (petData.Equipped == isEquipped)) or (isEquipped == nil))
		then
			table.insert(array, PetsUtil.getPetData(pet))
		end
	end
	return array
end

--pet collective data
function PetsUtil.count(player: Player?, equipCheck: boolean?)
	local count = 0
	for _, petModel: Model in pairs(CollectionService:GetTagged("Pet" :: PetTag)) do
		local petData = PetsUtil.getPetData(petModel)
		if (player and (petData.UserId == tostring(player.UserId))) or not player then --#1 condition for pets
			if (equipCheck ~= nil and petData.Equipped) or (equipCheck == nil) then --#2 condition for pets
				count += 1
			end
		end
	end
	return count
end

return PetsUtil
