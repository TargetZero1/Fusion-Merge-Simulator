--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--modules
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local characterUtil = {}

function characterUtil.AdjustCharacterScale(plr: Player, scaleNum: number)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid") :: Humanoid

	local bds = humanoid:WaitForChild("BodyDepthScale") :: any
	local bhs = humanoid:WaitForChild("BodyHeightScale") :: any
	local bws = humanoid:WaitForChild("BodyWidthScale") :: any
	local hs = humanoid:WaitForChild("HeadScale") :: any

	bds.Value, bhs.Value, bws.Value, hs.Value = scaleNum, scaleNum, scaleNum, scaleNum
end

function characterUtil.CreateCharacterObjectHolder(character: Model)
	assert(character and character.PrimaryPart and not character:FindFirstChild("ObjectHolder"))

	local ObjectHolder = Instance.new("Part")
	ObjectHolder.Name = "ObjectHolder"
	ObjectHolder.Size = character:GetExtentsSize() * Vector3.new(1, 2, 0)
		+ Vector3.new(0, 0, character:GetExtentsSize().Z * 1.5)
	ObjectHolder.Massless = true
	ObjectHolder.CFrame = character.PrimaryPart.CFrame
		+ character.PrimaryPart.CFrame.LookVector * MiscLists.MiscNumbers.DetectBlockDistance
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = character.PrimaryPart
	weldConstraint.Part1 = ObjectHolder
	weldConstraint.Parent = ObjectHolder
	ObjectHolder.Transparency = 1
	ObjectHolder.CanCollide = false
	ObjectHolder.Parent = character

	return ObjectHolder
end

function characterUtil.DetachObjectFromHolder(character: Model, object: BasePart?)
	local objHolder = character:FindFirstChild("ObjectHolder") :: BasePart
	if not objHolder then
		warn("Object holder not found")
		return
	end
	objHolder.CanTouch = false
	for _, weld: WeldConstraint in pairs(objHolder:GetChildren() :: any) do
		if
			weld:IsA("WeldConstraint")
			and ((object and (weld.Part0 == object)) or (not object and (weld.Part0 ~= character.PrimaryPart)))
		then
			weld:Destroy()
		end
	end
	task.spawn(function()
		task.wait(0.5)
		objHolder.CanTouch = true
	end)
end

function characterUtil.SetAnimation(character: Model, animId: string, onLoop: boolean)
	local Humanoid = character:FindFirstChild("Humanoid")
	assert(Humanoid, "Unable to find humanoid")
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator
	assert(Animator, "Unable to find animator!")

	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local animationTrack = Animator:LoadAnimation(animation)
	animationTrack.Looped = onLoop

	animationTrack:Play()
	animationTrack.Ended:Connect(function()
		animation:Destroy()
	end)
end

function characterUtil.kickObject(character: Model, object: BasePart, kickPower: number, kickArc: number)
	assert(character.PrimaryPart, "Character doesn't have pripart!")

	task.spawn(function()
		--sound fx
		local sound = Instance.new("Sound")
		sound.SoundId = MiscLists.AssetIdLists.SoundIds.KickSound
		sound.Parent = character.PrimaryPart
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)

		--particle fx
		if character.PrimaryPart then
			local attachment0 = Instance.new("Attachment")
			attachment0.Parent = object
			attachment0.CFrame = CFrame.new(0, -object.Size.Y * 0.1, 0)
			local attachment1 = Instance.new("Attachment")
			attachment1.Parent = object
			attachment1.CFrame = CFrame.new(0, object.Size.Y * 0.1, 0)

			local ParticleEmitter = Instance.new("ParticleEmitter")
			ParticleEmitter.Lifetime = NumberRange.new(0.5)
			ParticleEmitter.Rate = 30
			ParticleEmitter.Rotation = NumberRange.new(55)
			ParticleEmitter.RotSpeed = NumberRange.new(50)
			ParticleEmitter.Speed = NumberRange.new(30)
			ParticleEmitter.SpreadAngle = Vector2.new(0, 60)
			ParticleEmitter.Shape = Enum.ParticleEmitterShape.Cylinder
			ParticleEmitter.Enabled = true
			ParticleEmitter.Parent = object

			local Trail = Instance.new("Trail") :: Trail
			Trail.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
			Trail.Lifetime = 0.8
			Trail.Attachment0 = attachment0
			Trail.Attachment1 = attachment1
			Trail.Parent = object

			task.delay(5, function()
				Trail:Destroy()
				attachment0:Destroy()
				attachment1:Destroy()
			end)
			--tween
			task.wait(0.5)
			ParticleEmitter:Destroy()
		end
	end) -- sound
	object.AssemblyLinearVelocity = (
		(object.Position - character.PrimaryPart.Position).Unit
		* object:GetMass()
		* kickPower
	) + Vector3.new(0, kickArc, 0)
	--kick animation
	characterUtil.SetAnimation(character, MiscLists.AssetIdLists.AnimationIds.Kick, false)
end

return characterUtil
