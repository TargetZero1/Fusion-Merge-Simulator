--!strict
--services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--packages
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
--modules
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))
local RarityUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RarityUtil"))
local PetKinds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetKinds"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local PetsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetsUtil"))
local CharacterUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterUtil"))

--references

--variables
local Registry = {}

--types
type Maid = Maid.Maid

type PetKindsData = PetKinds.PetKindsData
type PetKindData = PetKinds.PetKindData<RarityUtil.RarityName>

export type PetProperties = PetsUtil.PetProperties
export type PetFunctions<self> = PetsUtil.PetFunctions<self>
export type Pet = PetsUtil.Pet
export type PetData = PetsUtil.PetData

export type AnimationActions = PetsUtil.AnimationActions

--constants
local MAX_ENERGY = 100
local MAX_EQUIPPED_PET_COUNT: number = MiscLists.Limits.MaximumEquippedPetCount
local ON_PET_DATA_UPDATE = "OnPetDataUpdate"

local GET_PET_MAX_EQUIP = "GetPetMaxEquip"
local ON_PET_MAX_EQUIP_UPDATE = "OnPetMaxEquipUpdate"

local ON_MERGE = "OnMerge"

--class
local Pet = {} :: Pet
Pet.__index = Pet

function Pet.new(model: Model, player: Player, cframe: CFrame, parent: Model, level: number?, equipped: boolean?): Pet
	assert(parent, "Parent not given?")

	local self = setmetatable({}, Pet) :: any
	self._isActive = true
	self.Maid = Maid.new() :: Maid
	self.Id = game:GetService("HttpService"):GenerateGUID(false)
	self.Player = player
	self.Class = "Pet"
	self.Parent = parent
	self.PetModel = self.Maid:GiveTask(model)
	self.Stats = {
		Equipped = if equipped ~= nil then equipped else false,
		Energy = math.clamp(MAX_ENERGY, 0, MAX_ENERGY), -- energy for the pets to be active
		Speed = 8, -- speed in which the pet moves (studs per second)
		BreakTime = 2, --break time in between going thorugh merging objects (in seconds)
		Rarity = RarityUtil.Common,
	}
	self.Level = level or 1
	self.Rarity = RarityUtil.Common
	--Registers pet
	Registry[self.Id] = self

	--grabbing plr data
	local plrData = if PlayerData then PlayerData.get(self.Player) else nil

	--give model position
	self.PetModel:PivotTo(cframe)

	--updates
	self:Update()

	--adds to pet index
	if plrData then
		plrData:AddIndexHistory("Pet", self.PetModel.Name)
	end
	--testing
	--task.spawn(function() task.wait(5);self:MoveTo(self.Player.Character.PrimaryPart) end)
	return self
end

