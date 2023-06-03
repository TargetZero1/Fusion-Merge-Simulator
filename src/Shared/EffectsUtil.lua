--!strict

--Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

--References

--Packages
local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

--Modules
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))
local GuiLibrary = RunService:IsClient()
	and require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("GuiLibrary"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

--variables
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Children = Fusion.Children

--module
local EffectsUtil = {}
function EffectsUtil.FlyingText(inst: Instance, text: string, textProperties: { [any]: any }?)
	textProperties = textProperties or {} :: { [any]: any }
	local function addTextLbl()
		local textLbl = Instance.new("TextLabel")
		textLbl.Size = UDim2.new(1, 0, 1, 0)
		textLbl.TextSize = if textProperties and textProperties.TextSize ~= nil then textProperties.TextSize else 25
		textLbl.TextScaled = if textProperties and textProperties.TextScaled ~= nil
			then textProperties.TextScaled
			else true
		textLbl.Position = UDim2.new(0, 0, 0, 0)
		textLbl.BackgroundTransparency = 1
		textLbl.TextStrokeTransparency = 0.5
		textLbl.TextColor3 = textProperties and textProperties.TextColor3 or Color3.fromRGB(0, 155, 0)
		textLbl.Name = "NotifText"
		textLbl.Text = text
		return textLbl
	end

	local bg = Instance.new("BillboardGui")
	bg.AlwaysOnTop = true
	bg.Size = UDim2.new(4, 0, 2, 0)
	bg.ExtentsOffset = Vector3.new(0, 1, 0)
	bg.Parent = inst
	local textLbl = addTextLbl()
	textLbl.Parent = bg
	tweenService
		:Create(
			textLbl,
			TweenInfo.new(1),
			{ Position = textLbl.Position - UDim2.new(0, 0, 0.5, 0), TextTransparency = 1, TextStrokeTransparency = 1 }
		)
		:Play()
	task.wait(2)
	bg:Destroy()
	return nil

	--[[local sGui      =   player.PlayerGui:FindFirstChild("NotifScreen") or Instance.new("ScreenGui")
    sGui.Name       =   "NotifScreen"
    sGui.Parent     =   player.PlayerGui
    local frame     =   sGui:FindFirstChild("Frame") or Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size      =   UDim2.new(1,0,1,0)
    frame.Position  =   UDim2.new(0,0,0,0)
    frame.Name      =   "Frame"
    frame.Parent    =   sGui
    local uiList    =   frame:FindFirstChild("UIListLayout") or Instance.new("UIListLayout")
    uiList.Name     =   "UIListLayout"
    uiList.HorizontalAlignment  = Enum.HorizontalAlignment.Center
    uiList.Parent   =   frame
    local textLbl = addTextLbl()
    textLbl.Parent  =   frame]]
	--[[task.wait(4)
    --destroy the text
    textLbl:Destroy()

    --destroy if theres no more texts to show
    if #frame:GetChildren() <= 1 then
        sGui:Destroy()
    end]]
end

function EffectsUtil.EggHatch(ScreenGui: ScreenGui, petName: string)
	--create egg image (old version, will have fusion later (not enough time :P))
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backgroundFrame.Size = UDim2.fromScale(1, 1)
	backgroundFrame.Transparency = 0.25
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.ZIndex = -2
	backgroundFrame.Parent = ScreenGui
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
	imageLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = MiscLists.AssetIdLists.ImageIds.EggImage
	imageLabel.Parent = ScreenGui
	--do shaking anim for egg
	do
		local shakingCount = 6
		local tweenTime = 0.2
		for i = 1, shakingCount do
			local tweenAdjustedTime = math.abs(tweenTime * math.cos(math.rad(180 * (i / shakingCount))))
			local tween = tweenService:Create(imageLabel, TweenInfo.new(tweenAdjustedTime), { Rotation = 10 })
			tween:Play()
			tween.Completed:Wait()
			local tween2 = tweenService:Create(imageLabel, TweenInfo.new(tweenAdjustedTime), { Rotation = -10 })
			tween2:Play()
			tween2.Completed:Wait()
		end
		tweenService:Create(imageLabel, TweenInfo.new(tweenTime * 1.5), { Rotation = 0 }):Play()
		task.wait(1.5)
	end
	imageLabel:Destroy()

	--shows viewport
	local _vp = GuiLibrary.Frames.ViewportFrame({
		Parent = ScreenGui,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.25, 0.25),
		BackgroundColor3 = Color3.fromRGB(0, 100, 200),
		CameraDistance = 3,
		Name = "PetPhoto",
		Model = Assets.PetModels:FindFirstChild(petName) and Assets.PetModels:FindFirstChild(petName):Clone() or nil,
		[Children] = {
			GuiLibrary.Texts.DefaultTextLabel({
				Name = "PetText",
				ZIndex = 4,
				Text = "You hatched a " .. string.lower(petName),
			}),
		},
	})
	task.spawn(function()
		task.wait(2)
		backgroundFrame:Destroy()
		_vp:Destroy()
	end)
	return nil
