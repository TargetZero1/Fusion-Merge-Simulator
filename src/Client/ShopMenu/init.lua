--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
-- Packages
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
-- Modules
local ExitButton = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ExitButton"))
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))
-- Types
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type Maid = Maid.Maid
type Signal = Signal.Signal
type ItemData = {
	Price: number,
	Icon: string,
	Color: Color3,
	Text: string,
	Id: number,
	IsGamepass: boolean,
	ExitOnPurchase: boolean,
}
-- Constants
local BUTTON_HEIGHT = 150
local BACKGROUND_COLOR = Color3.fromHSV(0, 0, 0.9)
-- Variables
-- References
-- Private functions
function getPurchaseButton(itemData: ItemData, layoutOrder: number, Size: ValueState<UDim2>, exitSignal: Signal)
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

	local textColor = LegibilityUtil(Color3.new(1, 1, 1), itemData.Color)

	-- if itemData.ExitOnPurchase then
	-- 	local function handlePromptFinish(userId: number, assetId: number, success: boolean)
	-- 		if userId == game:GetService("Players").LocalPlayer.UserId and assetId == itemData.Id then
	-- 			exitSignal:Fire()
	-- 		end
	-- 	end
	-- 	if itemData.IsGamepass then
	-- 		maid:GiveTask(MarketplaceService.PromptGamePassPurchaseFinished:Connect(handlePromptFinish))
	-- 	else
	-- 		maid:GiveTask(MarketplaceService.PromptProductPurchaseFinished:Connect(handlePromptFinish))
	-- 	end
	-- end

	local out = _new("ImageButton")({
		BackgroundColor3 = itemData.Color,
		Name = "Button",
		Size = Size,
		Image = "",
		AutoButtonColor = true,
		[_ON_EVENT("Activated")] = function()
			if itemData.ExitOnPurchase then
				exitSignal:Fire()
				task.wait(1)
			end
			if itemData.IsGamepass then
				MarketplaceService:PromptGamePassPurchase(game:GetService("Players").LocalPlayer, itemData.Id)
			else
				MarketplaceService:PromptProductPurchase(game:GetService("Players").LocalPlayer, itemData.Id)
			end
		end,
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = UDim.new(0, 6),
			}),
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
				Transparency = 0,
				Color = LegibilityUtil(Color3.new(0, 0, 0), itemData.Color),
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
				Image = itemData.Icon,
				ScaleType = Enum.ScaleType.Fit,
				Position = UDim2.fromScale(0.8, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				[_CHILDREN] = {
					_new("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
				},
			}),
			_new("Frame")({
				Name = "Info",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.4),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				[_CHILDREN] = {
					_new("TextLabel")({
						Name = "Name",
						Font = Enum.Font.Cartoon,
						BackgroundTransparency = 1,
						Text = "<b>" .. string.upper(itemData.Text) .. "</b>",
						RichText = true,
						TextWrapped = true,
						TextColor3 = textColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						Size = UDim2.fromScale(0.6, 2.8),
						Position = UDim2.fromScale(0, -2),
						AnchorPoint = Vector2.new(0, 0),
					}),
					_new("TextLabel")({
						Name = "Price",
						Font = Enum.Font.Cartoon,
						BackgroundTransparency = 1,
						TextColor3 = textColor,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
						Text = "<b>R$ " .. tostring(itemData.Price) .. "</b>",
						TextWrapped = false,
						TextScaled = false,
						Size = UDim2.fromScale(0.5, 2),
						Position = UDim2.fromScale(0.3, 2.2),
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
	}) :: Frame

	return out
end

function getPurchaseFrame(title: string, layoutOrder: number, items: { [number]: ItemData }, exitSignal: Signal)
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

	local itemFrame = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = 10,
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		},
	})

	local Size = _Value(UDim2.fromOffset(1.2 * BUTTON_HEIGHT, BUTTON_HEIGHT * 2 / #items))

	for i, itemData in ipairs(items) do
		local button = maid:GiveTask(getPurchaseButton(itemData, i, Size, exitSignal))
		button.Parent = itemFrame
	end

	local out = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0,
		LayoutOrder = layoutOrder,
		[_CHILDREN] = {
			_new("TextLabel")({
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				TextSize = 25,
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				TextColor3 = LegibilityUtil(Color3.new(0, 0, 0), BACKGROUND_COLOR),
				Font = Enum.Font.Cartoon,
				RichText = true,
				Text = "<b>" .. title .. "</b>",
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingTop = UDim.new(0, 2),
						PaddingBottom = UDim.new(0, 2),
						PaddingRight = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),
				},
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			itemFrame,
		},
	}) :: Frame

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end