function Pet:SetPetModel(class: PetsUtil.PetClass, level: number)
	if class and self.PetModel and self.PetModel.PrimaryPart then
		local petKind = PetKinds[class]
		local petStat = if petKind then petKind.LevelsStats else nil
		local levelStat = if petStat then petStat[level] else nil

		local prevPetModel = if self.PetModel and self.PetModel.PrimaryPart then self.PetModel else nil
		local petModel: Model = (if levelStat then levelStat.Skin:Clone() else prevPetModel) :: any

		assert(
			prevPetModel and petModel and prevPetModel.PrimaryPart and petModel.PrimaryPart,
			"Failed to load pet model!"
		)
		--set the pet model's parent and position
		petModel:PivotTo(prevPetModel.PrimaryPart.CFrame)
		petModel.Parent = prevPetModel.Parent
		self.PetModel = self.Maid:GiveTask(petModel)
		
		if prevPetModel ~= petModel then
			CollectionService:RemoveTag(prevPetModel, "Pet" :: PetsUtil.PetTag)
			prevPetModel:Destroy()
		end
		

		--making bodyPos and bodyGyro to attach the pet to player to follow through an object
		local AlignPosition = Instance.new("AlignPosition")
		local AlignOrientation = Instance.new("AlignOrientation")
		local Attachment0 = Instance.new("Attachment")
		Attachment0.Name = "Attachment0"
		Attachment0.Parent = self.PetModel.PrimaryPart
		AlignPosition.MaxForce = 16000
		AlignPosition.Parent = self.PetModel.PrimaryPart
		AlignPosition.MaxVelocity = self.Stats.Speed
		AlignOrientation.Parent = self.PetModel.PrimaryPart
		AlignOrientation.MaxTorque = 150000
		AlignPosition.Attachment0 = Attachment0
		AlignOrientation.Attachment0 = Attachment0

		--weld folder
		local weldFolders = Instance.new("Folder")
		weldFolders.Name = "WeldFolders"
		weldFolders.Parent = self.PetModel

		--declare the pet's id
		local petData =
			PetsUtil.newPetData(class, petModel, self.Player.UserId, self.Level, self.Stats.Equipped, self.Id)
		PetsUtil.applyPetData(petModel, petData)

		--tagging
		CollectionService:AddTag(self.PetModel, "Pet" :: PetsUtil.PetTag)

		--grabbing plr data
		local plrData = if PlayerData then PlayerData.get(self.Player) else nil

		--updating
		local intTick = tick()
		self.Maid.UpdateLoop = RunService.Stepped:Connect(function()
			if self.Stats.Equipped then
				--set attribute
				self.PetModel:SetAttribute("Energy", self.Stats.Energy)
				self.PetModel:SetAttribute("Level", self.Level)
			end
			--updates equipped
			if not self.Stats.Equipped then
				self._isActive = false
			end
			--updates parent
			self.PetModel.Parent = if self.Stats.Equipped
				then self.Parent
				else ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Storages")
			--consistently drains energy when active
			if self.Stats.Equipped and self._isActive then
				if (tick() - intTick) >= 1 then
					local energyReduceAmount = if plrData and plrData.PetInfiniteEnergy then 0 else 1

					self.Stats.Energy = math.clamp(self.Stats.Energy - energyReduceAmount, 0, self:GetMaxEnergy())
					intTick = tick()
					if self.Stats.Energy == 0 then
						self:Sleep()
					end
				end
			end
		end)

		--setting all welds inside the pet to true since it's turned off initially for no reason
		for _, v in pairs(self.PetModel:GetDescendants()) do
			if v:IsA("WeldConstraint") then
				v.Enabled = true
			end
		end

		--set collision
		self.PetModel.PrimaryPart.CollisionGroup = "Pet"

		--updates attribute
		self.PetModel:SetAttribute("MaxEnergy", self:GetMaxEnergy())

		return petModel
	end
	return nil
end

function Pet:SetEquip(bool: boolean)
	local plrData = PlayerData.get(self.Player)
	assert(plrData, "Unable to load player data!")
	if
		(PetsUtil.count(self.Player, true) >= (plrData:GetAdjustedPerkAmount("PetEquip", MAX_EQUIPPED_PET_COUNT)))
		and bool
	then
		warn("The amount of pets equipped already reached max")
		return
	end
	self.Stats.Equipped = bool
	if self.Stats.Equipped then
		self._isActive = true
		self:Stand() --resets the pet up
	end

	--gets pets data then sync the info to client
	local petsData = {}
	local petModels = Pet.getPets(self.Player)

	for _, v in pairs(petModels) do
		table.insert(petsData, PetsUtil.getPetData(v.PetModel))
	end

	NetworkUtil.fireClient(ON_PET_MAX_EQUIP_UPDATE, self.Player, Pet.getMaxEquipped(self.Player))
	return nil
end