end

function EffectsUtil.OnSpawn(BasePart: BasePart)
	--spawn splash particle
	local splashParticle = Instance.new("ParticleEmitter")
	splashParticle.Name = "SplashParticle"
	splashParticle.Brightness = 10
	splashParticle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 126)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 126)),
	})
	splashParticle.LightEmission = 1
	splashParticle.LightInfluence = 0
	splashParticle.Orientation = Enum.ParticleOrientation.VelocityParallel
	splashParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	splashParticle.Texture = "rbxassetid://10891594349"
	splashParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
	splashParticle.EmissionDirection = Enum.NormalId.Front
	splashParticle.Lifetime = NumberRange.new(0.5, 1)
	splashParticle.Rate = 50
	splashParticle.Speed = NumberRange.new(40)
	splashParticle.SpreadAngle = Vector2.new(360, 360)

	splashParticle.Parent = BasePart

	--disabling splash particle
	task.spawn(function()
		task.wait(0.15)
		splashParticle.Enabled = false
		task.wait(0.5)
		splashParticle:Destroy()
	end)
	return nil
end

function EffectsUtil.OnMergeEffect(BasePart: BasePart)
	--spawn explosion particle
	local explosionParticle = Instance.new("ParticleEmitter")
	explosionParticle.Brightness = 80
	explosionParticle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 175, 62)),
	})
	explosionParticle.LightEmission = 1
	explosionParticle.LightInfluence = 0
	explosionParticle.Orientation = Enum.ParticleOrientation.FacingCamera
	explosionParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 15),
		NumberSequenceKeypoint.new(1, 2.5),
	})
	explosionParticle.Texture = "rbxassetid://6490035152"
	explosionParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	explosionParticle.EmissionDirection = Enum.NormalId.Front
	explosionParticle.Lifetime = NumberRange.new(0.8)
	explosionParticle.Rate = 10
	explosionParticle.Speed = NumberRange.new(0, 0)
	explosionParticle.SpreadAngle = Vector2.new(0, 0)

	--spawn splash particle
	EffectsUtil.OnSpawn(BasePart)
	local splashParticle: ParticleEmitter? = (BasePart:FindFirstChild("SplashParticle") :: ParticleEmitter) or nil
	if splashParticle then
		--make it colorful
		splashParticle.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 255, 53)),
			ColorSequenceKeypoint.new(0.0882, Color3.fromRGB(125, 170, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(164, 15, 38)),
			ColorSequenceKeypoint.new(0.263, Color3.fromRGB(249, 56, 149)),
			ColorSequenceKeypoint.new(0.358, Color3.fromRGB(37, 51, 250)),
			ColorSequenceKeypoint.new(0.445, Color3.fromRGB(203, 203, 203)),
			ColorSequenceKeypoint.new(0.661, Color3.fromRGB(230, 68, 27)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
		splashParticle.Rate = 200
	end

	--spawn halo particle
	local haloParticle = Instance.new("ParticleEmitter")
	haloParticle.Brightness = 1
	haloParticle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	haloParticle.LightEmission = 0
	haloParticle.LightInfluence = 0
	haloParticle.Orientation = Enum.ParticleOrientation.FacingCamera
	haloParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 15),
	})
	haloParticle.Texture = "rbxassetid://6900421398"
	haloParticle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.394),
		NumberSequenceKeypoint.new(1, 0.961),
	})
	haloParticle.EmissionDirection = Enum.NormalId.Front
	haloParticle.Lifetime = NumberRange.new(0.5)
	haloParticle.Rate = 25
	haloParticle.Speed = NumberRange.new(0)
	haloParticle.SpreadAngle = Vector2.new(0, 0)

	--setting parents first
	explosionParticle.Parent = BasePart
	if splashParticle then
		splashParticle.Parent = BasePart
	end
	haloParticle.Parent = BasePart
	--disabling explosion particle
	task.spawn(function()
		task.wait(0.15)
		explosionParticle.Enabled = false
		task.wait(1)
		explosionParticle:Destroy()
	end)

	--disabling halo particle
	task.spawn(function()
		task.wait(0.15)
		haloParticle.Enabled = false
		task.wait(1)
		haloParticle:Destroy()
	end)

	--play sound
	task.spawn(function()
		local sound = Instance.new("Sound")
		sound.SoundId = MiscLists.AssetIdLists.SoundIds.ExplosionSound
		sound.RollOffMaxDistance = math.huge
		sound.Volume = 1
		sound.Parent = BasePart
		sound:Play()
		sound.Ended:Wait()
		sound:Destroy()
	end)

	--objects spinning and levitating
	task.wait(0.15)
	BasePart.Anchored = true
	local oriCf = BasePart.CFrame
	local targetAngle = 360
	for i = 1, targetAngle, 8 do
		task.wait()
		local alpha = (math.sin(math.rad(i / (targetAngle / 90))))
		BasePart.CFrame = CFrame.fromEulerAnglesYXZ(0, math.rad(NumberUtil.LerpNumber(1, targetAngle, alpha)), 0)
				* (oriCf - oriCf.Position)
			+ (oriCf.Position + Vector3.new(0, math.sin(math.rad(i / 2)) * 2, 0))
	end
	BasePart.Anchored = false

	--alter object size
	--[[local oriObject = ReplicatedStorage.Assets.ObjectModels:FindFirstChild(objModel.Name)
        local size = oriObject:FindFirstChild("MeshPart") and oriObject.MeshPart.Size

        if objModel:FindFirstChild("MeshPart") then
            tweenService:Create(objModel:FindFirstChild("MeshPart"), TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true), {Size = size - Vector3.new(0.1,0.1,0.1)}):Play()
        end]]
	return nil
