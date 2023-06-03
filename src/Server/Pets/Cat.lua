--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local PetKinds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetKinds"))
--classes
local Pet = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Pet"))

--types
type Maid = Maid.Maid

type Pet = Pet.Pet

export type CatProperties = {} & Pet.PetProperties
export type CatFunctions<Self> = {} & Pet.PetFunctions<Self>
export type CatInfo<Self> = CatProperties & CatFunctions<Self>
export type Cat = CatInfo<CatInfo<any>>

--class
local Cat = {} :: Cat
Cat.__index = Cat
setmetatable(Cat, Pet)

function Cat.new(model: Model, player: Player, cframe: CFrame, ...): Cat
	local self = setmetatable(Pet.new(model, player, cframe, ...), Cat) :: any
	self.PetModel.Name = "Cat"
	self.Rarity = PetKinds.Cat.Rarity :: { [any]: any }
	self.Speed = 16 :: number
	self.Energy = self:GetMaxEnergy()
	self.BreakTime = 4 :: number
	self.Class = "Cat"

	--adjusting velocity
	local AlignPosition = self.PetModel.PrimaryPart:FindFirstChild("AlignPosition")
	AlignPosition.MaxVelocity = self.Speed

	self:Update()
	return self
end

function Cat:Sleep()
	Pet.Sleep(self)
	return nil
end

function Cat:SetAnimation(actionName: Pet.AnimationActions?)
	Pet.SetAnimation(self, actionName)
	if actionName then
		local levelStats = PetKinds.Cat.LevelsStats[self.Level]
		local animId = if levelStats then levelStats.Animation[actionName] else nil

		local petModelRig = self.PetModel:FindFirstChild("CatRig")
		local animationController = if petModelRig
			then petModelRig:FindFirstChild("AnimationController") :: AnimationController
			else nil
		local Animator = if animationController then animationController:FindFirstChild("Animator") :: Animator else nil

		if animationController and Animator then
			local s, e = pcall(function()
				local animation: Animation = Instance.new("Animation")
				self.Maid.AnimationInstance = animation
				animation.AnimationId = "http://www.roblox.com/asset/?id=" .. tostring(animId) --MiscLists.AnimationIds[self.PetModel.Name].Walk
				self._Animation = Animator:LoadAnimation(animation)
				if self._Animation then
					self._Animation.Looped = true
					self._Animation:Play()
				end
			end)
			if not s then
				warn(e)
				return nil
			end
		end
	end

	return nil
end

function Cat:GetMaxEnergy()
	assert(PetKinds.Cat.LevelsStats[self.Level], "Level not found!")
	return PetKinds.Cat.LevelsStats[self.Level].MaximumEnergy
end

function Cat.init(maid: Maid)
	return nil
end

return Cat