function Pet:MoveTo(object: BasePart)
	assert(self.PetModel.PrimaryPart)
	if not object then
		warn("Object not detected")
		return
	end
	if self._isActive then
		--references
		local attachment0 = self.PetModel.PrimaryPart:FindFirstChild("Attachment0")
		--creating/referencing an attachment
		local attachment1 = Instance.new("Attachment")
		attachment1.CFrame =
			object.CFrame:ToObjectSpace(CFrame.lookAt(object.Position, self.PetModel.PrimaryPart.Position)) --adjusting the cframe so the pat oriented towards the destination
		attachment1.Name = "PetAttachment"
		attachment1.Parent = object

		--Referencing the pet's bodypos and bodygyro
		local AlignPosition = if self.PetModel.PrimaryPart
			then self.PetModel.PrimaryPart:FindFirstChild("AlignPosition") :: AlignPosition
			else nil
		local AlignOrientation = if self.PetModel.PrimaryPart
			then self.PetModel.PrimaryPart:FindFirstChild("AlignOrientation") :: AlignOrientation
			else nil
		assert(
			AlignPosition and AlignOrientation and attachment0 and attachment1,
			"Failed to load attachment in the pet's model"
		)

		--setting the attachment1(dest) of bodypos and bodygyro to the given destination object
		AlignPosition.Attachment1 = attachment1
		AlignOrientation.Attachment1 = attachment1
		-- exhaustion

		--play animation
		self:SetAnimation("Walk")

		--loop until it arrives to the destination
		local _taskRunning = false
		local _moving = true

		local plrData = if PlayerData then PlayerData.get(self.Player) else nil

		self.Maid.MoveTask = RunService.Stepped:Connect(function()
			if _taskRunning then
				return
			end
			_taskRunning = true

			--condition 1
			if
				not self.Stats.Equipped
				or not self.PetModel.PrimaryPart
				or not self.PetModel.PrimaryPart:FindFirstChild("AlignPosition")
				or not self.PetModel.PrimaryPart:FindFirstChild("AlignOrientation")
				or not self._isActive
			then
				self:Stand()
				_moving = false
				return
			end

			--condition 2
			if
				not object.Parent
				or (self.PetModel.PrimaryPart.Position - object.Position).Magnitude <= (object.Size.Magnitude * 0.5 + self.PetModel.PrimaryPart.Size.Magnitude * 0.5)
				or (self.Stats.Energy <= 0)
				or object.Anchored
				or (math.abs(object.AssemblyLinearVelocity.Y) >= 4)
			then
				if self.Stats.Energy <= 0 then
					self:Sleep()
				else
					self:Stand()
				end
				_moving = false
				return
			end

			--speed multiplier
			AlignPosition.MaxVelocity = self.Stats.Speed * (if plrData then plrData.PetSpeedMultiplier else 1)

			--exhausts energy by velocity (obselete)
			--[[absoluteEnergy -= self.EnergyPerStud*(self.PetModel.PrimaryPart.Position - intPos).Magnitude
            self.Energy = math.clamp(absoluteEnergy, 0, MAX_ENERGY)
            intPos = self.PetModel.PrimaryPart.Position ]]

			_taskRunning = false
		end)
		--yields the caller
		local intTask = self.Maid.MoveTask
		repeat
			wait()
		until not self.Maid or (_moving == false) or (intTask ~= self.Maid.MoveTask)
	end
	return nil
end

function Pet:Stand() --equivalent to reset (while equipped)
	if self._isActive then
		self:SetAnimation("Bored") --stop anim
	end

	self:Detach()

	if not self.Stats.Equipped then
		return
	end

	local AlignPosition = if self.PetModel.PrimaryPart
		then self.PetModel.PrimaryPart:FindFirstChild("AlignPosition") :: AlignPosition
		else nil
	local AlignOrientation = if self.PetModel.PrimaryPart
		then self.PetModel.PrimaryPart:FindFirstChild("AlignOrientation") :: AlignOrientation
		else nil
	assert(AlignPosition and AlignOrientation, "Failed to load attachment in the pet's model")

	if AlignPosition.Attachment1 then
		AlignPosition.Attachment1:Destroy()
	end
	if AlignOrientation.Attachment1 then
		AlignOrientation.Attachment1:Destroy()
	end

	self.Maid.MoveTask = nil
	return nil
