--!strict
-- Services
local RunService = game:GetService("RunService")

-- Packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local TableUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("TableUtil"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

-- Modules
local PetsUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetsUtil"))
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local ExitButton = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ExitButton"))
local PetKinds = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetKinds"))
local MergeIndex = require(
	game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("PetInventory"):WaitForChild("MergeIndex")
)

-- Types
type Signal = Signal.Signal
type List<T> = TableUtil.List<T>
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
type ValueState<T> = ColdFusion.ValueState<T>
type PetData = PetsUtil.PetData
type LevelStats = PetKinds.LevelStats

-- Constants
-- local GET_PETS_KEY = "GetPet"
-- local EQUIP_PET_KEY = "EquipPet"
-- local DELETE_PET_KEY = "DeletePet"
local BACKGROUND_COLOR = Color3.fromHSV(1, 0, 1)
local INVENTORY_BACKGROUND_COLOR = Color3.fromHSV(1, 0, 0.9)
local SELECT_COLOR = Color3.fromHSV(0.15, 1, 1)
local EQUIP_COLOR = Color3.fromHSV(0.425, 1, 1)
local DELETE_COLOR = Color3.fromHSV(1, 1, 0.9)
local PADDING = UDim.new(0, 10)
local TEXT_SIZE = 24

-- References
local PetModelFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("PetModels")

-- Private function
function getViewportFrame(model: Model, Color: State<Color3>): ViewportFrame
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

	model:PivotTo(CFrame.new(0, 0, 0))
	maid:GiveTask(model)

	local _cf, size = model:GetBoundingBox()
	local diameter = size.Magnitude

	local camera = _new("Camera")({
		FieldOfView = 40,
		CFrame = CFrame.Angles(0, math.rad(30), 0) * CFrame.new(Vector3.new(0, 0, diameter), Vector3.new(0, 0, 0)),
	})

	local viewportFrame = _new("ViewportFrame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CurrentCamera = camera,
		BorderSizePixel = 0,
		ZIndex = 20,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Ambient = Color3.new(1, 1, 1),
		LightColor = Color3.new(1, 1, 1),
		ImageColor3 = Color,
		ImageTransparency = 0,
		[_CHILDREN] = {
			camera,
			_new("UICorner")({
				CornerRadius = UDim.new(0.5, 0),
			}),
			_new("WorldModel")({
				[_CHILDREN] = {
					model,
				},
			}),
		},
	}) :: ViewportFrame

	maid:GiveTask(viewportFrame.Destroying:Connect(function()
		maid:Destroy()
	end))

	return viewportFrame
end

local function inventoryButton(
	layoutOrder: number,
	petData: PetData,
	maid: Maid,
	Selection: ValueState<PetData?>
): ImageButton?
	assert(petData.Name, "Bad pet data")

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

	local selectedModel = PetModelFolder:FindFirstChild(petData.Name)
	local model = selectedModel and selectedModel:Clone() :: Model
	if model then
		local viewport = maid:GiveTask(getViewportFrame(
			model,
			_Computed(function(sel: PetData?)
				if sel == petData then
					return Color3.new(0, 0, 0)
				else
					return Color3.new(1, 1, 1)
				end
			end, Selection):Tween()
		)) :: ViewportFrame
		viewport.Size = UDim2.fromScale(1, 1)
		viewport.Position = UDim2.fromScale(0.5, 0.5)
		viewport.AnchorPoint = Vector2.new(0.5, 0.5)

		local button = _new("ImageButton")({
			Name = petData.Name,
			LayoutOrder = if petData.Equipped then layoutOrder else layoutOrder + 1000,
			AutoButtonColor = true,
			BackgroundColor3 = _Computed(function(sel: PetData?)
				if sel == petData then
					return SELECT_COLOR
				elseif petData and petData.Equipped then
					return EQUIP_COLOR
				else
					return BACKGROUND_COLOR
				end
			end, Selection):Tween(),
			[_ON_EVENT("Activated")] = function()
				if petData == Selection:Get() then
					Selection:Set(nil)
				else
					Selection:Set(petData)
				end
			end,
			Image = "",
			[_CHILDREN] = {
				viewport :: any,
				_new("UICorner")({
					CornerRadius = PADDING,
				}),
			},
		}) :: ImageButton
		return button
	end
	return nil
