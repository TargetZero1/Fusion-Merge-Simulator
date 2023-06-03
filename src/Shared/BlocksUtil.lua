--!strict
--services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages

--modules
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))

--types
export type BlockTag = "Block"
export type BlockData = {
	BlockId: string,
	UserId: string,
	Level: number,
	IsBonus: boolean,
}

local BlockUtil = {}

-- constants
local BLOCK_SPARKLE_VALUES = {
	4,
	6,
	8,
	12,
	16,
	20,
}

-- references
local BonusBlockParticleFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("BonusParticles")
local BonusBlockTextureFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("BonusSkins")

--private function
function getBonusBlockAssetIndex(blockLevel: number): number
	for i, v in ipairs(BLOCK_SPARKLE_VALUES) do
		if v > blockLevel then
			return math.max(i - 1, 1)
		end
	end
	return #BLOCK_SPARKLE_VALUES
end

function getBonusParticles(blockLevel: number): ParticleEmitter
	local blockIndex = getBonusBlockAssetIndex(blockLevel)
	local blockTemplate = BonusBlockParticleFolder:WaitForChild(tostring(blockIndex))
	return blockTemplate:FindFirstChildOfClass("ParticleEmitter"):Clone()
end

function getBlockTexture(blockLevel: number): string
	local blockIndex = getBonusBlockAssetIndex(blockLevel)
	-- print(blockLevel, " BL -> ", blockIndex)
	local textureTemplate: Texture = BonusBlockTextureFolder:WaitForChild(tostring(blockIndex))
	return textureTemplate.Texture
end

--block data
function BlockUtil.newBlockData(userId: number, level: number?, isBonus: boolean): BlockData
	return {
		BlockId = game:GetService("HttpService"):GenerateGUID(false),
		UserId = tostring(userId),
		Level = level or 1,
		IsBonus = isBonus,
	}
end

function BlockUtil.applyBlockData(block: Model, blockData: BlockData)
	block:SetAttribute("BlockId", tostring(blockData.BlockId))
	block:SetAttribute("Level", blockData.Level)
	block:SetAttribute("UserId", tostring(blockData.UserId))
	block:SetAttribute("IsBonus", blockData.IsBonus)
end

function BlockUtil.getBlockData(block: Model): BlockData
	return {
		BlockId = block:GetAttribute("BlockId") :: string,
		UserId = block:GetAttribute("UserId") :: string,
		Level = block:GetAttribute("Level") :: number,
		IsBonus = block:GetAttribute("IsBonus") :: boolean,
	}
end

function BlockUtil.getBlockModelById(id: string): Model?
	for _, block: Model in pairs(CollectionService:GetTagged("Block" :: BlockTag)) do
		local blockData = BlockUtil.getBlockData(block)
		if blockData.BlockId == id then
			return block
		end
	end
	return nil
end

--block collective data
function BlockUtil.count(player: Player?)
	local count = 0
	for _, block: Model in pairs(CollectionService:GetTagged("Block" :: BlockTag)) do
		if (player and (block:GetAttribute("UserId") == tostring(player.UserId))) or not player then
			count += 1
		end
	end
	return count
end

function BlockUtil.getBlocks(player: Player?): { [number]: BlockData }
	local array = {}
	for _, block: Model in pairs(CollectionService:GetTagged("Block" :: BlockTag)) do
		if (player and (block:GetAttribute("UserId") == tostring(player.UserId))) or not player then
			table.insert(array, BlockUtil.getBlockData(block))
		end
	end
	return array
end

function BlockUtil.clear(player: Player?)
	for _, block: Model in pairs(CollectionService:GetTagged("Block" :: BlockTag)) do
		if (player and (block:GetAttribute("UserId") == tostring(player.UserId))) or not player then
			block:Destroy()
		end
	end
	return nil
end

--effects
function BlockUtil.BlockLeveLVisualUpdate(block: Model, blockData: BlockData?)
	assert(block.PrimaryPart, "Block doesn't have primary part yet!")

	blockData = blockData or BlockUtil.getBlockData(block)
	assert(blockData, "Block not detected!")

	if blockData.IsBonus then
		local particles = getBonusParticles(blockData.Level)
		particles.Parent = block.PrimaryPart
	end

	--create/refer to the surfaceGui parent
	local sgParent = block:FindFirstChild("SurfaceGuiParent") :: Folder or Instance.new("Folder")
	sgParent.Name = "SurfaceGuiParent"
	sgParent.Parent = block

	--clears all texts if there was any before
	sgParent:ClearAllChildren()

	for _, face: Enum.NormalId in pairs(Enum.NormalId:GetEnumItems()) do
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "BlockFace"..face.Name
		surfaceGui.Adornee = block.PrimaryPart
		surfaceGui.Face = face
		surfaceGui.ClipsDescendants = true
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surfaceGui.CanvasSize = Vector2.new(250, 250)
		surfaceGui.Parent = sgParent

		local listLayout = Instance.new("UIListLayout")
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = surfaceGui
		listLayout.Padding = UDim.new(0, 0)
		listLayout.FillDirection = Enum.FillDirection.Horizontal

		local textLabel = Instance.new("TextLabel")
		textLabel.Font = Enum.Font.Arcade
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = false
		textLabel.TextSize = 90
		textLabel.LayoutOrder = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextStrokeTransparency = 0.5
		textLabel.AutomaticSize = Enum.AutomaticSize.XY
		textLabel.Size = UDim2.fromScale(0, 0)
		textLabel.Text = if blockData.IsBonus
			then tostring(blockData.Level)
			else FormatUtil.formatNumber(MiscLists.Limits.BlockNumberOnLevel[blockData.Level])
		textLabel.Parent = surfaceGui

		if blockData.IsBonus then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Image = "rbxassetid://12809225949"
			imageLabel.BackgroundTransparency = 1
			imageLabel.LayoutOrder = 2
			imageLabel.Size = UDim2.fromOffset(70, 70)
			imageLabel.Parent = surfaceGui
		end
	end

	local textureId = MiscLists.AssetIdLists.TextureIds["BlockLevel" .. tostring(blockData.Level)] :: string?
	if blockData.IsBonus then
		textureId = getBlockTexture(blockData.Level)
	end

	for _, v: Texture in pairs(block:GetDescendants() :: { [number]: any }) do
		if v:IsA("Texture") then
			v:Destroy()
		end
	end
	for _, face in pairs(Enum.NormalId:GetEnumItems()) do
		if textureId then
			local texture = Instance.new("Texture")
			texture.Texture = textureId
			texture.Face = face
			texture.Parent = block.PrimaryPart
		end
	end
	--[[for _, v: Texture in pairs(block:GetDescendants() :: { [number]: any }) do
		if v:IsA("Texture") and textureId then
			v.Texture = textureId
		end
		--[[if (1 % (level % MAX_LEVEL_REMAINDER)) == 0 then
				v.Texture = MiscLists.AssetIdLists.TextureIds.BlockLevel1
			elseif (2 % (level % MAX_LEVEL_REMAINDER)) == 0 then
				v.Texture = MiscLists.AssetIdLists.TextureIds.BlockLevel2
			elseif (3 % (level % MAX_LEVEL_REMAINDER)) == 0 then
				v.Texture = MiscLists.AssetIdLists.TextureIds.BlockLevel3
			elseif (MAX_LEVEL_REMAINDER % (level % MAX_LEVEL_REMAINDER)) == 0 then
				v.Texture = MiscLists.AssetIdLists.TextureIds.BlockLevel4
			end
		end]]
	--end
	return nil
end

return BlockUtil