end

function Pet:AttachTo(object: BasePart, modelToPivot: Model?)
	if self._isActive and self.PetModel and self.PetModel.PrimaryPart then
		if modelToPivot and modelToPivot.PrimaryPart then
			modelToPivot:PivotTo(
				self.PetModel.PrimaryPart.CFrame
					- self.PetModel.PrimaryPart.CFrame.LookVector * (self.PetModel.PrimaryPart.Size.Z + modelToPivot.PrimaryPart.Size.Z) * 0.5
					+ self.PetModel.PrimaryPart.CFrame.UpVector * self.PetModel.PrimaryPart.Size.Y
			)
		end
		local weldFolders = self.PetModel:FindFirstChild("WeldFolders")
		assert(self.PetModel.PrimaryPart and weldFolders)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = self.PetModel.PrimaryPart
		weld.Part1 = object
		weld.Parent = weldFolders

		self:SetAnimation("WalkObject") --walk with obj
	end
	return nil
end

function Pet:Detach()
	local weldFolders = self.PetModel:FindFirstChild("WeldFolders")
	assert(self.PetModel.PrimaryPart and weldFolders)

	weldFolders:ClearAllChildren()

	if self._isActive then
		self:SetAnimation("Sit")
	end
	return nil
end

function Pet:Sleep()
	assert(self.PetModel and self.PetModel.PrimaryPart)
	if self._isActive then
		self._isActive = false

		--detaches from objects
		self:Detach()

		--set sleeping anim
		self:SetAnimation("Sleep")

		--set recharge
		local intTick = tick()
		local sleepTotalTime = 0

		self.Maid.SleepingLoop = RunService.Stepped:Connect(function()
			--obselete (recharging sleep)
			--[[if (self._isActive) or (not self.Equipped) or (self.Energy >= MAX_ENERGY) then 
                --wakes the pet up (when it is activated)    
                self:Wake() 
                return 
            end
            if (tick() - intTick) >= 1 then
                print(absoluteEnergy)
                self.Energy = math.clamp(math.ceil(absoluteEnergy), 0, MAX_ENERGY)
                intTick = tick()
            end]]

			--new system (sleep for 30 secs)
			if (tick() - intTick) >= 1 then
				--print("Sleep time: ".. sleepTotalTime)
				sleepTotalTime += 1
				intTick = tick()
			end
			if sleepTotalTime >= 30 then
				self:Wake()
				return
			end
		end)

		--set proxprompt to wake the pet up
		local proxPrompt = Instance.new("ProximityPrompt")
		proxPrompt.Name = "Wake"
		proxPrompt.ActionText = "Wake"
		proxPrompt.RequiresLineOfSight = false
		proxPrompt.Parent = self.PetModel.PrimaryPart
		proxPrompt.Triggered:Connect(function(player)
			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart") :: BasePart
			hrp.Anchored = true
			char:PivotTo(
				CFrame.lookAt(
					hrp.Position,
					(self.PetModel.PrimaryPart.Position * Vector3.new(1, 0, 1)) + Vector3.new(0, hrp.Position.Y, 0)
				)
			)

			CharacterUtil.SetAnimation(char, MiscLists.AssetIdLists.AnimationIds.Pet, false)
			task.wait(3)
			pcall(function()
				self:Wake()
			end)

			hrp.Anchored = false
		end)
	end
	return nil
end

function Pet:Wake()
	--set the waking/walking anim

	--nilling sleeping loop
	self.Maid.SleepingLoop = nil

	--removes prox prompt inside the pet model
	for _, v: ProximityPrompt in pairs(self.PetModel:GetDescendants() :: any) do
		if v:IsA("ProximityPrompt") then
			v:Destroy()
		end
	end

	--stands the pet
	if self.Stats.Equipped then
		self._isActive = true
		self:Stand()
	end
	--set the energy to 100 (new system)
	self.Stats.Energy = self:GetMaxEnergy()
	return nil