local function getProductInfo(gamePassId : number, infoType : Enum.InfoType) : {
	PriceInRobux: number,
	IconImageAssetId: number,
	Name: string
}
	local productInfo
	local s, _ = pcall(function()
		productInfo =  MarketplaceService:GetProductInfo(
			gamePassId,
			infoType
		)
	end)
	if s then
		return productInfo
	end
	return {
		PriceInRobux = 0,
		IconImageAssetId = 0,
		Name = "content error",
	}
end

-- Class
return function(Visible: ValueState<boolean>, OnBack: Signal?, target: GuiBase): Frame
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

	--loading
	_new("TextLabel")({
		Parent = target,
		ZIndex = -10,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 25,
		TextColor3 = BACKGROUND_COLOR,
		Text = "Please Wait...",
	})

	local RateOfPassiveMoney2xProductInfo = getProductInfo(MiscLists.GamePassIds.RateOfPassiveMoney2x, Enum.InfoType.GamePass)
	local RateOfGems2xProductInfo = getProductInfo(MiscLists.GamePassIds.RateOfGems2x, Enum.InfoType.GamePass)
	local LuckyProductInfo = getProductInfo(MiscLists.GamePassIds.Lucky, Enum.InfoType.GamePass)
	local SuperLuckyProductInfo = getProductInfo(MiscLists.GamePassIds.SuperLucky, Enum.InfoType.GamePass)

	local Add50Gems = getProductInfo(MiscLists.DeveloperProductIds.Add50Gems, Enum.InfoType.Product)
	local Add150Gems = getProductInfo(MiscLists.DeveloperProductIds.Add150Gems, Enum.InfoType.Product)
	local Add500Gems = getProductInfo(MiscLists.DeveloperProductIds.Add500Gems, Enum.InfoType.Product)

	local Drop25Blocks = getProductInfo(MiscLists.DeveloperProductIds.Drop25Blocks, Enum.InfoType.Product)
	local Drop50Blocks = getProductInfo(MiscLists.DeveloperProductIds.Drop50Blocks, Enum.InfoType.Product)
	local Drop100Blocks = getProductInfo(MiscLists.DeveloperProductIds.Drop100Blocks, Enum.InfoType.Product)

	local AddLevel5Cat = getProductInfo(MiscLists.DeveloperProductIds.AddLevel5Cat, Enum.InfoType.Product)
	local AddLevel5Dog = getProductInfo(MiscLists.DeveloperProductIds.AddLevel5Dog, Enum.InfoType.Product)
	local AddLevel5Mouse = getProductInfo(MiscLists.DeveloperProductIds.AddLevel5Mouse, Enum.InfoType.Product)

	local exitSignal = maid:GiveTask(Signal.new())

	local main = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = Visible,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.4, 0.7),
		BackgroundTransparency = 0,
		LayoutOrder = 5,
		BackgroundColor3 = BACKGROUND_COLOR,
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 40),
				PaddingLeft = UDim.new(0, 40),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			getPurchaseFrame("Passes", 4, {
				{
					Price = RateOfPassiveMoney2xProductInfo.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						RateOfPassiveMoney2xProductInfo.IconImageAssetId
					), --Assets.Texture.Gamepass.Icon.AutoClick,
					Color = MiscLists.ColorLists.ShopMenu.DoublePassiveMoney, --Color3.fromHSV(math.random(), 0.5, 1),
					Text = RateOfPassiveMoney2xProductInfo.Name,
					Id = MiscLists.GamePassIds.RateOfPassiveMoney2x,
					IsGamepass = true,
					ExitOnPurchase = false,
				},
				{
					Price = RateOfGems2xProductInfo.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						RateOfGems2xProductInfo.IconImageAssetId
					), --Assets.Texture.Gamepass.Icon.AutoClick,
					Color = MiscLists.ColorLists.ShopMenu.DoubleGems,
					Text = RateOfGems2xProductInfo.Name,
					Id = MiscLists.GamePassIds.RateOfGems2x,
					IsGamepass = true,
					ExitOnPurchase = false,
				},
				{
					Price = LuckyProductInfo.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						LuckyProductInfo.IconImageAssetId
					), --Assets.Texture.Gamepass.Icon.AutoClick,
					Color = MiscLists.ColorLists.ShopMenu.LuckyPass,
					Text = LuckyProductInfo.Name,
					Id = MiscLists.GamePassIds.Lucky,
					IsGamepass = true,
					ExitOnPurchase = false,
				},
				{
					Price = SuperLuckyProductInfo.PriceInRobux,
					Icon = "rbxassetid://" .. SuperLuckyProductInfo.IconImageAssetId, --Assets.Texture.Gamepass.Icon.AutoClick,
					Color = MiscLists.ColorLists.ShopMenu.SuperLuckyPass,
					Text = SuperLuckyProductInfo.Name,
					Id = MiscLists.GamePassIds.SuperLucky,
					IsGamepass = true,
					ExitOnPurchase = false,
				},
			}, exitSignal),
			getPurchaseFrame("Developer Products", 5, {
				--add gems
				{
					Price = Add50Gems.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Add50Gems.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Add50Gems,
					Text = Add50Gems.Name,
					Id = MiscLists.DeveloperProductIds.Add50Gems,
					IsGamepass = false,
					ExitOnPurchase = false,
				},
				{
					Price = Add150Gems.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Add150Gems.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Add150Gems,
					Text = Add150Gems.Name,
					Id = MiscLists.DeveloperProductIds.Add150Gems,
					IsGamepass = false,
					ExitOnPurchase = false,
				},
				{
					Price = Add500Gems.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Add500Gems.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Add500Gems,
					Text = Add500Gems.Name,
					Id = MiscLists.DeveloperProductIds.Add500Gems,
					IsGamepass = false,
					ExitOnPurchase = false,
				},

				--add blocks
				{
					Price = Drop25Blocks.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Drop25Blocks.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Drop25Blocks,
					Text = Drop25Blocks.Name,
					Id = MiscLists.DeveloperProductIds.Drop25Blocks,
					IsGamepass = false,
					ExitOnPurchase = false,
				},
				{
					Price = Drop50Blocks.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Drop50Blocks.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Drop50Blocks,
					Text = Drop50Blocks.Name,
					Id = MiscLists.DeveloperProductIds.Drop50Blocks,
					IsGamepass = false,
					ExitOnPurchase = false,
				},
				{
					Price = Drop100Blocks.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						Drop100Blocks.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.Drop100Blocks,
					Text = Drop100Blocks.Name,
					Id = MiscLists.DeveloperProductIds.Drop100Blocks,
					IsGamepass = false,
					ExitOnPurchase = false,
				},

				--pets
				{
					Price = AddLevel5Cat.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						AddLevel5Cat.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.AddLevel5Cat,
					Text = AddLevel5Cat.Name,
					Id = MiscLists.DeveloperProductIds.AddLevel5Cat,
					IsGamepass = false,
					ExitOnPurchase = true,
				},
				{
					Price = AddLevel5Dog.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						AddLevel5Dog.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.AddLevel5Dog,
					Text = AddLevel5Dog.Name,
					Id = MiscLists.DeveloperProductIds.AddLevel5Dog,
					IsGamepass = false,
					ExitOnPurchase = true,
				},
				{
					Price = AddLevel5Mouse.PriceInRobux,
					Icon = "rbxassetid://" .. tostring(
						AddLevel5Mouse.IconImageAssetId
					),
					Color = MiscLists.ColorLists.ShopMenu.AddLevel5Mouse,
					Text = AddLevel5Mouse.Name,
					Id = MiscLists.DeveloperProductIds.AddLevel5Mouse,
					IsGamepass = false,
					ExitOnPurchase = true,
				},
			}, exitSignal),
			_new("UICorner")({
				CornerRadius = UDim.new(0, 10),
			}),
			_new("Frame")({
				Name = "Spacer",
				LayoutOrder = 40,
				Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 20)),
				BackgroundTransparency = 1,
			}),
		},
	}) :: Frame

	local out = _new("Frame")({
		Name = "ShopMenu",
		Parent = target,
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = Visible,
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		BackgroundColor3 = BACKGROUND_COLOR,
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {
			_new("TextLabel")({
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				TextSize = 37,
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				TextColor3 = LegibilityUtil(Color3.new(0, 0, 0), BACKGROUND_COLOR),
				Font = Enum.Font.Cartoon,
				RichText = true,
				Text = "<b>Shop</b>",
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 12),
						PaddingLeft = UDim.new(0, 12),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),
				},
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			main,
		},
	}) :: Frame

	if OnBack then
		maid:GiveTask(ExitButton(main, function()
			OnBack:Fire()
		end, Visible))
		maid:GiveTask(exitSignal:Connect(function()
			OnBack:Fire()
		end))
	end

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end
