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

export type MouseProperties = {} & Pet.PetProperties
export type MouseFunctions<Self> = {} & Pet.PetFunctions<Self>
export type MouseInfo<Self> = MouseProperties & MouseFunctions<Self>
export type Mouse = MouseInfo<MouseInfo<any>>

--class
local Mouse = {} :: Mouse
Mouse.__index = Mouse
setmetatable(Mouse, Pet)

function Mouse.new(model: Model, player: Player, cframe: CFrame, ...): Mouse
	local self = setmetatable(Pet.new(model, player, cframe, ...), Mouse) :: any
	self.PetModel.Name = "Mouse"
	self.Energy = self:GetMaxEnergy()
	self.Rarity = PetKinds.Mouse.Rarity :: { [any]: any }
	self.Class = "Mouse"

	self:Update()
	return self
end

function Mouse:SetAnimation(actionName: Pet.AnimationActions?)
	Pet.SetAnimation(self, actionName)

	if actionName then
		local levelStats = PetKinds.Mouse.LevelsStats[self.Level]
		local animId = if levelStats then levelStats.Animation[actionName] else nil

		local petModelRig = self.PetModel:FindFirstChild("MouseRig")
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

function Mouse:GetMaxEnergy()
	assert(PetKinds.Mouse.LevelsStats[self.Level], "Level not found!")
	return PetKinds.Mouse.LevelsStats[self.Level].MaximumEnergy
end

function Mouse.init(maid: Maid)
	return nil
end

return Mouse