end

function Pet:Upgrade()
	self.Level += 1

	self:Update()

	return nil
end

function Pet:Update()
	if self.Class then
		--update model
		self:SetPetModel(self.Class, self.Level)

		--updates speed
		local AlignPosition = if self.PetModel.PrimaryPart
			then self.PetModel.PrimaryPart:FindFirstChild("AlignPosition") :: AlignPosition
			else nil
		local AlignOrientation = if self.PetModel.PrimaryPart
			then self.PetModel.PrimaryPart:FindFirstChild("AlignOrientation") :: AlignOrientation
			else nil
		assert(AlignPosition and AlignOrientation, "Failed to load attachment in the pet's model")

		AlignPosition.MaxVelocity = self.Stats.Speed

		--equip set
		self:SetEquip(self.Stats.Equipped)

		--gets pets data then sync the info to client
		local petsData = {}
		local petModels = Pet.getPets(self.Player)
		for _, v in pairs(petModels) do
			table.insert(petsData, PetsUtil.getPetData(v.PetModel))
		end
		NetworkUtil.fireClient(ON_PET_DATA_UPDATE, self.Player, petsData)
	end
	return nil
end

function Pet:SetAnimation(actionName: string?)
	self.Maid.AnimationInstance = nil
	if self._Animation then
		self._Animation:Stop()
		self._Animation = nil
	end
	--[[if actionName then

		local petModelRig = self.PetModel:FindFirstChild(self.PetModel.Name .. "Rig")
		local animationController = if petModelRig
			then petModelRig:FindFirstChild("AnimationController") :: AnimationController
			else nil
		local Animator = if animationController then animationController:FindFirstChild("Animator") :: Animator else nil
		if animationController and Animator then
			local animation: Animation = Instance.new("Animation")
			self.Maid.AnimationInstance = animation
			animation.AnimationId = "http://www.roblox.com/asset/?id=" .. tostring(animId) --MiscLists.AnimationIds[self.PetModel.Name].Walk
			self._Animation = Animator:LoadAnimation(animation)
			if self._Animation then
				self._Animation.Looped = true
				self._Animation:Play()
			end
		end
	end]]

	return nil
end

function Pet.merge(petDatas: { PetData })
	local firstPetData = petDatas[1]
	local petInfo = if firstPetData then Pet.getById(firstPetData.PetId) else nil

	assert(petInfo, "Error laoding pet info!")

	local PetKind = PetKinds[petInfo.Class :: any] :: PetKinds.PetKindData<PetsUtil.PetClass>
	assert(PetKind, "Pet Class not found!")

	local levelStat = PetKind.LevelsStats[petInfo.Level]
	assert(levelStat, "Level not found!")

	local plr = if petInfo then petInfo.Player else nil

	assert(plr, "Player not found!")

	local success: boolean = false
	--upgrades the pet info
	if petInfo then
		petInfo:Upgrade()
		success = true
	end

	if success then --destroys other pets that are suitable for merge
		for _, otherPetData in pairs(petDatas) do
			local otherPetInfo = Pet.getById(otherPetData.PetId)
			if otherPetInfo and (petInfo ~= otherPetInfo) then
				otherPetInfo:Destroy()
			end
		end
	end

	--equips the pet
	if #PetsUtil.getPets(plr, true) < Pet.getMaxEquipped(plr) then
		petInfo:SetEquip(true)
	end

	--updates for client...
	local petsData = {}
	local petModels = Pet.getPets(plr)
	for _, v in pairs(petModels) do
		table.insert(petsData, PetsUtil.getPetData(v.PetModel))
	end
	NetworkUtil.fireClient(ON_PET_DATA_UPDATE, plr, petsData)

	--collecting identical pet by level
	--[[local identicalPets = {}
	for _,pet : PetData in pairs(PetsUtil.getPets(self.Player)) do
		if (pet ~= 7) and (pet.Level == self.Level) and (pet.PetModel.Name == self.PetModel.Name) then 
			table.insert(identicalPets, pet)
			if #identicalPets >= 2 then
				break
			end
		end
	end

	--upgrades the pet and destroys the other ones
	if #identicalPets == 2 then
		self:Upgrade()
		for _, pet in pairs(identicalPets) do
			pet:Destroy()
		end
	end

	--setting it equipped automatically
	if Pet.count(player, true) < MAX_EQUIPPED_PET_COUNT then
		self:SetEquip(true)
	end]]

	return nil
