--!strict
-- Services
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local Assets = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"))

-- Types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type GamepassData = {
	Texture: string,
	Id: number,
	Name: string,
	Color: Color3,
	Price: number,
}
-- Constants
local PADDING_PX = 10
local GAME_PASS_DATA = {
	{
		Texture = Assets.Texture.Gamepass.Icon.AutoClick,
		Id = 131415688,
		Name = "Auto Click",
		Color = Color3.fromRGB(107, 50, 124),
		Price = 1,
	},
	{
		Texture = Assets.Texture.Gamepass.Icon.AutoHatch,
		Id = 134335046,
		Name = "Auto Hatch",
		Color = Color3.fromRGB(33, 84, 185),
		Price = 1,
	},
	{
		Texture = Assets.Texture.Gamepass.Icon.DoubleCash,
		Id = 0,
		Name = "2x Cash",
		Color = Color3.fromRGB(61, 122, 61),
		Price = 1,
	},
	{
		Texture = Assets.Texture.Gamepass.Icon.DoublePassiveCash,
		Id = 131415468,
		Name = "2x Passive Cash",
		Color = Color3.fromRGB(0, 104, 113),
		Price = 1,
	},
	-- {
	-- 	Texture = Assets.Texture.Gamepass.Icon.Lucky,
	-- 	Id = 131414952,
	-- 	Name = "Lucky",
	-- 	Color = Color3.fromRGB(75, 151, 75),
	-- 	Price = 1,
	-- },
	-- {
	-- 	Texture = Assets.Texture.Gamepass.Icon.SuperLucky,
	-- 	Id = 131415099,
	-- 	Name = "Super Lucky",
	-- 	Color = Color3.fromRGB(75, 151, 75),
	-- 	Price = 1,
	-- },
	{
		Texture = Assets.Texture.Gamepass.Icon.TripleHatch,
		Id = 134335317,
		Name = "Triple Hatch",
		Color = Color3.fromRGB(151, 0, 0),
		Price = 1,
	},
} :: { [number]: GamepassData }
-- Variables
-- References
-- Class

function getButton(data: GamepassData, backgroundColor: Color3, onClick: (GamepassData) -> nil)
	local maid = Maid.new()
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local textColor = LegibilityUtil(Color3.new(1, 1, 1), data.Color)

	local button = _new("ImageButton")({
		BackgroundColor3 = data.Color,
		Name = "GamepassButton",
		Image = "",
		AutoButtonColor = true,
		[_ON_EVENT("Activated")] = function()
			onClick(data)
		end,
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = UDim.new(0, 6),
			}),
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
				Transparency = 0,
				Color = LegibilityUtil(Color3.new(0, 0, 0), backgroundColor),
			}),
			_new("UIGradient")({
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(1, 0, 1)),
					ColorSequenceKeypoint.new(0.8, Color3.fromHSV(1, 0, 0.9)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 0, 0.8)),
				}),
				Rotation = 45,
				Transparency = NumberSequence.new(0),
			}),
			_new("ImageLabel")({
				Name = "Icon",
				Image = data.Texture,
				ScaleType = Enum.ScaleType.Fit,
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				BackgroundTransparency = 0.8,
				Size = UDim2.fromScale(0.3, 0.3),
				[_CHILDREN] = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
				},
			}),
			_new("Frame")({
				Name = "Info",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.65, 1),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				[_CHILDREN] = {
					_new("TextLabel")({
						Name = "Name",
						Font = Enum.Font.Cartoon,
						BackgroundTransparency = 1,
						Text = "<b>" .. string.upper(data.Name) .. "</b>",
						RichText = true,
						TextWrapped = true,
						TextColor3 = textColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0),
					}),
					_new("TextLabel")({
						Name = "Price",
						Font = Enum.Font.Cartoon,
						BackgroundTransparency = 1,
						TextColor3 = textColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
						Text = "<b>R$ " .. tostring(data.Price) .. "</b>",
						TextWrapped = false,
						TextScaled = true,
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0.5, 1),
						AnchorPoint = Vector2.new(0.5, 1),
					}),
				},
			}),
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
		},
	})

	maid:GiveTask(button.Destroying:Connect(function()
		maid:Destroy()
	end))

	return button
end

return function(surfacePart: Part?): Frame
	local maid = Maid.new()
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

	local backgroundColor = Color3.new(1, 1, 1)
	if surfacePart then
		backgroundColor = surfacePart.Color
	end

	local AbsoluteSize = _Value(Vector2.new(0, 0))

	local frame = _new("Frame")({
		Name = "Menu",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		[_CHILDREN] = {
			_new("UIGridLayout")({
				CellPadding = _Computed(function(absSize: Vector2)
					return UDim2.fromOffset(PADDING_PX, PADDING_PX)
				end, AbsoluteSize),
				CellSize = _Computed(function(absSize: Vector2)
					return UDim2.fromOffset(
						(absSize.X - 2 * PADDING_PX - PADDING_PX * 2) / 2,
						(absSize.Y - 2 * PADDING_PX - PADDING_PX * 3) / math.ceil(#GAME_PASS_DATA / 2)
					)
				end, AbsoluteSize),
				FillDirection = Enum.FillDirection.Horizontal,
				FillDirectionMaxCells = 3,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				StartCorner = Enum.StartCorner.TopLeft,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			_new("UIPadding")({
				PaddingTop = UDim.new(0, PADDING_PX),
				PaddingBottom = UDim.new(0, PADDING_PX),
				PaddingLeft = UDim.new(0, PADDING_PX),
				PaddingRight = UDim.new(0, PADDING_PX),
			}),
		},
	}) :: Frame

	AbsoluteSize:Set(frame.AbsoluteSize)

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		AbsoluteSize:Set(frame.AbsoluteSize)
	end))

	local function onButtonClick(data: GamepassData)
		if data.Id == 0 then
			return
		end
		MarketplaceService:PromptGamePassPurchase(game:GetService("Players").LocalPlayer, data.Id)
	end

	for i, data in ipairs(GAME_PASS_DATA) do
		local button = maid:GiveTask(getButton(data, backgroundColor, onButtonClick))
		button.Parent = frame
	end

	if surfacePart then
		_new("SurfaceGui")({
			Name = "GamepassMenu",
			Parent = if RunService:IsRunning()
				then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
				else game:GetService("StarterGui"),
			Brightness = 1,
			LightInfluence = 0,
			ResetOnSpawn = false,
			Face = Enum.NormalId.Front,
			Adornee = surfacePart,
			PixelsPerStud = 50,
			SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
			[_CHILDREN] = {
				frame,
			},
		})
	end

	maid:GiveTask(frame.Destroying:Connect(function()
		maid:Destroy()
	end))

	return frame
end
