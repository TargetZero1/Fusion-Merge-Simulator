--this module contains info about the pets

--!strict
--Dependancies

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PetModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PetModels")
local RarityUtil = require(script.Parent:WaitForChild("RarityUtil"))
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))

--References
local Assets = ReplicatedStorage:WaitForChild("Assets")

--Types
export type LevelStats = {
	MaximumEnergy: number,
	Speed: number,
	RetargetTime: number,
	Skin: Model,
	Animation: {
		Walk: number?,
		WalkObject: number?,
		Sit: number?,
		Bored: number?,
		Sleep: number?,
	},
}

export type PetKindData<RarityName> = {
	Class: PetsUtil.PetClass,
	PetModel: Model,
	SleepTimeLength: number,
	Rarity: RarityUtil.Rarity<RarityName>,
	LevelsStats: {
		[number]: LevelStats,
	},
}

local petsData = {} :: { [string]: PetKindData<any> }

petsData.Mouse = {
	Class = "Mouse",
	PetModel = PetModels.Mouse, --the pet model
	SleepTimeLength = 50, -- sleeping time length of a pet (in seconds)
	Rarity = RarityUtil.Common, -- 5% = extremely rare, 20% = rare, 50% is common
	LevelsStats = {
		[1] = {
			MaximumEnergy = 60,
			Speed = 5,
			RetargetTime = 4,
			Skin = Assets.PetModels.Mouse,
			Animation = {
				Walk = 12316954325,
				WalkObject = 12318817353,
				Sit = 12328934033,
				Bored = 12422987693,
				Sleep = 12346668533,
			},
		},
		[2] = {
			MaximumEnergy = 80,
			Speed = 6,
			RetargetTime = 3.8,
			Skin = Assets.PetModels.Mouse2,
			Animation = {
				Walk = 12316954325,
				WalkObject = 12318817353,
				Sit = 12455015618,
				Bored = 12444647263,
				Sleep = 12444663627,
			},
		},
		[3] = {
			MaximumEnergy = 100,
			Speed = 7,
			RetargetTime = 3.6,
			Skin = Assets.PetModels.Mouse3,
			Animation = {
				Walk = 12316954325,
				WalkObject = 12318817353,
				Sit = 12328934033,
				Bored = 12422987693,
				Sleep = 12346668533,
			},
		},
		[4] = {
			MaximumEnergy = 120,
			Speed = 9,
			RetargetTime = 3.4,
			Skin = Assets.PetModels.Mouse4,
			Animation = {
				Walk = 12316954325,
				WalkObject = 12318817353,
				Sit = 12704652912,
				Bored = 12704672466,
				Sleep = 12704684232,
			},
		},
		[5] = {
			MaximumEnergy = 140,
			Speed = 11,
			RetargetTime = 3.2,
			Skin = Assets.PetModels.Mouse5,
			Animation = {
				Walk = 12704723974,
				WalkObject = 12704785111,
				Sit = 12704801456,
				Bored = 12704825725,
				Sleep = 12704831430,
			},
		},
		[6] = {
			MaximumEnergy = 160,
			Speed = 12,
			RetargetTime = 3.0,
			Skin = Assets.PetModels.Mouse6,
			Animation = {
				Walk = 12704723974,
				WalkObject = 12704785111,
				Sit = 12704801456,
				Bored = 12704825725,
				Sleep = 12704831430,
			},
		},
		[7] = {
			MaximumEnergy = 180,
			Speed = 14,
			RetargetTime = 2.8,
			Skin = Assets.PetModels.Mouse7,
			Animation = {
				Walk = 12704723974,
				WalkObject = 12704785111,
				Sit = 12704801456,
				Bored = 12704825725,
				Sleep = 12704831430,
			},
		},
	},
} :: PetKindData<RarityUtil.RarityName>

