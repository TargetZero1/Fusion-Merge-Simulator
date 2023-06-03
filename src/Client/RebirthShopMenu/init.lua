--!strict
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
-- Packages
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))
local PlayerDataType =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PlayerDataType"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))
local RebirthUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RebirthUtil"))

-- Types
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type Maid = Maid.Maid
type Signal = Signal.Signal
type ItemData = {
	PerkState: ValueState<number>,
	Icon: string,
	Color: Color3,
	Perk: PlayerDataType.PerkType,
}
-- Constants
local BUTTON_HEIGHT = 150
local BACKGROUND_COLOR = Color3.fromHSV(0, 0, 0.9)
local BUTTON_COLOR = Color3.fromRGB(5, 129, 47)
local GEM_COLOR = Color3.fromRGB(159, 17, 224)
local ERROR_COLOR = Color3.fromRGB(155, 10, 10)
-- Variables
-- References
-- Private functions
function getPurchaseButton(itemData: ItemData, layoutOrder: number, Size: ValueState<UDim2>, onPerksClicked: Signal)
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

	local out = _new("ImageButton")({
		BackgroundColor3 = itemData.Color,
		Name = "Button",
		Size = Size,
		Image = "",
		AutoButtonColor = true,
		[_ON_EVENT("Activated")] = function()
			onPerksClicked:Fire(itemData.Perk)
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
				Position = UDim2.fromScale(0.9, 0),
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
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				[_CHILDREN] = {
					_new("TextLabel")({
						Name = "Name",
						Font = Enum.Font.Cartoon,
						BackgroundTransparency = 1,
						Text = _Computed(function(level: number)
							local perkType = MiscLists.Limits.Perks[itemData.Perk]
							if perkType and perkType[level + 1] then
								return "<b>" .. string.upper(perkType[level + 1].Text) .. "</b>"
							else
								return "+100%" --.. perkType:Get()
							end
						end, itemData.PerkState),
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
						Text = _Computed(function(level: number): string
							local perkType = MiscLists.Limits.Perks[itemData.Perk]
							if perkType and perkType[level + 1] then
								return "<b>Gem " .. tostring(perkType[level + 1].Gems) .. "</b>"
							end

							return ""
						end, itemData.PerkState),
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
	}) :: Frame

	return out
end

function getPurchaseFrame(
	title: string,
	layoutOrder: number,
	items: { [number]: ItemData },
	gemValue: ValueState<number>,
	onPerksClicked: Signal
)
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
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1.2, 1.4),
		BackgroundTransparency = 1,
		LayoutOrder = 10,
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			_new("UIGridLayout")({
				CellPadding = UDim2.new(0, 10, 0, 10),
				--FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
				CellSize = _Value(UDim2.fromOffset(BUTTON_HEIGHT * 1.5, 2 * BUTTON_HEIGHT / #items)),
			}),
		},
	})

	local Size = _Value(UDim2.fromOffset(BUTTON_HEIGHT, 4 * BUTTON_HEIGHT / #items))

	for i, itemData in ipairs(items) do
		local button = maid:GiveTask(getPurchaseButton(itemData, i, Size, onPerksClicked))
		button.Parent = itemFrame
	end

	local out = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		[_CHILDREN] = {
			_new("Frame")({
				Size = UDim2.fromScale(0.1, 0.08),
				BackgroundTransparency = 1,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = UDim.new(0, 15),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("Frame")({
						Name = "PlayerGemInfo",
						Size = UDim2.fromScale(0.1, 1),
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						AutomaticSize = Enum.AutomaticSize.X,
						[_CHILDREN] = {
							_new("UIListLayout")({
								Padding = UDim.new(0, 5),
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							_new("ImageLabel")({
								Name = "Gem_Icon",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1.2, 1.2),
								--BackgroundColor3 = Color3.new(),
								LayoutOrder = 1,
								Image = "rbxassetid://13081579241",
								[_CHILDREN] = {
									_new("UIAspectRatioConstraint")({}),
								},
							}),
							_new("TextLabel")({
								Name = "GemInfo",
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = 40,
								LayoutOrder = 1,
								Text = gemValue,
							}),
						},
					}),
					_new("TextLabel")({
						Name = "Title",
						AutomaticSize = Enum.AutomaticSize.XY,
						LayoutOrder = 1,
						TextSize = 30,
						BackgroundTransparency = 0.3,
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

-- Class
return function(
	Visible: ValueState<boolean>,

	GemValue: ValueState<number>,
	RebirthValue: ValueState<number>,
	HighestBlockLevel: ValueState<number>,
	CashValue: ValueState<number>,
	PerksState: ValueState<{ [PlayerDataType.PerkType]: number }>,

	OnBack: Signal,
	onRebirthClicked: Signal,
	onPerksClicked: Signal
): Frame
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

	local intPerkStateVal = PerksState:Get()
	local cashPerkState = _Value(if intPerkStateVal then intPerkStateVal["Cash" :: PlayerDataType.PerkType] else 0)
	local gemsPerkState = _Value(if intPerkStateVal then intPerkStateVal["Gems" :: PlayerDataType.PerkType] else 0)
	local petEquipPerkState =
		_Value(if intPerkStateVal then intPerkStateVal["PetEquip" :: PlayerDataType.PerkType] else 0)
	local kickPowerPerkState =
		_Value(if intPerkStateVal then intPerkStateVal["KickPower" :: PlayerDataType.PerkType] else 0)
	local bonusBlocksPerkState =
		_Value(if intPerkStateVal then intPerkStateVal["BonusBlock" :: PlayerDataType.PerkType] else 0)

	_Computed(function(perkStateVal: { [PlayerDataType.PerkType]: number })
		cashPerkState:Set(perkStateVal["Cash" :: PlayerDataType.PerkType])
		gemsPerkState:Set(perkStateVal["Gems" :: PlayerDataType.PerkType])
		petEquipPerkState:Set(perkStateVal["PetEquip" :: PlayerDataType.PerkType])
		kickPowerPerkState:Set(perkStateVal["KickPower" :: PlayerDataType.PerkType])
		bonusBlocksPerkState:Set(perkStateVal["BonusBlock" :: PlayerDataType.PerkType])

		return nil
	end, PerksState)

	local shopFrame = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = Visible,
		BackgroundColor3 = BACKGROUND_COLOR,
		Size = UDim2.fromScale(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0,
		LayoutOrder = 5,
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {
			_new("UICorner")({}),
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 3,
			}),
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 15),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			getPurchaseFrame("GEM SHOP", 4, {
				{
					PerkState = cashPerkState,
					Icon = MiscLists.AssetIdLists.ImageIds.CashPerk,
					Color = MiscLists.ColorLists.RebirthShopMenu.CashPerkOpt,
					Perk = "Cash" :: PlayerDataType.PerkType,
				},
				{
					PerkState = gemsPerkState,
					Icon = MiscLists.AssetIdLists.ImageIds.GemsPerk,
					Color = MiscLists.ColorLists.RebirthShopMenu.GemPerkOpt,
					Perk = "Gems" :: PlayerDataType.PerkType,
				},
				{
					PerkState = petEquipPerkState,
					Icon = MiscLists.AssetIdLists.ImageIds.PetEquip,
					Color = MiscLists.ColorLists.RebirthShopMenu.PetEquipPerkOpt,
					Perk = "PetEquip" :: PlayerDataType.PerkType,
				},
				--{
				--	PerkState = kickPowerPerkState,
				--	Icon = Assets.Texture.Gamepass.Icon.AutoClick,
				--	Color = Color3.fromHSV(math.random(), 0.5, 1),
				--	Perk = "KickPower" :: PlayerDataType.PerkType
				--},
				--{
				--	PerkState = bonusBlocksPerkState,
				--	Icon = Assets.Texture.Gamepass.Icon.AutoClick,
				--	Color = Color3.fromHSV(math.random(), 0.5, 1),
				--	Perk = "BonusBlock" :: PlayerDataType.PerkType

				--},
			}, GemValue, onPerksClicked),

			--_new("Frame")({
			--	Name = "Spacer",
			--	LayoutOrder = 40,
			--	Size = UDim2.new(UDim.new(0,0),UDim.new(0,20)),
			--	BackgroundTransparency = 1,
			--}),
		},
	}) :: Frame

	local OwnsDoubleGemRatePass = _Value(
		MarketplaceService:UserOwnsGamePassAsync(
			game:GetService("Players").LocalPlayer.UserId,
			MiscLists.GamePassIds.RateOfGems2x
		)
	)

	local GemPerkLevel = _Computed(function(perkState: {[PlayerDataType.PerkType]: number})
		return perkState["Gems" :: PlayerDataType.PerkType] or 0
	end, PerksState)

	maid:GiveTask(MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr: Player, gamePassId: string, success: boolean)
		if gamePassId == MiscLists.GamePassIds.RateOfGems2x and success then
			OwnsDoubleGemRatePass:Set(true)
		end
	end))

	local rebirthFrame = _new("Frame")({
		Name = "RebirthFrame",
		BackgroundTransparency = 0,
		BackgroundColor3 = BACKGROUND_COLOR,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {
			_new("UICorner")({}),
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 3,
			}),
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 15),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("TextLabel")({
				Name = "RebirthTitle",
				Font = Enum.Font.Cartoon,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				TextSize = 50,
				RichText = true,
				Text = "<b>REBIRTH</b>",
			}),
			_new("TextLabel")({
				Name = "RebirthDesc",
				Font = Enum.Font.Cartoon,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				TextSize = 25,
				Text = "Rebirthing will reset \n all cash upgrades and \n all block levels. You \n will receive:",
			}),
			_new("Frame")({
				Name = "Gem_Image",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.8, 0.3),
				[_CHILDREN] = {
					_new("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 10),
					}),
					_new("ImageLabel")({
						Name = "GemsDisplay",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.5, 1),
						LayoutOrder = 1,
						Image = "rbxassetid://13081579241",
					}),
					_new("TextLabel")({
						Name = "GemsBonus",
						Font = Enum.Font.Cartoon,
						LayoutOrder = 2,
						AutomaticSize = Enum.AutomaticSize.XY,
						Text = _Computed(function(rebirth: number, highestBlockLevelVal: number, isGemPassOwned: boolean, gemPerkLevel: number)
							print("\nblock", highestBlockLevelVal, "nextRebirthLevel", rebirth+1, "perk", gemPerkLevel, "is pass", isGemPassOwned)
							local gemBonus = RebirthUtil.getRebirthGemRewardFromBlockLevel(
								highestBlockLevelVal,
								rebirth+1,
								gemPerkLevel,
								isGemPassOwned
							)
							print("gem bonus", gemBonus)
							return "+" .. FormatUtil.formatNumber(gemBonus)
						end, RebirthValue, HighestBlockLevel, OwnsDoubleGemRatePass, GemPerkLevel),
						TextColor3 = GEM_COLOR,
						BackgroundTransparency = 1,
						TextSize = 50,
					}),
				},
			}),
			_new("TextButton")({
				Name = "RebirthButton",
				Size = UDim2.fromScale(0.45, 0.15),
				AutoButtonColor = true,
				BackgroundColor3 = _Computed(function(cash: number, rebirth: number)
					local price = MiscLists.Prices.RebirthPrice[rebirth + 1]
						or MiscLists.Prices.RebirthPrice[#MiscLists.Prices.RebirthPrice]
					return if price <= cash then BUTTON_COLOR else ERROR_COLOR
				end, CashValue, RebirthValue):Tween(),
				TextColor3 = LegibilityUtil(Color3.fromRGB(255, 255, 255), BUTTON_COLOR),
				Font = Enum.Font.Cartoon,
				AutomaticSize = Enum.AutomaticSize.XY,
				TextSize = 25,
				Text = _Computed(function(rebirth: number)
					return "$"
						.. FormatUtil.formatNumber(
							MiscLists.Prices.RebirthPrice[rebirth + 1]
								or MiscLists.Prices.RebirthPrice[#MiscLists.Prices.RebirthPrice]
						)
				end, RebirthValue),
				[_CHILDREN] = {
					_new("UICorner")({}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 3,
						Color = Color3.fromRGB(100, 100, 100),
					}),
				},
				[_ON_EVENT("Activated")] = function()
					onRebirthClicked:Fire()
				end,
			}),
		},
	})

	local main = _new("Frame")({
		Visible = Visible,
		AutomaticSize = Enum.AutomaticSize.XY,
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = 5,
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			}),
			_new("UIListLayout")({
				Padding = UDim.new(0, 25),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			--_new("UIAspectRatioConstraint")({
			--	AspectRatio = 1.5
			--}),

			shopFrame,
			rebirthFrame,

			--_new("Frame")({
			--	Name = "Spacer",
			--	LayoutOrder = 40,
			--	Size = UDim2.new(UDim.new(0,0),UDim.new(0,20)),
			--	BackgroundTransparency = 1,
			--}),
			_new("UICorner")({
				CornerRadius = UDim.new(0, 10),
			}),
		},
	}) :: Frame

	local out = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = Visible,
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		BackgroundColor3 = BACKGROUND_COLOR,
		AnchorPoint = Vector2.new(0.5, 0.5),
		[_CHILDREN] = {

			--[[_new("TextLabel")({
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				TextSize = 37,
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(0.9,0.9,0.9),
				TextColor3 = LegibilityUtil(Color3.new(0,0,0), BACKGROUND_COLOR),
				Font = Enum.Font.Cartoon,
				RichText = true,
				Text = "<b>Rebirth</b>",
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingTop = UDim.new(0,4),
						PaddingBottom = UDim.new(0,4),
						PaddingRight = UDim.new(0,12),
						PaddingLeft = UDim.new(0,12),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0,8),
					}),
				},
			}),]]
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
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

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end
