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
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))
local BlocksUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BlocksUtil"))

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

type AchievementInfo = {
    Text : string,
    Image : string | Model
}
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

--module
return function(
    achievementInfo : AchievementInfo,
    waitTime : number ?
)
    local maid = Maid.new()
    local _fuse = ColdFusion.fuse(maid)
    
    local _new = _fuse.new
    local _import = _fuse.import
    local _mount = _fuse.mount

    local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _OUT = _fuse.OUT
	local _REF = _fuse.REF
	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT
	local _ON_PROPERTY = _fuse.ON_PROPERTY

    --FXes
    local Position = _Value(UDim2.new(0,0,1,0))
    local BackgroundTransp = _Value(1)
    local RotationFX = _Value(0)
    
    local camera = if typeof(achievementInfo.Image) == "Instance" and achievementInfo.Image.PrimaryPart then _new("Camera")({
        CFrame = CFrame.lookAt(achievementInfo.Image.PrimaryPart.Position + (achievementInfo.Image.PrimaryPart.CFrame.LookVector + achievementInfo.Image.PrimaryPart.CFrame.RightVector + achievementInfo.Image.PrimaryPart.CFrame.UpVector)*5,  achievementInfo.Image.PrimaryPart.Position)
    }) else nil

    if typeof(achievementInfo.Image) == "Instance" then
        --BlocksUtil.BlockLeveLVisualUpdate(achievementInfo.Image, BlocksUtil.newBlockData(game:GetService("Players").LocalPlayer.UserId, 1, false))
    end

    local sunraysFX = _new("ImageLabel")({
        Name = "SunraysFX",
        ZIndex = -6,
        Rotation = _Computed(function(rot)
            return rot
        end, RotationFX):Tween(2.5, Enum.EasingStyle.Linear),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5626201475",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(2, 2)
    })

    local out = maid:GiveTask(_new("Frame")({
        Name = "AchievementFrame",
        Position = _Computed(function(pos) 
            return pos
        end, Position):Tween(0.6),
        Size = UDim2.fromScale(1, 0.95),
        BackgroundTransparency = 1,

        [_CHILDREN] = {
            _new("UIListLayout")({
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center

            }),
            _new("Frame")({
                Size = UDim2.fromScale(1, 0.35),
                BackgroundTransparency = 1,
                [_CHILDREN] = {
                    _new("UIListLayout")({
                        Padding = UDim.new(0, 15),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                        
                    _new("ImageLabel")({
                        Name = "Picture",
                        BackgroundTransparency = 1,
                        LayoutOrder = 1,
                        Size = UDim2.new(0.73,0,0.73,0),
                        Image = if typeof(achievementInfo.Image) == "string" then achievementInfo.Image else nil,
                        [_CHILDREN] = {
                            _new("UIAspectRatioConstraint")({}),
                            sunraysFX,
                            _new("ViewportFrame")({  
                                Name = "Picture",
                                BackgroundTransparency = 1,
                                LayoutOrder = 1,
                                Size = UDim2.new(1,0,1,0),
                                CurrentCamera = camera,
                                [_CHILDREN] = {
                                    _new("UIAspectRatioConstraint")({}),
                                    _new("WorldModel")({
                                        [_CHILDREN] = {
                                            
                                            if typeof(achievementInfo.Image) == "Instance" then  achievementInfo.Image else nil
                                        }
                                    }),
                                }
                            })
                        }
                    }) 
                
                        
                    , 
                    _new("TextLabel")({
                        Name = "Achievement Text",
                        BackgroundTransparency = _Computed(function(bg)
                            return bg
                        end, BackgroundTransp):Tween((waitTime or 2.5)*0.5, nil, nil, nil, true),
                        Size = UDim2.fromScale(1, 0.2),
                        LayoutOrder = 2,
                        BackgroundColor3 = SECONDARY_COLOR,  
                        Font = Enum.Font.Arcade,
                        RichText = true,  
                        TextSize = TEXT_SIZE,
                        TextStrokeTransparency = 0.95,
                        TextColor3 = TERTIARY_COLOR,
                        TextStrokeColor3 = PRIMARY_COLOR,
                        Text = "<b>" .. achievementInfo.Text ..  "</b>"
                    }),
                }
            })
        }
    }))
    Position:Set(UDim2.new())
    BackgroundTransp:Set(0.5)
    RotationFX:Set(5*(waitTime or 2.5)) 
    task.spawn(function()
        task.wait(waitTime or 2.5)
        Position:Set(UDim2.new(0,0,-1,0))
        task.wait(1)
        maid:Destroy()
    end)
    return out
end