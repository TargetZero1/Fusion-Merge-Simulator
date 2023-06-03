--!strict
--services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))
--modules
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))

local MainSysUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MainSysUtil"))
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local CharacterUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterUtil"))

--types
type Maid = Maid.Maid

--constants
local DEFAULT_BONUS_BLOCK_LEVEL = 1

local BLOCK_SPAWN_INTERVAL = 60
local BLOCK_KICK_CHECK_SPAWN_INTERVAL = 30

local BLOCK_KICK_CHECK_INTERVAL = math.huge

local BLOCK_MIN_VELOCITY = 1

local ON_BONUS_BLOCK_INTERACT = "OnBonusBlockInteract"

--references
local Player = Players.LocalPlayer
local Assets = ReplicatedStorage:WaitForChild("Assets") :: Folder
local MiscAssets = workspace:WaitForChild("MiscAssets") :: Folder
local BonusBlockSpawners = MiscAssets:WaitForChild("BonusBlockSpawners") :: Model

--private functions
function spawnBlockBonus(blockType: number, maid: Maid?)
	local blockMaid = maid or Maid.new()
	--create a new block
	local newBlockData = BlocksUtil.newBlockData(-1, blockType, true)
	local newBlockModel = Assets:WaitForChild("ObjectModels"):WaitForChild("TypeA"):Clone() :: Model

	--apply block data
	BlocksUtil.applyBlockData(newBlockModel, newBlockData)
	BlocksUtil.BlockLeveLVisualUpdate(newBlockModel, newBlockData)
	--apply text
	--      for _,v : TextLabel in pairs(newBlockModel:GetDescendants() :: any) do
	--         if v:IsA("TextLabel") then
	--             v.Text = tostring(blockType) .. "x"
	--         end
	--     end

	--apply textures
	for _, v: Texture in pairs(newBlockModel:GetDescendants() :: any) do
		local textureId = MiscLists.AssetIdLists.TextureIds["BlockLevel" .. tostring(blockType + 64)]
		if v:IsA("Texture") and textureId then
			v.Texture = textureId
		end
	end

	--adds functionality
	if newBlockModel.PrimaryPart then
		blockMaid:GiveTask(newBlockModel.PrimaryPart.Touched:Connect(function(hit)
			local plotModel = if hit.Parent and hit.Parent.Name == "Separators" then hit.Parent.Parent :: Model else nil
			local plotData = if plotModel and plotModel:IsA("Model") then MainSysUtil.getMainSysData(plotModel) else nil

			if plotData and (plotData.UserId == tostring(Player.UserId)) and plotModel and plotModel.PrimaryPart then
				--anti-exploit measure #1
				local raycastParam = RaycastParams.new()
				raycastParam.FilterDescendantsInstances = { hit }
				raycastParam.FilterType = Enum.RaycastFilterType.Include
				raycastParam.CollisionGroup = "Separator"
				local raycastResult: RaycastResult? = workspace:Raycast(
					newBlockModel.PrimaryPart.Position,
					hit.Position - newBlockModel.PrimaryPart.Position,
					raycastParam
				)

				assert(raycastResult)
				--local worldFaceV3 = hit.CFrame:VectorToWorldSpace(raycastResult.Normal)
				local worldFaceV3 = raycastResult.Normal
				local dot = worldFaceV3:Dot((plotModel.PrimaryPart.Position - hit.Position).Unit)

				local pos = newBlockModel.PrimaryPart.Position
				newBlockModel:SetAttribute("isHitPlot", true)
				newBlockModel:Destroy()

				if dot <= 0 then
					--flashy particle
					local part = Instance.new("Part")
					part.Transparency = 1
					part.Position = pos
					part.CanCollide = false
					part.Anchored = true
					part.Parent = workspace

					local ParticleEmitter = Instance.new("ParticleEmitter")
					ParticleEmitter.Brightness = 10
					ParticleEmitter.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					})
					ParticleEmitter.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 190, 200)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 50, 255)),
					})
					ParticleEmitter.Lifetime = NumberRange.new(0.5, 2)
					ParticleEmitter.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 8),
						NumberSequenceKeypoint.new(1, 10),
					})
					ParticleEmitter.Rate = 60
					ParticleEmitter.Rotation = NumberRange.new(55)
					ParticleEmitter.RotSpeed = NumberRange.new(50)
					ParticleEmitter.Speed = NumberRange.new(30)
					ParticleEmitter.SpreadAngle = Vector2.new(0, 60)
					ParticleEmitter.Shape = Enum.ParticleEmitterShape.Cylinder
					ParticleEmitter.Enabled = true
					ParticleEmitter.Parent = part
					task.wait(0.25)
					ParticleEmitter.Enabled = false

					Debris:AddItem(part, 2)

					NetworkUtil.fireServer(ON_BONUS_BLOCK_INTERACT, blockType)
					--plotInfo:DropBlocks(blockType)
				end
			end
		end))
	end

	--detects on destroy
	blockMaid:GiveTask(newBlockModel.Destroying:Connect(function()
		if blockMaid.isMaid then
			blockMaid:Destroy()
		end
	end))

	return newBlockModel
