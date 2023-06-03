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

export type DogProperties = {} & Pet.PetProperties
export type DogFunctions<Self> = {} & Pet.PetFunctions<Self>
export type DogInfo<Self> = DogProperties & DogFunctions<Self>
export type Dog = DogInfo<DogInfo<any>>

--class
local Dog = {} :: Dog
Dog.__index = Dog
setmetatable(Dog, Pet)

function Dog.new(model: Model, player: Player, cframe: CFrame, ...): Dog
	local self = setmetatable(Pet.new(model, player, cframe, ...), Dog) :: any
	self.PetModel.Name = "Dog"
	self.Rarity = PetKinds.Dog.Rarity :: { [any]: any }
	self.Speed = 19 :: number
	self.Energy = self:GetMaxEnergy()
	self.BreakTime = 1 :: number
	self.Class = "Dog"

	--adjusting velocity
	local AlignPosition = self.PetModel.PrimaryPart:FindFirstChild("AlignPosition")
	AlignPosition.MaxVelocity = self.Speed

	self:Update()
	return self
end

function Dog:SetAnimation(actionName: Pet.AnimationActions?)
	Pet.SetAnimation(self, actionName)

	if actionName then
		local levelStats = PetKinds.Dog.LevelsStats[self.Level]
		--print(levelStats)
		local animId = if levelStats then levelStats.Animation[actionName] else nil

		local petModelRig = self.PetModel:FindFirstChild("DogRig")
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

function Dog:GetMaxEnergy()
	assert(PetKinds.Dog.LevelsStats[self.Level], "Level not found!")
	return PetKinds.Dog.LevelsStats[self.Level].MaximumEnergy
end

function Dog.init(maid: Maid)
	return nil
end

return Dog