end

function Pet:Destroy()
	--unregisters
	Registry[self.Id] = nil

	--destroys rest
	self.Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(self, nil)
	return nil
end

function Pet:GetMaxEnergy()
	return MAX_ENERGY
end

function Pet.getMaxEquipped(plr: Player)
	local plrData = PlayerData.get(plr)
	assert(plrData, "Unable to load player data!")
	return plrData:GetAdjustedPerkAmount("PetEquip", MAX_EQUIPPED_PET_COUNT)
end

--[[function Pet:SetData(info)
	local petData = {} :: PetsUtil.PetData
	petData.Class = self.Class :: PetsUtil.PetClass
	petData.Equipped = (info.Equipped or self.Equipped) :: boolean
	petData.Level = (info.Level or self.Level) :: number
	petData.PetId = (self.Id) :: string
	petData.UserId = tostring(self.Player.UserId) :: string 
	petData.Name = self.PetModel.Name

	PetsUtil.applyPetData(self.PetModel, petData)

	self.Equipped = petData.Equipped
	self.Level = petData.Level
	self:Update()
	return nil
end

function Pet:GetData()
	return PetsUtil.getPetData(self.PetModel) :: PetsUtil.PetData
end]]

--Public Functions
function Pet.get(model: Model)
	for _, petInfo: Pet in pairs(Registry) do
		if petInfo.PetModel == model then
			return petInfo :: Pet
		end
	end
	return nil
end

function Pet.getById(id: string)
	return Registry[id]
end

function Pet.getPets(player: Player?, equipped: boolean?)
	local array = {}
	for _, info: Pet in pairs(Registry) do
		if
			((player and info.Player == player) or not player)
			and (((equipped ~= nil) and info.Stats.Equipped) or (equipped == nil))
		then
			table.insert(array, info)
		end
	end
	return array
end

