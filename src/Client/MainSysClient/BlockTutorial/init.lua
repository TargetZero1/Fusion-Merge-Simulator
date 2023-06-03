--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
--modules
local BlocksUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BlocksUtil"))
--types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type Signal = Signal.Signal
--constants
local BACKGROUND_COLOR = Color3.fromRGB(200,200,200)
local PRIMARY_COLOR = Color3.fromRGB(255, 255, 255)
--local functions
local function getViewportFrame(maid : Maid, model : Model, text : string, pos : UDim2, size : UDim2)
    assert(model.PrimaryPart)

    local _fuse = ColdFusion.fuse(maid)
	local _new = ColdFusion.new
	local _import = ColdFusion.import
	local _mount = ColdFusion.mount

	local _Value = ColdFusion.Value
	local _Computed = ColdFusion.Computed

	local _CHILDREN = ColdFusion.CHILDREN
	local _ON_EVENT = ColdFusion.ON_EVENT
	local _ON_PROPERTY = ColdFusion.ON_PROPERTY


    return  _new("ViewportFrame")({
        BackgroundTransparency = 1,
        Position = pos,
        Size = size,
        CurrentCamera = _new("Camera")({
            FieldOfView = 20,
            CFrame = CFrame.lookAt(model.PrimaryPart.Position + (model.PrimaryPart.CFrame.LookVector + model.PrimaryPart.CFrame.RightVector)*12, model.PrimaryPart.Position)
        }),
        [_CHILDREN] = {
            _new("UIStroke")({
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            }),
            _new("WorldModel")({
                [_CHILDREN] = {
                    model
                }    
            }),
            _new("TextLabel")({
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255,255,255),
                Text = text
            })
        }
    })    
    
end
   

return function(maid : Maid)
	local _fuse = ColdFusion.fuse(maid)
	local _new = ColdFusion.new
	local _import = ColdFusion.import
	local _mount = ColdFusion.mount

	local _Value = ColdFusion.Value
	local _Computed = ColdFusion.Computed

	local _CHILDREN = ColdFusion.CHILDREN
	local _ON_EVENT = ColdFusion.ON_EVENT
	local _ON_PROPERTY = ColdFusion.ON_PROPERTY

    local model = maid:GiveTask(ReplicatedStorage.Assets.ObjectModels.TypeA:Clone())
    local model2 = maid:GiveTask(ReplicatedStorage.Assets.ObjectModels.TypeA:Clone())

    BlocksUtil.BlockLeveLVisualUpdate(model, BlocksUtil.newBlockData(game:GetService("Players").LocalPlayer.UserId, 1, false))
    BlocksUtil.BlockLeveLVisualUpdate(model2, BlocksUtil.newBlockData(game:GetService("Players").LocalPlayer.UserId, 2, false))

    local out = maid:GiveTask(_new("Frame")({
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        [_CHILDREN] = {
            _new("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            _new("UIAspectRatioConstraint")({
                AspectRatio = 2
            }),

            _new("TextLabel")({
                Name = "TutorialText",
                LayoutOrder = 1,
                Size = UDim2.fromScale(1, 0.25),
                Font = Enum.Font.Cartoon,
                Text = "Bounce blocks together to MERGE",
                TextColor3 = PRIMARY_COLOR,
                TextStrokeTransparency = 0.7,
                TextScaled = true,
                BackgroundTransparency = 1,
            }),
            _new("Frame")({
                Name = "DisplayFrame",
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.75),
                [_CHILDREN] = {
                    _new("UIListLayout")({
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }),
                    _new("Frame")({
                        Name = "TwoBlocksVisual",
                        LayoutOrder = 1,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.33, 1),
                        [_CHILDREN] = {
                            getViewportFrame(maid, model:Clone(), "1", UDim2.fromScale(0, 0), UDim2.fromScale(0.5, 0.5)),
                            getViewportFrame(maid, model:Clone(), "1", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.5))
                        }
                    }),
                    _new("Frame")({
                        LayoutOrder = 2,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.25, 1),
                        [_CHILDREN] = {
                            _new("ImageLabel")({
                                Name = "Image",
                                Size = UDim2.fromScale(1, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0, 0.25),
                                Image = "rbxassetid://6583628103",
                                Rotation = 90,
                                [_CHILDREN] = {
                                    _new("UIAspectRatioConstraint")({
                                        AspectRatio = 1
                                    })
                                }
                            }),
                            
                        }   
                    }),
                    _new("Frame")({
                        LayoutOrder = 3,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0.33, 1),
                        [_CHILDREN] = {
                            getViewportFrame(maid, model2:Clone(), "2", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)),
                        }
                    }),
                    --[[_new("")({

                    })]]
                }
            })
        }
    }))
    return out
end