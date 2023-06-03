--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))

--types
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
type Signal = Signal.Signal
--constants
local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(255,255,255)
local SECONDARY_COLOR = Color3.fromRGB(100,255,100)
local TERTIARY_COLOR = Color3.fromRGB(250,250,0)

local TEXT_SIZE = 25
--variables
--references
--local functions
local function getButton(maid: Maid, text: string, onClicked: Signal?, bgColor: ValueState<Color3>?)
		local _fuse = ColdFusion.fuse(maid)
		local _new = _fuse.new
		local _mount = _fuse.mount
		local _import = _fuse.import

		local _Value = _fuse.Value
		local _Computed = _fuse.Computed

		local _CHILDREN = _fuse.CHILDREN
		local _ON_EVENT = _fuse.ON_EVENT

		return _new("TextButton")({
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = text,
			TextColor3 = LegibilityUtil(
				Color3.new(1, 1, 1),
				if bgColor then bgColor:Get() else Color3.fromRGB(200, 200, 200)
			),
			AutoButtonColor = true,
			BackgroundColor3 = bgColor,
			BackgroundTransparency = 0.5,
			Font = Enum.Font.Cartoon,
			Size = UDim2.fromScale(0.3, 1),
			TextSize = TEXT_SIZE * 0.8,
			RichText = true,
			[_ON_EVENT("Activated")] = function()
				if onClicked then
					onClicked:Fire()
				end
			end,
			[_CHILDREN] = {
				_new("UICorner")({}),
			},
		})
end

local function rewardIsClaimed(rewardName : string, claimedRewards : {DailyRewards.ClaimedRewardData})
	local isClaimed = false
	for _, claimedReward in pairs(claimedRewards) do
		if claimedReward.RewardName == rewardName then
			isClaimed = true
			break
		end
	end
	return isClaimed
end

	--module
