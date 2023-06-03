--!strict
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

--References
local Player = game:GetService("Players").LocalPlayer

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))

--Dependancies
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local EffectsUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EffectsUtil"))
local CharacterUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterUtil"))
local MiscLists = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MiscLists"))

--types
type Maid = Maid.Maid

--constant
local ON_PROFIT = "OnProfitFx"
local ON_MERGE = "OnMergeFx"
--local ON_BLOCK_KICK = "OnBlockKick"

return {

	init = function(maid: Maid)
		--[[ local function _blockModel(model : Model)
            if model:IsA("Model") and model.PrimaryPart then
                local _maid = Maid.new()
                _maid:GiveTask(model:GetAttributeChangedSignal(ON_PROFIT):Connect(function()
                    print("Profit test")
                    if model:GetAttribute(ON_PROFIT) == true then
                        EffectsUtil.GainProfitFX(
                            model.PrimaryPart.Position,
                            Player.PlayerGui.ScreenGui.Stats.CashFrame,
                            Player.PlayerGui.ScreenGui
                        )
                    end
                end))
                model.Destroying:Connect(function()
                    _maid:Destroy()
                end)
            end
        end]]

		maid:GiveTask(NetworkUtil.onClientEvent(ON_PROFIT, function(blockModel)
            local ScreenGui = Player.PlayerGui:FindFirstChild("ScreenGui") :: ScreenGui
            local Stats = ScreenGui:FindFirstChild("Stats") 
            if ScreenGui and Stats then
                EffectsUtil.GainProfitFX(
                    blockModel.PrimaryPart.Position,
                    Stats:FindFirstChild("CashFrame") :: GuiObject,
                    ScreenGui
                )
            end
		end))

        maid:GiveTask( NetworkUtil.onClientEvent(ON_MERGE, function(blockModel)
            EffectsUtil.OnMergeEffect(blockModel.PrimaryPart)

        end) )

       --[[ maid:GiveTask(NetworkUtil.onClientEvent(ON_BLOCK_KICK, function(blockData : BlocksUtil.BlockData, kickPower : number, kickArc : number)
            local blockModel = BlocksUtil.getBlockModelById(blockData.BlockId)
            if blockModel and blockModel.PrimaryPart then
                local character = Player.Character or Player.CharacterAdded:Wait()
                CharacterUtil.kickObject(character, blockModel.PrimaryPart, kickPower, kickArc)
            end
        end))]]

        --detect kicking
        --kick
		local function initCharacter(char: Model)
			local hrp = char:WaitForChild("HumanoidRootPart")
			assert(char and hrp, "Character not found!")

			local ObjectHolder = char:WaitForChild("ObjectHolder") :: BasePart
			assert(ObjectHolder and ObjectHolder:IsA("BasePart"), "Object holder not detected")

			maid.CharMaid = Maid.new()
			local charMaid = maid.CharMaid :: Maid

			if not charMaid then
				return
			end

            local isCoolDown = false
			charMaid:GiveTask(ObjectHolder.Touched:Connect(function(hit)
				local blockData = if hit.Parent then BlocksUtil.getBlockData(hit.Parent :: Model) else nil
				if blockData and blockData.BlockId and not isCoolDown then
                    isCoolDown = true
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
                    task.wait(MiscLists.Limits.KickCoolDown)
                    isCoolDown = false
                    if blockData.IsBonus then
                        if not BadgeService:UserHasBadgeAsync(Player.UserId, MiscLists.BadgeIds.FoundBonusBlock) then
                            BadgeService:AwardBadge(Player.UserId, MiscLists.BadgeIds.FoundBonusBlock)
                        end
                    end
				end
			end))

            charMaid:GiveTask(char.Destroying:Connect(function()
                charMaid:Destroy()
            end))
		end

		local character = Player.Character or Player.CharacterAdded:Wait()
		initCharacter(character)

		Player.CharacterAdded:Connect(initCharacter)

		--[[for _, model in pairs(CollectionService:GetTagged("Block" :: BlocksUtil.BlockTag)) do
            _blockModel(model)
        end
        maid:GiveTask(CollectionService:GetInstanceAddedSignal("Block" :: BlocksUtil.BlockTag):Connect(function(model)
            _blockModel(model)
            return nil
        end))]]
		--[[local buffer = false
        maid:GiveTask(UserInputService.InputEnded:Connect(function(input: InputObject, _gameProcessed: boolean)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not _gameProcessed and not buffer then
                buffer = true
                local raycastResult = Mouse:GetTarget() :: RaycastResult?
                local blockModel: Model ? = if raycastResult and raycastResult.Instance then raycastResult.Instance.Parent :: Model else nil
                local blockData = if blockModel then BlocksUtil.getBlockData(blockModel) else nil
                if blockModel and blockData and blockData.BlockId then
                    print(blockData.BlockId, " | source :",blockData.BlockId)
                    --sending it to server
                    local success = NetworkUtil.invokeServer(ON_BLOCK_CLICKED, blockData)
                    if success then
                        task.spawn(function()
                            --visual deformation
                            local blockPripart = Assets.ObjectModels.TypeA.PrimaryPart
                            game:GetService("TweenService"):Create(
                                blockModel.PrimaryPart, 
                                TweenInfo.new(
                                    0.1, 
                                    Enum.EasingStyle.Bounce, 
                                    Enum.EasingDirection.InOut, 
                                    0, 
                                    true
                                ), 
                                {
                                    Size = blockPripart.Size*0.9
                                }
                            ):Play()


                            EffectsUtil.GainProfitFX(
                                Player,
                                Player.PlayerGui.ScreenGui,
                                Player.PlayerGui.ScreenGui.Stats.CashFrame
                            )
                        end)
                    end
                end
                task.wait(0.1)
                buffer = false
            end
        end))]]
	end,
}