end

function EffectsUtil.GainProfitFX(at: Vector3, targetFrame: GuiObject, ScreenGui: ScreenGui)
	--cash fx
	local statsFrame = targetFrame
	local worldToScreen, isVisible = workspace.CurrentCamera:WorldToScreenPoint(at)
	if not isVisible then
		return
	end
	local cashImagePos = if worldToScreen
		then UDim2.fromOffset(worldToScreen.X, worldToScreen.Y)
		else UDim2.fromScale(0.4, 0.4)
	local cashImage = Instance.new("ImageLabel")
	cashImage.BackgroundTransparency = 1
	cashImage.Image = MiscLists.AssetIdLists.ImageIds.CashImage
	cashImage.Size = UDim2.fromScale(0.1, 0.1)
	cashImage.Position = cashImagePos
	local ratioConstraint = Instance.new("UIAspectRatioConstraint")
	ratioConstraint.AspectRatio = 1
	ratioConstraint.Parent = cashImage
	cashImage.Parent = ScreenGui

	--[[task.spawn(function()
		--play sound
		local sound = Instance.new("Sound")
		sound.SoundId = MiscLists.AssetIdLists.SoundIds.ClickSound
		sound.RollOffMaxDistance = 25
		sound.Volume = 1
		sound.Parent = ScreenGui
		sound:Play()
		sound.Ended:Wait()
		sound:Destroy()
	end)]]

	local cashImageAbsolutePos = cashImage.AbsolutePosition
	local interval = 50
	local randNum = math.random(25, 150) * (math.sign(math.random(-1, 1) + 0.1))
	for i = 1, interval do
		task.wait(0.5 / interval)
		local pos = cashImageAbsolutePos:Lerp(statsFrame.AbsolutePosition, i / interval)
		cashImage.Position = UDim2.fromOffset(pos.X, pos.Y)
			+ UDim2.fromOffset(math.abs(math.sin(math.rad(180 * (i / interval)))) * randNum, 0)
	end
	cashImage:Destroy()
	return nil
end

function EffectsUtil.Notify() end

return EffectsUtil