end

-- Class
return function(
	maid: Maid,
	Selection: ValueState<PetData?>,
	Pets: State<{ [number]: PetData }>,
	EquipLimit: ValueState<number>,
	IndexSelection: ValueState<GuiObject?>,
	OnBack: Signal,
	OnEquip: Signal,
	OnDelete: Signal,
	OnMerge: Signal,
	parent: GuiObject
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

	local ViewportSize = _Value(workspace.CurrentCamera.ViewportSize)
	local InventorySize = _Value(Vector2.new(0, 0))
	local PetLimit = _Value(50)

	local OnMergeIndex = Signal.new()

	local LevelStats = _Computed(function(petData: PetData?): LevelStats?
		if petData then
			-- print("CLASS", petData.Class, petData.Level)
			local petClass = PetKinds[petData.Class]
			-- print(petClass)
			if petClass then
				local lvl = math.min(petData.Level, #petClass.LevelsStats)
				if lvl < petData.Level then
					warn(
						"The level for this "
							.. tostring(petData.Class)
							.. " only goes up to "
							.. tostring(#petClass.LevelsStats)
							.. ", pet data has a level of "
							.. tostring(petData.Level)
					)
				end
				return petClass.LevelsStats[lvl]
			end
		end
		return nil
	end, Selection)

	local inventory = _new("Frame")({
		Name = "Inventory",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		[_CHILDREN] = {
			_new("UICorner")({
				CornerRadius = PADDING,
			}),
			_new("UIGridLayout")({
				CellPadding = UDim2.new(PADDING, PADDING),
				CellSize = _Computed(function(inventorySize: Vector2)
					local dim = UDim.new(-PADDING.Scale, inventorySize.X * 0.25 - PADDING.Offset)
					return UDim2.new(dim, dim)
				end, InventorySize),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				StartCorner = Enum.StartCorner.TopLeft,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		},
	}) :: Frame
	InventorySize:Set(inventory.AbsoluteSize)

	_Computed(function(pets)
		return pets
	end, Pets):ForPairs(function(i: number, v: PetData, pairMaid: Maid)
		--print(i, "PET DATA", v)
		local button = inventoryButton(i, v, pairMaid, Selection)
		if button then
			button.Parent = inventory
		end
		return i, v
	end)

	local Model = _Computed(function(sel: PetData?): Model?
		maid._model = nil
		if sel then
			local modelSelected = PetModelFolder:FindFirstChild(sel.Name)
			local model = modelSelected and modelSelected:Clone() :: Model
			if model then
				model:PivotTo(CFrame.new(0, 0, 0))
				maid._model = model
				return model
			end
		end
		return nil
	end, Selection)

	local Diameter = _Computed(function(model: Model?): number?
		if model then
			local _cf, size = model:GetBoundingBox()
			local diameter = size.Magnitude
			return diameter
		end
		return nil
	end, Model)

	local camera = _new("Camera")({
		FieldOfView = 40,
		CFrame = _Computed(function(diameter: number?)
			diameter = diameter or 0
			assert(diameter ~= nil)
			return CFrame.Angles(0, math.rad(30), 0) * CFrame.new(Vector3.new(0, 0, diameter), Vector3.new(0, 0, 0))
		end, Diameter),
	})

	local viewportFrame = _new("ViewportFrame")({
		BackgroundTransparency = 0,
		BackgroundColor3 = INVENTORY_BACKGROUND_COLOR,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		CurrentCamera = camera,
		BorderSizePixel = 0,
		ZIndex = 20,
		LayoutOrder = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Ambient = Color3.new(1, 1, 1),
		LightColor = Color3.new(1, 1, 1),
		ImageColor3 = Color3.new(1, 1, 1),
		[_CHILDREN] = {
			camera,
			_new("UICorner")({
				CornerRadius = UDim.new(0.5, 0),
			}),
			_new("WorldModel")({
				[_CHILDREN] = {
					Model,
				},
			}),
		},
	})

	local out = _new("Frame")({
		Name = "PetInventory",
		Visible = _Computed(function(indexSelectionVal: GuiObject?)
			--print(indexSelectionVal and indexSelectionVal.Name, " huh?")
			return if indexSelectionVal and indexSelectionVal.Name == "PetInventory" then true else false
		end, IndexSelection),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = BACKGROUND_COLOR,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = parent,
		[_CHILDREN] = {
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = LegibilityUtil(Color3.new(0.5, 0.5, 0.5), BACKGROUND_COLOR),
				Thickness = 4,
			}),
			_new("UIPadding")({
				PaddingTop = PADDING,
				PaddingBottom = PADDING,
				PaddingRight = PADDING,
				PaddingLeft = PADDING,
			}),
			_new("UIListLayout")({
				Padding = PADDING,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("UICorner")({
				CornerRadius = PADDING,
			}),

			_new("Frame")({
				Name = "Content",
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = PADDING,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("Frame")({
						Name = "Profile",
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = _Computed(function(vSize: Vector2)
							return UDim2.fromOffset(vSize.X * 0.2, vSize.Y * 0)
						end, ViewportSize),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = PADDING,
								PaddingBottom = PADDING,
								PaddingRight = PADDING,
								PaddingLeft = PADDING,
							}),
							_new("UIListLayout")({
								Padding = PADDING,
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							viewportFrame,
							_new("TextLabel")({
								Name = "PetName",
								RichText = true,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								LayoutOrder = 2,
								TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
								TextSize = TEXT_SIZE * 1.5,
								Font = Enum.Font.Cartoon,
								TextWrapped = true,
								Text = _Computed(function(petData: PetData?)
									if petData then
										return "<b>" .. string.upper(petData.Name) .. "</b>"
									else
										return "<b>" .. string.upper("None") .. "</b>"
									end
								end, Selection),
							}),
							_new("TextLabel")({
								Name = "PetLevel",
								RichText = true,
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 0,
								LayoutOrder = 1.75,
								BackgroundColor3 = INVENTORY_BACKGROUND_COLOR,
								TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), INVENTORY_BACKGROUND_COLOR),
								TextSize = TEXT_SIZE * 0.6,
								TextXAlignment = Enum.TextXAlignment.Left,
								Font = Enum.Font.Cartoon,
								TextWrapped = true,
								Text = _Computed(function(petData: PetData?)
									if petData then
										return "<b> LVL " .. string.upper(tostring(petData.Level)) .. "</b>"
									else
										return "<b> LVL 0 </b>"
									end
								end, Selection),
								[_CHILDREN] = {
									_new("UICorner")({
										CornerRadius = UDim.new(0.5, 0),
									}),
									_new("UIPadding")({
										PaddingTop = UDim.new(0, 2),
										PaddingBottom = UDim.new(0, 2),
										PaddingRight = UDim.new(0, 6),
										PaddingLeft = UDim.new(0, 6),
									}),
								},
							}),
							_new("Frame")({
								Name = "StatFrame",
								BackgroundColor3 = BACKGROUND_COLOR,
								LayoutOrder = 3,
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								[_CHILDREN] = {
									_new("UICorner")({
										CornerRadius = PADDING,
									}),
									_new("UIStroke")({
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
										Color = INVENTORY_BACKGROUND_COLOR,
										Thickness = 4,
									}),
									_new("UIPadding")({
										PaddingTop = PADDING,
										PaddingBottom = PADDING,
										PaddingRight = PADDING,
										PaddingLeft = PADDING,
									}),
									_new("UIListLayout")({
										Padding = PADDING,
										FillDirection = Enum.FillDirection.Vertical,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										VerticalAlignment = Enum.VerticalAlignment.Top,
										SortOrder = Enum.SortOrder.LayoutOrder,
									}),
									_new("Frame")({
										Name = "Container",
										BackgroundTransparency = 1,
										AutomaticSize = Enum.AutomaticSize.XY,
										[_CHILDREN] = {
											_new("UIListLayout")({
												Padding = PADDING,
												FillDirection = Enum.FillDirection.Vertical,
												HorizontalAlignment = Enum.HorizontalAlignment.Left,
												VerticalAlignment = Enum.VerticalAlignment.Top,
												SortOrder = Enum.SortOrder.LayoutOrder,
											}),
											_new("TextLabel")({
												Name = "Power",
												RichText = true,
												AutomaticSize = Enum.AutomaticSize.XY,
												BackgroundTransparency = 1,
												LayoutOrder = 1,
												TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
												TextSize = TEXT_SIZE * 1.15,
												Font = Enum.Font.Cartoon,
												TextWrapped = true,
												Text = _Computed(function(levelStats: LevelStats?)
													local val = 0
													if levelStats then
														val = levelStats.MaximumEnergy
													end
													return "⚡ " .. "<b>" .. tostring(val) .. "</b>"
												end, LevelStats),
											}),
											_new("TextLabel")({
												Name = "Speed",
												RichText = true,
												AutomaticSize = Enum.AutomaticSize.XY,
												BackgroundTransparency = 1,
												LayoutOrder = 2,
												TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
												TextSize = TEXT_SIZE * 1.15,
												Font = Enum.Font.Cartoon,
												TextWrapped = true,
												Text = _Computed(function(levelStats: LevelStats?)
													local val = 0
													if levelStats then
														val = levelStats.Speed
													end
													return "⏪ " .. "<b>" .. tostring(val) .. "</b>"
												end, LevelStats),
											}),
											_new("TextLabel")({
												Name = "Delay",
												RichText = true,
												AutomaticSize = Enum.AutomaticSize.XY,
												BackgroundTransparency = 1,
												LayoutOrder = 2,
												TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
												TextSize = TEXT_SIZE * 1.15,
												Font = Enum.Font.Cartoon,
												TextWrapped = true,
												Text = _Computed(function(levelStats: LevelStats?)
													local val = 0
													if levelStats then
														val = levelStats.RetargetTime
													end
													return "⏰ " .. "<b>" .. tostring(val) .. "s</b>"
												end, LevelStats),
											}),
										},
									}),
								},
							}),
						},
					}),
					_new("ScrollingFrame")({
						LayoutOrder = 2,
						BackgroundTransparency = 0,
						CanvasSize = UDim2.fromScale(0, 0),
						BackgroundColor3 = INVENTORY_BACKGROUND_COLOR,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						ScrollBarImageColor3 = LegibilityUtil(Color3.new(1, 1, 1), INVENTORY_BACKGROUND_COLOR),
						Size = _Computed(function(vSize: Vector2)
							return UDim2.fromOffset(vSize.X * 0.4, vSize.Y * 0.5)
						end, ViewportSize),
						[_CHILDREN] = {
							inventory :: any,
							_new("UIPadding")({
								PaddingTop = PADDING,
								PaddingBottom = PADDING,
								PaddingRight = PADDING,
								PaddingLeft = PADDING,
							}),
							_new("UIListLayout")({
								Padding = PADDING,
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								VerticalAlignment = Enum.VerticalAlignment.Top,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
						},
					}),
				},
			}),

			_new("Frame")({
				Name = "Limits",
				LayoutOrder = 5,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = UDim.new(0, TEXT_SIZE * 0.75),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("TextLabel")({
						Name = "PetLimit",
						RichText = true,
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = 5,
						TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
						TextSize = TEXT_SIZE * 0.7,
						TextXAlignment = Enum.TextXAlignment.Left,
						Font = Enum.Font.Cartoon,
						TextWrapped = true,
						Text = _Computed(function(pets: { [number]: PetData }, limit: number)
							local count = #pets
							return "<b>PETS " .. tostring(count) .. "/" .. tostring(limit) .. "</b>"
						end, Pets, PetLimit),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = UDim.new(0, 2),
								PaddingBottom = UDim.new(0, 2),
								PaddingRight = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 6),
							}),
						},
					}),
					_new("TextLabel")({
						Name = "EquipLimit",
						RichText = true,
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = 0,
						TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), BACKGROUND_COLOR),
						TextSize = TEXT_SIZE * 0.7,
						TextXAlignment = Enum.TextXAlignment.Left,
						Font = Enum.Font.Cartoon,
						TextWrapped = true,
						Text = _Computed(function(pets: { [number]: PetData }, limit: number)
							local count = 0
							for i, petData in ipairs(pets) do
								if petData.Equipped then
									count += 1
								end
							end
							return "<b>EQUIPPED " .. tostring(count) .. "/" .. tostring(limit) .. "</b>"
						end, Pets, EquipLimit),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = UDim.new(0, 2),
								PaddingBottom = UDim.new(0, 2),
								PaddingRight = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 6),
							}),
						},
					}),
				},
			}),
			_new("Frame")({
				Name = "Footer",
				LayoutOrder = 5,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = PADDING,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("TextButton")({
						AutomaticSize = Enum.AutomaticSize.XY,
						TextSize = TEXT_SIZE,
						Name = "EquipButton",
						BackgroundColor3 = EQUIP_COLOR,
						Font = Enum.Font.Cartoon,
						TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), EQUIP_COLOR),
						LayoutOrder = 3,
						RichText = true,
						AutoButtonColor = true,
						[_ON_EVENT("Activated")] = function()
							print("Equip")

							-- local petData = Selection:Get()

							OnEquip:Fire(Selection:Get())
							-- if petData then
							-- 	petData.Equipped = not petData.Equipped
							-- 	Selection:Set(petData)
							-- end
						end,
						BackgroundTransparency = _Computed(function(petData: PetData?)
							return if petData ~= nil then 0 else 0.7
						end, Selection):Tween(),
						Text = _Computed(function(petData: PetData?)
							if petData and petData.Equipped then
								return "<b>" .. string.upper("Unequip") .. "</b>"
							else
								return "<b>" .. string.upper("Equip") .. "</b>"
							end
						end, Selection),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = PADDING,
								PaddingBottom = PADDING,
								PaddingRight = PADDING,
								PaddingLeft = PADDING,
							}),
							_new("UICorner")({
								CornerRadius = PADDING,
							}),
						},
					}),
					_new("TextButton")({
						AutomaticSize = Enum.AutomaticSize.XY,
						TextSize = TEXT_SIZE,
						Name = "DeleteButton",
						BackgroundColor3 = DELETE_COLOR,
						Font = Enum.Font.Cartoon,
						TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), DELETE_COLOR),
						LayoutOrder = 1,
						RichText = true,
						AutoButtonColor = true,
						[_ON_EVENT("Activated")] = function()
							OnDelete:Fire(Selection:Get())
						end,
						Text = "<b>" .. string.upper("Delete") .. "</b>",
						BackgroundTransparency = _Computed(function(petData: PetData?)
							return if petData ~= nil then 0 else 0.7
						end, Selection):Tween(),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = PADDING,
								PaddingBottom = PADDING,
								PaddingRight = PADDING,
								PaddingLeft = PADDING,
							}),
							_new("UICorner")({
								CornerRadius = PADDING,
							}),
						},
					}),
					_new("TextButton")({
						AutomaticSize = Enum.AutomaticSize.XY,
						TextSize = TEXT_SIZE,
						Name = "MergeButton",
						Visible = _Computed(function(petData: PetData?)
							local levelFound = false
							if petData then
								local PetKind =
									PetKinds[petData.Class :: any] :: PetKinds.PetKindData<PetsUtil.PetClass>

								local levelStat = if PetKind then PetKind.LevelsStats[petData.Level + 1] else nil

								levelFound = if levelStat then true else false
							end
							return levelFound
						end, Selection),
						BackgroundColor3 = EQUIP_COLOR,
						Font = Enum.Font.Cartoon,
						TextColor3 = LegibilityUtil(Color3.new(1, 1, 1), DELETE_COLOR),
						LayoutOrder = 0,
						RichText = true,
						AutoButtonColor = true,
						[_ON_EVENT("Activated")] = function()
							--[[local mergeIndexFrame =	maid:GiveTask(MergeIndex(Selection, Pets, out, OnMerge, IndexSelection))
							mergeIndexFrame.Parent = parent]]
							OnMergeIndex:Fire()
							--OnMergeIndex:Fire(Selection:Get())
						end,
						Text = "<b>" .. string.upper("Merge") .. "</b>",
						BackgroundTransparency = _Computed(function(petData: PetData?)
							return if petData ~= nil then 0 else 0.7
						end, Selection):Tween(),
						[_CHILDREN] = {
							_new("UIPadding")({
								PaddingTop = PADDING,
								PaddingBottom = PADDING,
								PaddingRight = PADDING,
								PaddingLeft = PADDING,
							}),
							_new("UICorner")({
								CornerRadius = PADDING,
							}),
						},
					}),
					-- _new("TextButton")({
					-- 	AutomaticSize = Enum.AutomaticSize.XY,
					-- 	TextSize = TEXT_SIZE,
					-- 	Name = "BackButton",
					-- 	BackgroundTransparency = 1,
					-- 	Font = Enum.Font.Cartoon,
					-- 	TextColor3 = LegibilityUtil(Color3.new(1,1,1), BACKGROUND_COLOR),
					-- 	LayoutOrder = 0,
					-- 	RichText = true,
					-- 	AutoButtonColor = true,
					-- 	[_ON_EVENT("Activated")] = function()
					-- 		-- print("Back")
					-- 		OnBack:Fire()
					-- 	end,
					-- 	Text = "<b>"..string.upper("Back").."</b>",
					-- 	[_CHILDREN] = {
					-- 		_new("UIPadding")({
					-- 			PaddingTop = PADDING,
					-- 			PaddingBottom = PADDING,
					-- 			PaddingRight = PADDING,
					-- 			PaddingLeft = PADDING,
					-- 		}),
					-- 	},
					-- })
				},
			}),
			_new("Frame")({
				Name = "Spacer",
				LayoutOrder = 10,
				Size = UDim2.new(UDim.new(0, 0), PADDING),
				BackgroundTransparency = 1,
			}),
		},
	}) :: Frame

	--merge index
	local mergeIndexFrame = maid:GiveTask(MergeIndex(Selection, Pets, out, OnMerge, IndexSelection))
	mergeIndexFrame.Parent = parent

	--exit button
	maid:GiveTask(ExitButton(
		out,
		function()
			OnBack:Fire()
		end,
		_Computed(function(indexSelectionVal: GuiObject?)
			return if indexSelectionVal and indexSelectionVal.Name == "PetInventory" then true else false
		end, IndexSelection)
	))

	maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
		ViewportSize:Set(workspace.CurrentCamera.ViewportSize)
		InventorySize:Set(inventory.AbsoluteSize)
	end))

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	OnMergeIndex:Connect(function()
		IndexSelection:Set(mergeIndexFrame)
	end)

	--set first
	IndexSelection:Set(out)

	return out
	--}
	--}) :: Frame
end