function Pet.hatch(petClass: PetsUtil.PetClass, isPremium: boolean, isLucky: boolean, isSuperLucky: boolean): string
	local levelWeights = {
		[1] = 80, 
		[2] = 15, 
		[3] = 5, 
		[4] = 0.01, 
		[5] = 0.01, 
		[6] = 0.01, 
		[7] = 0.01
	}

	local minWeight = math.huge
	for i, levelWeight in ipairs(levelWeights) do
		minWeight = math.min(levelWeight, minWeight)
	end

	local ticketMultiplier = math.ceil(1/minWeight)
	
	local raffleTickets = {}

	-- print(petClass, "prem", isPremium)

	for lvl, basePoints in ipairs(levelWeights) do
		-- local petInfo: PetKindData = PetKinds[petName]
		local rarityPoints: number = basePoints * ticketMultiplier --RarityUtil[petInfo.Rarity].RarityPoint
		if isPremium then
			if lvl ~= 7 then
				rarityPoints = 0
			end
		else
			if isLucky then
				if lvl == 1 then
					rarityPoints -= 15 * ticketMultiplier
				elseif lvl == 2 then
					rarityPoints += 10 * ticketMultiplier
				elseif lvl == 3 then
					rarityPoints += 5 * ticketMultiplier
				end
			end
			if isSuperLucky then
				if lvl == 1 then
					rarityPoints -= 25 * ticketMultiplier
				elseif lvl == 2 then
					rarityPoints += 15 * ticketMultiplier
				elseif lvl == 3 then
					rarityPoints += 10 * ticketMultiplier
				end
			end
		end
		-- print("LVL", lvl, "PTS", rarityPoints * ticketMultiplier)
		for pt = 1, math.max(rarityPoints * ticketMultiplier, 0) do
			if lvl > 1 then
				table.insert(raffleTickets, petClass .. tostring(lvl))
			else
				table.insert(raffleTickets, petClass)
			end
		end
	end

	return raffleTickets[math.random(#raffleTickets)]
end

function _testHatchRates()
	local hatchCount = 1000
	local class: PetsUtil.PetClass = "Cat"
	local isPremium = false
	local isLucky = false
	local isSuperLucky = true
	local selections: {[string]: number} = {}
	local testStart = tick()
	print("test start")
	for i=1, hatchCount do
		if i%100 == 0 then
			print(math.round(10*100*(i/hatchCount))/10, "% complete")
			task.wait()
		end
		local result = Pet.hatch(class, isPremium, isLucky, isSuperLucky)
		selections[result] = selections[result] or 0
		selections[result] += 1
	end
	local testDuration = tick() - testStart
	print("Average Time Per Hatch: ", math.round(1000*testDuration/hatchCount)/1000, "s")

	local winRate = {}
	for k, v in pairs(selections) do
		winRate[k] = tostring(math.round(100*100*(v/hatchCount))/100).."%"
	end
	
	print("WIN RATE", winRate)
end
-- task.spawn(_testHatchRates)


function Pet.clear(player: Player?)
	--clears all the pet, optionally by player param
	for _, petInfo: Pet in pairs(Registry) do
		if (player and (petInfo.Player == player)) or not player then
			petInfo:Destroy()
		end
	end
	return nil
end

function Pet.init(maid: Maid)
	local petModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PetModels")
	--weld constraint
	for _, petModel: Model in pairs(petModels:GetChildren() :: any) do
		for _, part: BasePart in pairs(petModel:GetDescendants() :: any) do
			if part:IsA("BasePart") and (petModel.PrimaryPart ~= part) and petModel.PrimaryPart then
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = petModel.PrimaryPart
				weld.C0 = part.CFrame:Inverse() * petModel.PrimaryPart.CFrame
				weld.C1 = CFrame.new()
				weld.Parent = petModel.PrimaryPart
			end
		end
	end

	--server to client comm
	NetworkUtil.onServerInvoke("Equip", function(plr: Player, petModel: Model, equip: boolean)
		local petInfo = Pet.get(petModel)
		assert(petInfo, "Can not find pet registry")
		petInfo:SetEquip(not petInfo.Stats.Equipped)
		petInfo:Update()
		return true
	end)

	NetworkUtil.onServerInvoke("Destroy", function(plr: Player, petModel: Model)
		local petInfo = Pet.get(petModel)
		assert(petInfo, "Can not find pet registry")

		if petInfo then
			petInfo:Destroy()
		end

		--updates client
		local petsData = {}
		local petModels = Pet.getPets(plr)
		for _, v in pairs(petModels) do
			table.insert(petsData, PetsUtil.getPetData(v.PetModel))
		end
		NetworkUtil.fireClient(ON_PET_DATA_UPDATE, plr, petsData)

		return nil
	end)

	NetworkUtil.onServerInvoke(ON_MERGE, function(plr: Player, petDataColl: { PetData })
		--print("Merge..")
		print("Server On Merge")
		local petName: string
		local count = 0
		for _, v in pairs(petDataColl) do
			if v.UserId == tostring(plr.UserId) then
				petName = petName or v.Name
				if v.Name ~= petName then
					return false
				end
				count += 1
			end
		end
		if count ~= 3 then
			return false
		end

		--print("Merge!", petDataColl)
		Pet.merge(petDataColl)
		return true
	end)

	NetworkUtil.onServerInvoke(GET_PET_MAX_EQUIP, function(plr: Player)
		return Pet.getMaxEquipped(plr)
	end)

	NetworkUtil.getRemoteEvent(ON_PET_MAX_EQUIP_UPDATE)

	return nil
end

return Pet