return function(
	maid : Maid,
	rewardTypes : ValueState<{DailyRewards.RewardType}>,
	claimedRewardsData : ValueState<{DailyRewards.ClaimedRewardData}>,
	isMenuVisible : ValueState<boolean>,
	startTick : ValueState<number>,
	OnRewardClaim : Signal
)
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

	local rewardsFrame =  _new("ScrollingFrame")({
		LayoutOrder = 3,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.75),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0,10),
				PaddingLeft = UDim.new(0,10),
				PaddingRight = UDim.new(0,10),
				PaddingTop = UDim.new(0,10)
			}),
			_new("UIGridLayout")({
				CellSize = UDim2.fromOffset(130, 130),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			
		}
	})    

	local out : GuiObject = _new("Frame")({
		AnchorPoint = Vector2.new(0.5,0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Visible = isMenuVisible,
		[_CHILDREN] = {
			_new("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1.5
			}),
			_new("UICorner")({}),
			_new("TextLabel")({
				Name = "Title",
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				RichText = true,
				Font = Enum.Font.Cartoon,
				Size = UDim2.fromScale(1, 0.15),
				TextColor3 = TERTIARY_COLOR,
				TextStrokeTransparency = 0.5,
				TextScaled = true,
				Text = ("<b>Get FREE rewards for playing</b>"),
				[_CHILDREN] = {
					_new("UITextSizeConstraint"){
					MaxTextSize = 30,
					MinTextSize = 20
					}
				}
			}),
			_new("TextLabel")({
				Name = "ClaimedText",
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				RichText = true,
				Font = Enum.Font.Cartoon,
				Size = UDim2.fromScale(1, 0.1),
				TextColor3 = SECONDARY_COLOR,
				TextStrokeTransparency = 0.5,
				Text = _Computed(function(claimedRewards : {DailyRewards.ClaimedRewardData}, rewards : {DailyRewards.RewardType})

					return (string.format("%s/%s claimed", tostring(#claimedRewards), tostring(#rewards)))
				end, claimedRewardsData, rewardTypes) ,
				TextSize = TEXT_SIZE,
				[_CHILDREN] = {
					_new("UITextSizeConstraint"){
					MaxTextSize = 25,
					MinTextSize = 15
					}
				} 
			}),
			rewardsFrame
		}
	}) :: GuiObject

	rewardTypes:ForPairs(function(k, v : DailyRewards.RewardType, pairMaid)
		local pairFuse = ColdFusion.fuse(pairMaid)
		local _pairNew = pairFuse.new
		local _pairValue = pairFuse.Value
		local _pairComputed = pairFuse.Computed
	
		local _pairCHILDREN = pairFuse.CHILDREN
		local _pairON_EVENT = pairFuse.ON_EVENT


		local isClaimVisible = _Value(false)
		local timeRatio = _pairValue(1)

		local button = _mount(getButton(maid, "")){
			Parent = rewardsFrame,
			LayoutOrder = v.Time, 
			AutoButtonColor = false,
			BackgroundColor3 = TERTIARY_COLOR,
			[_CHILDREN] = {
				_new("TextLabel")({
					BackgroundTransparency = 1,
					Text = v.RewardName,
					TextColor3 = PRIMARY_COLOR,
					Font = Enum.Font.Cartoon,
					TextStrokeTransparency = 0.5,
					ZIndex = 10,
					Size = UDim2.fromScale(1, 0.24),
					TextScaled = true
				}),
				_pairNew("ImageLabel")({
					ZIndex = 1,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = "rbxassetid://13393642916"
				}),
				_pairNew("TextLabel")({
					Name = "ClockDisplay",
					ZIndex = 3,
					Visible = _pairComputed(function(bool : boolean, claimedRewards: {DailyRewards.ClaimedRewardData})
					local isClaimed = rewardIsClaimed(v.RewardName, claimedRewards)
					return if isClaimed then false else not bool 
					end, isClaimVisible, claimedRewardsData),
					RichText = true,
					BackgroundTransparency = 1,
					TextStrokeTransparency = 0.5,
					Size = UDim2.fromScale(1, 1),
					TextColor3 = PRIMARY_COLOR,
					Text = _pairComputed(function(ratio)
					local time = (v.Time - (DateTime.now().UnixTimestamp - startTick:Get()))

					return "<b>" .. NumberUtil.NumberToClock(time) .. "</b>"
					end, timeRatio),
					[_CHILDREN] = {
					_pairNew("UITextSizeConstraint"){
						MaxTextSize = 45,
						MinTextSize = 35
					}
					}
				}),
				_pairNew("Frame")({
					Name = "CountdownVisual",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1
				}),
				_pairNew("TextButton")({
					Name = "ClaimButton",
					RichText = true,
					AutoButtonColor = true,
					BackgroundColor3 = _pairComputed(function(claimedRewards : {DailyRewards.ClaimedRewardData})
					local isClaimed = rewardIsClaimed(v.RewardName, claimedRewards)
					
					return if isClaimed then Color3.fromRGB(50,50,50) else SECONDARY_COLOR 
					end, claimedRewardsData),
					Visible = isClaimVisible,
					AnchorPoint = Vector2.new(0.5,0.5),
					TextColor3 = PRIMARY_COLOR,
					ZIndex = 4,
					Size = UDim2.fromScale(0.8, 0.35),
					Font = Enum.Font.Cartoon,
					Text = _pairComputed(function(claimedRewards : {DailyRewards.ClaimedRewardData})
					local isClaimed = rewardIsClaimed(v.RewardName, claimedRewards)
					
					return if isClaimed then "CLAIMED" else "<b>CLAIM!</b>" 
					end, claimedRewardsData),
					Position = UDim2.fromScale(0.5, 0.8),
					BackgroundTransparency = 0,
					[_pairCHILDREN] = {
					_pairNew("UICorner")({})
					},
					[_pairON_EVENT("Activated")] = function ()
					OnRewardClaim:Fire(v)
					end
				})
			}
		}

		_pairComputed(function(ratio : number, visible : boolean)
			local parent = button:FindFirstChild("CountdownVisual")
			local isClaimed = rewardIsClaimed(v.RewardName, claimedRewardsData:Get())
			
			if parent then
				parent:ClearAllChildren()
				if visible then
					if not isClaimed then
						for deg = - 1 - 90, - (ratio*360) - 90, - 10 do
						_pairNew("Frame")({
							
							Parent = parent,
							BackgroundColor3 = Color3.fromRGB(100,100,100),
							AnchorPoint = Vector2.new(0.5,0.5),
							Size = UDim2.fromScale(0.1, 0.08),
							Position = UDim2.fromScale(math.cos(math.rad(deg))*0.35 + 0.5, math.sin(math.rad(deg))*0.35 + 0.5),
							Rotation = deg
						})
						end
					end
				end
			end
			return nil
		end, timeRatio, isMenuVisible) 
	
		pairMaid:GiveTask(RunService.RenderStepped:Connect(function()
			local offset = DateTime.now().UnixTimestamp - startTick:Get()
			local timeRemaining = (v.Time - (offset))
		
			if timeRemaining <= 0 then
				--pairMaid:Destroy()
				-- print("Enable claim")
				isClaimVisible:Set(true)
			else
				timeRatio:Set((offset)/(offset + timeRemaining))
				isClaimVisible:Set(false)
			end
		end))  
		
		return k, v
	end)

	local exitButton =   maid:GiveTask(ExitButton(out, function()
		isMenuVisible:Set(false)
	end, isMenuVisible))

	print(exitButton)
	return out
end