end

local function initBlockSpawner(blockSpawner: BasePart)
	local blockMaid = Maid.new()
	local blockBonus = blockMaid:GiveTask(
		spawnBlockBonus(blockSpawner:GetAttribute("BlockBonusType") or DEFAULT_BONUS_BLOCK_LEVEL, blockMaid)
	)
	assert(blockBonus.PrimaryPart, "Unable to load block bonus model's primary part")
	blockBonus.Parent = MiscAssets:WaitForChild("BonusBlocks")
	assert(blockBonus.Parent, "Block bonus can't find the parent!")
	blockBonus:PivotTo(blockSpawner.CFrame + Vector3.new(0, blockBonus.PrimaryPart.Size.Y, 0))

	local initialized = false
	local hitPlot = false
	blockMaid:GiveTask(blockBonus.Destroying:Connect(function() --upon destroyed, spawn the block again
		if not initialized then
			initialized = true
			if blockMaid.isMaid then
				blockMaid:Destroy()
			end
			if blockBonus:GetAttribute("isHitPlot") then
				hitPlot = true
			end
			task.wait(if hitPlot then BLOCK_SPAWN_INTERVAL else BLOCK_KICK_CHECK_SPAWN_INTERVAL)
			--task.wait()
			initBlockSpawner(blockSpawner)
		end
	end))

	local intTick = tick()
	blockMaid:GiveTask(RunService.Stepped:Connect(function()
		if hitPlot then
			blockMaid:Destroy()
			return
		end

		if not blockBonus.PrimaryPart then
			blockMaid:Destroy()
			return
		end

		if
			((tick() - intTick) >= BLOCK_KICK_CHECK_INTERVAL)
			or (blockBonus.PrimaryPart.AssemblyLinearVelocity.Magnitude >= BLOCK_MIN_VELOCITY)
		then
			--if ((tick() - intTick) >= 1) then
			intTick = tick()
			if
				not hitPlot
				and not initialized
				and (
					blockBonus.PrimaryPart
					and (blockBonus.PrimaryPart.AssemblyLinearVelocity.Magnitude < BLOCK_MIN_VELOCITY)
				)
			then
				initialized = true
				blockMaid:Destroy()
				task.wait(BLOCK_KICK_CHECK_SPAWN_INTERVAL)
				initBlockSpawner(blockSpawner)
			end
		end
	end))
end

return {
	init = function(maid: Maid)
		for _, v: BasePart in pairs(BonusBlockSpawners:GetChildren() :: any) do
			if v:IsA("BasePart") then
				initBlockSpawner(v) --cursive function loop for spawner
			end
		end

		--kick
		--[[local function initCharacter(char: Model)
			local hrp = char:WaitForChild("HumanoidRootPart")
			assert(char and hrp, "Character not found!")

			local ObjectHolder = char:WaitForChild("ObjectHolder") :: BasePart
			assert(ObjectHolder and ObjectHolder:IsA("BasePart"), "Object holder not detected")

			maid.CharMaid = Maid.new()
			local charMaid = maid.CharMaid :: Maid

			if not charMaid then
				return
			end

			charMaid:GiveTask(ObjectHolder.Touched:Connect(function(hit)
				local blockData = if hit.Parent then BlocksUtil.getBlockData(hit.Parent :: Model) else nil
				if blockData and blockData.UserId == "-1" then
					local kickMode = Player:GetAttribute("KickMode")
					local kickPower = MiscLists.Limits.KickPower
					local kickArc = MiscLists.Limits.KickArc

					kickPower = if kickMode == "Kick"
						then kickPower
						elseif kickMode == "Punt" then kickPower * MiscLists.Limits.KickModeEffect.PuntPowerMultiplier
						else kickPower * MiscLists.Limits.KickModeEffect.TapPowerMultiplier
					kickArc = if kickMode == "Kick"
						then kickArc
						elseif kickMode == "Punt" then kickArc * MiscLists.Limits.KickModeEffect.PuntArcMultiplier
						else kickArc * kickPower * MiscLists.Limits.KickModeEffect.TapArcMultiplier

					CharacterUtil.kickObject(char, hit, kickPower, kickArc)

					if not BadgeService:UserHasBadgeAsync(Player.UserId, MiscLists.BadgeIds.FoundBonusBlock) then
						BadgeService:AwardBadge(Player.UserId, MiscLists.BadgeIds.FoundBonusBlock)
					end
				end
			end))

			charMaid:GiveTask(char.Destroying:Connect(function()
                charMaid:Destroy()
            end))
		end

		local character = Player.Character or Player.CharacterAdded:Wait()
		initCharacter(character)

		Player.CharacterAdded:Connect(initCharacter)]]
	end,
}