petsData.Cat = {
	Class = "Cat",
	PetModel = PetModels.Cat,
	SleepTimeLength = 90,
	Rarity = RarityUtil.Rare,
	LevelsStats = {
		[1] = {
			MaximumEnergy = 60,
			Speed = 4,
			RetargetTime = 3.4,
			Skin = Assets.PetModels.Cat,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12328546231,
				Bored = 12400607053,
				Sleep = 12339976330,
			},
		},
		[2] = {
			MaximumEnergy = 80,
			Speed = 5,
			RetargetTime = 3.2,
			Skin = Assets.PetModels.Cat2,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12455015618,
				Bored = 12444647263,
				Sleep = 12444663627,
			},
		},
		[3] = {
			MaximumEnergy = 100,
			Speed = 7,
			RetargetTime = 3.0,
			Skin = Assets.PetModels.Cat3,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12469481892,
				Bored = 12470333090,
				Sleep = 12469603948,
			},
		},
		[4] = {
			MaximumEnergy = 120,
			Speed = 8,
			RetargetTime = 2.8,
			Skin = Assets.PetModels.Cat4,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12476920666,
				Bored = 12477144570,
				Sleep = 12477026193,
			},
		},
		[5] = {
			MaximumEnergy = 140,
			Speed = 10,
			RetargetTime = 2.6,
			Skin = Assets.PetModels.Cat5,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12486206637,
				Bored = 12486641325,
				Sleep = 12486238759,
			},
		},
		[6] = {
			MaximumEnergy = 160,
			Speed = 11,
			RetargetTime = 2.4,
			Skin = Assets.PetModels.Cat6,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12486206637,
				Bored = 12486641325,
				Sleep = 12486238759,
			},
		},
		[7] = {
			MaximumEnergy = 180,
			Speed = 13,
			RetargetTime = 2.2,
			Skin = Assets.PetModels.Cat7,
			Animation = {
				Walk = 12308318874,
				WalkObject = 12319016926,
				Sit = 12486206637,
				Bored = 12486641325,
				Sleep = 12486238759,
			},
		},
	},
} :: PetKindData<RarityUtil.RarityName>

petsData.Dog = {
	Class = "Dog",
	PetModel = PetModels.Dog,
	SleepTimeLength = 90,
	Rarity = RarityUtil.ExtremelyRare,
	LevelsStats = {
		[1] = {
			MaximumEnergy = 78,
			Speed = 3,
			RetargetTime = 4,
			Skin = Assets.PetModels.Dog,
			Animation = {
				Walk = 12693536525,
				WalkObject = 12693565088,
				Sit = 12693950494,
				Bored = 12694890610,
				Sleep = 12694745704,
			},
		},
		[2] = {
			MaximumEnergy = 104,
			Speed = 4,
			RetargetTime = 3.8,
			Skin = Assets.PetModels.Dog2,
			Animation = {
				Walk = 12695128398, --12703946041
				WalkObject = 12695170409, --BROKEN
				Sit = 12693950494,
				Bored = 12694890610,
				Sleep = 12694745704,
			},
		},
		[3] = {
			MaximumEnergy = 130,
			Speed = 6,
			RetargetTime = 3.6,
			Skin = Assets.PetModels.Dog3,
			Animation = {
				Walk = 12695759963,
				WalkObject = 12695790080,
				Sit = 12695950765,
				Bored = 12696076408,
				Sleep = 12696046325,
			},
		},
		[4] = {
			MaximumEnergy = 156,
			Speed = 7,
			RetargetTime = 3.4,
			Skin = Assets.PetModels.Dog4,
			Animation = {
				Walk = 12695759963,
				WalkObject = 12695790080,
				Sit = 12703429363,
				Bored = 12703496673,
				Sleep = 12703478451,
			},
		},
		[5] = {
			MaximumEnergy = 182,
			Speed = 9,
			RetargetTime = 3.2,
			Skin = Assets.PetModels.Dog5,
			Animation = {
				Walk = 12703946041,
				WalkObject = 12704371025,
				Sit = 12704395096,
				Bored = 12704410206,
				Sleep = 12704404911,
			},
		},
		[6] = {
			MaximumEnergy = 208,
			Speed = 10,
			RetargetTime = 3.0,
			Skin = Assets.PetModels.Dog6,
			Animation = {
				Walk = 12703946041,
				WalkObject = 12704371025,
				Sit = 12704395096,
				Bored = 12704410206,
				Sleep = 12704404911,
			},
		},
		[7] = {
			MaximumEnergy = 234,
			Speed = 11,
			RetargetTime = 2.8,
			Skin = Assets.PetModels.Dog7,
			Animation = {
				Walk = 12703946041,
				WalkObject = 12704371025,
				Sit = 12704395096,
				Bored = 12704410206,
				Sleep = 12704404911,
			},
		},
	},
} :: PetKindData<RarityUtil.RarityName>

export type PetKindsData = typeof(petsData)

--[[function petsData.getPetKindData(petName : string)
	local petData

	--checking whether the obj name is valid and shallow copy the data table
	if petsData[petName] then
		petData = table.clone(petsData[petName])
	end

	--making sure obj data loads
	assert(petData and petData.PetModel, "Error upon loading object's data")

	--cloning the model to spawn
	petData.PetModel = petData.PetModel:Clone()

	return petData
end]]

return petsData
