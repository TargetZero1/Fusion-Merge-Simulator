--!strict
-- Services
local RunService = game:GetService("RunService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
-- Constants
local BACKGROUND_COLOR = Color3.fromRGB(170, 179, 194)
local BASE_TEXT_SIZE = 16 * if RunService:IsRunning() then 2 else 1
local BASE_PADDING = UDim.new(0, 4)
local TEXT_FONT = Enum.Font.Cartoon
local GOAL_TEXT_COLOR = Color3.new(1, 1, 1)

-- Variables
-- References
-- Class

--Types
type List<V> = TableUtil.List<V>
type Dict<K, V> = TableUtil.Dict<K, V>
type Maid = Maid.Maid
type Signal = Signal.Signal
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>

-- Format of the data supplied for each user on the leaderboard
export type LeaderboardEntry = {
	Text: string,
	Value: number,
	Rank: number,
	Name: string,
	UserId: number,
}

-- Private function
function getListEntry(
	entry: LeaderboardEntry,
	maid: Maid,
	backgroundColor: Color3,
	frame: Instance
): Frame
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

	local pos = _Value(UDim2.fromScale(1, 0))

	local entryFrameContent: Frame = _new("Frame")({
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Position = _Computed(function(position)
			return position
		end, pos):Tween(0.25),
		LayoutOrder = entry.Rank,
		BackgroundColor3 = backgroundColor,
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = BASE_PADDING,
				PaddingTop = BASE_PADDING,
				PaddingLeft = BASE_PADDING,
				PaddingRight = BASE_PADDING,
			}),
			_new("UICorner")({
				CornerRadius = BASE_PADDING,
			}),
			_new("TextLabel")({
				Name = "Value",
				ZIndex = 10,
				Text = entry.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				BackgroundTransparency = 0.15,
				Font = TEXT_FONT,
				RichText = true,
				TextColor3 = LegibilityUtil(GOAL_TEXT_COLOR, backgroundColor),
				TextSize = BASE_TEXT_SIZE,
				TextScaled = false,
				BackgroundColor3 = backgroundColor,
				LayoutOrder = 3,
			}),
			_new("Frame")({
				Name = "LabelContainer",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = BASE_PADDING,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					_new("TextLabel")({
						Name = "Rank",
						Text = tostring(entry.Rank),
						Size = UDim2.fromOffset(BASE_TEXT_SIZE * 1.5, BASE_TEXT_SIZE),
						BackgroundTransparency = 1,
						Font = TEXT_FONT,
						TextColor3 = LegibilityUtil(GOAL_TEXT_COLOR, backgroundColor),
						TextSize = BASE_TEXT_SIZE,
						LayoutOrder = 1,
					}),
					_new("ImageLabel")({
						Name = "Icon",
						Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(entry.UserId) .. "&w=150&h=150",
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(BASE_TEXT_SIZE * 1.25, BASE_TEXT_SIZE * 1.25),
						LayoutOrder = 2,
					}),
					_new("TextLabel")({
						Name = "Username",
						Text = entry.Name,
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = TEXT_FONT,
						TextColor3 = LegibilityUtil(GOAL_TEXT_COLOR, backgroundColor),
						TextSize = BASE_TEXT_SIZE,
						LayoutOrder = 3,
					}),
				},
			}),
		},
	}) :: any

	local entryFrame = _new("Frame")({
		Parent = frame,
		BackgroundTransparency = 1,
		LayoutOrder = entry.Rank,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		[_CHILDREN] = {
			entryFrameContent
		}
	}) :: Frame
	pos:Set(UDim2.fromScale(0, 0))
	return entryFrame
end

-- Constructs new leaderboard object
return function(
	title: string,
	buttonBackgroundColor: Color3,
	Data: State<Dict<string, LeaderboardEntry>>,
	PlayerData: State<LeaderboardEntry>
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

	local topTextSize = BASE_TEXT_SIZE * 2
	local bottomTextSize = BASE_TEXT_SIZE * 1.5
	local canvasReduction = topTextSize + bottomTextSize + BASE_PADDING.Offset * 4

	local inst: Frame = _new("Frame")({
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = BASE_PADDING,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			_new("TextLabel")({
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, topTextSize),
				Text = FormatUtil.bold(title:upper()),
				RichText = true,
				TextColor3 = LegibilityUtil(GOAL_TEXT_COLOR, BACKGROUND_COLOR),
				TextScaled = false,
				Font = TEXT_FONT,
				TextSize = topTextSize,
			}),
			_new("TextLabel")({
				LayoutOrder = 3,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, bottomTextSize),
				Text = _Computed(function(playerData: LeaderboardEntry)
					return "You: " .. playerData.Text
				end, PlayerData),
				RichText = true,
				TextColor3 = LegibilityUtil(GOAL_TEXT_COLOR, BACKGROUND_COLOR),
				TextScaled = false,
				Font = TEXT_FONT,
				TextSize = bottomTextSize,
			}),
		},
	}) :: any

	local scrollingFrame = _new("ScrollingFrame")({
		Parent = inst,
		LayoutOrder = 1,
		ScrollBarThickness = BASE_TEXT_SIZE,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ScrollBarImageColor3 = LegibilityUtil(GOAL_TEXT_COLOR, BACKGROUND_COLOR),
		Size = UDim2.new(1, 0, 1, -canvasReduction),
		[_CHILDREN] = {
			_new("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 0),
				PaddingTop = UDim.new(0, 0),
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, BASE_TEXT_SIZE),
			}),
		},
	})

	local canvas: Frame = _new("Frame")({
		Parent = scrollingFrame,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = BASE_PADDING,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			_new("UIPadding")({
				PaddingBottom = BASE_PADDING,
				PaddingTop = BASE_PADDING,
				PaddingLeft = BASE_PADDING,
				PaddingRight = BASE_PADDING,
			}),
		},
	}) :: any

	local computedMaid = maid:GiveTask(Maid.new())
	_Computed(function(data)
		computedMaid:DoCleaning()
		task.spawn(function()
			for key, _ in pairs(data) do
				local entry = Data:Get()[key]
				computedMaid:GiveTask(getListEntry(entry, computedMaid, buttonBackgroundColor, canvas))
				task.wait(0.15)
			end
		end)
		
		return nil
	end, Data)
	--[[Data:ForKeys(function(key: string, maid: Maid)
		local entry = Data:Get()[key]
		getListEntry(entry, maid, buttonBackgroundColor, canvas)
		task.wait(0.1)
		return key
	end)]]

	maid:GiveTask(inst.Destroying:Connect(function()
		maid:Destroy()
	end))


	return inst
end
