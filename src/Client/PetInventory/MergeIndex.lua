--!strict
-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
-- local SELECT_COLOR = Color3.fromHSV(0.15, 1, 1)
local EQUIP_COLOR = Color3.fromHSV(0.425, 1, 1)
-- local DELETE_COLOR = Color3.fromHSV(1, 1, 0.9)
local PADDING = UDim.new(0, 10)
local TEXT_SIZE = 24

local PET_MERGE_COUNT = 3

-- References
local PetModelFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PetModels")

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

-- Class
return function(
	Selection: ValueState<PetData?>,
	Pets: State<{ [number]: PetData }>,
	inventory: Frame,
	OnMerge: Signal,
	IndexSelection: ValueState<GuiObject?>
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

	-- local ViewportSize = _Value(workspace.CurrentCamera.ViewportSize)
	-- local InventorySize = _Value(Vector2.new(0, 0))
	-- local EquipLimit = _Value(5)
	-- local PetLimit = _Value(50)
	local PetMergeSelections = _Value({})

	local dynamicAbsoluteSize = _Value(inventory.AbsoluteSize)
	local dynamicAbsolutePosition = _Value(inventory.AbsolutePosition)

	local mergeablePetCollectionsFrame = _new("ScrollingFrame")({
		Name = "MergeFrame",
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = BACKGROUND_COLOR,
		Size = UDim2.fromScale(1, 0.8),
		LayoutOrder = 0,
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = PADDING,
				PaddingTop = PADDING,
				PaddingRight = PADDING,
				PaddingLeft = PADDING,
			}),
			_new("UIGridLayout")({
				CellPadding = UDim2.fromOffset(10, 10),
				CellSize = UDim2.fromOffset(80, 80),
			}),
		},
	})

	local model = _Computed(function(selectionVal: PetData?)
		maid._model = nil
		local referencedModel = if selectionVal
			then ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PetModels"):FindFirstChild(selectionVal.Name)
			else nil
		local model = if referencedModel then referencedModel:Clone() :: Model else nil
		if model then
			model:PivotTo(CFrame.new())
			maid._model = model
			return model
		end
		return nil :: any
	end, Selection)

	local Diameter = _Computed(function(model: Model)
		local _cf, size
		if model then
			_cf, size = model:GetBoundingBox()
		end
		return if size then size.Magnitude else nil
	end, model)

	local camera = _new("Camera")({
		FieldOfView = 40,
		CFrame = _Computed(function(diameterVal: number?)
			return if diameterVal
				then CFrame.lookAt(Vector3.new(1, 1, 1) * diameterVal, Vector3.new())
				else CFrame.new()
		end, Diameter),
	})

	local petImageViewport = _new("ViewportFrame")({
		Name = "PetImage",
		Size = UDim2.fromScale(0.8, 0.4),
		CurrentCamera = camera,
		[_CHILDREN] = {
			_new("WorldModel")({
				[_CHILDREN] = {
					model,
				},
			}),
		},
	})

	local mergeIndex = _new("Frame")({
		Name = "MergeIndex",
		-- AnchorPoint = Vector2.new(0.5,0.5),
		Position = _Computed(function(d: Vector2)
			return UDim2.fromOffset(d.X, d.Y)
		end, dynamicAbsolutePosition),
		Size = _Computed(function(d: Vector2)
			return UDim2.fromOffset(d.X, d.Y)
		end, dynamicAbsoluteSize),
		Visible = _Computed(function(indexSelectionVal: GuiObject?)
			return if indexSelectionVal and indexSelectionVal.Name == "MergeIndex" then true else false
		end, IndexSelection),
		[_CHILDREN] = {
			_new("UIListLayout")({
				Padding = PADDING,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			_new("UIPadding")({
				PaddingBottom = PADDING,
				PaddingTop = PADDING,
				PaddingRight = PADDING,
				PaddingLeft = PADDING,
			}),
			_new("Frame")({
				Name = "PetsStat",
				BackgroundColor3 = INVENTORY_BACKGROUND_COLOR,
				Size = UDim2.fromScale(0.4, 1),
				LayoutOrder = 0,
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingBottom = PADDING,
						PaddingTop = PADDING,
						PaddingRight = PADDING,
						PaddingLeft = PADDING,
					}),
					_new("UIListLayout")({
						Padding = PADDING,
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					petImageViewport,
					--[[_new("ViewportFrame")({
						Name = "PetImage",
						Size = UDim2.fromScale(0.8, 0.4)
					}),]]
					_new("TextLabel")({
						Name = "PetName",
						BackgroundTransparency = 1,
						TextSize = TEXT_SIZE * 2,
						AutomaticSize = Enum.AutomaticSize.XY,
						Text = _Computed(function(selectionVal: PetData?)
							return tostring(if selectionVal then selectionVal.Name else "no pet data"):upper()
						end, Selection),
						Font = Enum.Font.Cartoon,
					}),
					_new("Frame")({
						Name = "Stats",
						BackgroundTransparency = 1,
						[_CHILDREN] = {
							_new("UIListLayout")({
								Padding = PADDING,
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							_new("TextLabel")({
								Name = "EnergyStats",
								Font = Enum.Font.Cartoon,
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = TEXT_SIZE,
								TextColor3 = LegibilityUtil(Color3.fromRGB(255, 255, 255), INVENTORY_BACKGROUND_COLOR),
								Text = _Computed(function(selectionVal: PetData?)
									local petModel = if selectionVal
										then PetsUtil.getPetModelById(selectionVal.PetId)
										else nil
									return "⚡"
										.. tostring(if petModel then petModel:GetAttribute("MaxEnergy") else "n/a"):upper()
								end, Selection),
							}),
							_new("TextLabel")({
								Name = "SpeedStats",
								Font = Enum.Font.Cartoon,
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = TEXT_SIZE,
								TextColor3 = LegibilityUtil(Color3.fromRGB(255, 255, 255), INVENTORY_BACKGROUND_COLOR),
								Text = _Computed(function(selectionVal: PetData?)
									local petModel = if selectionVal
										then PetsUtil.getPetModelById(selectionVal.PetId)
										else nil
									local alignPos = if petModel and petModel.PrimaryPart
										then petModel.PrimaryPart:FindFirstChild("AlignPosition") :: AlignPosition
										else nil
									return "⏪" .. tostring(if alignPos then alignPos.MaxVelocity else "n/a"):upper()
								end, Selection),
							}),
						},
					}),
				},
			}),

			_new("Frame")({
				Name = "MergeMainFrame",
				BackgroundColor3 = INVENTORY_BACKGROUND_COLOR,
				Size = UDim2.fromScale(0.58, 1),
				LayoutOrder = 2,
				[_CHILDREN] = {
					_new("UIPadding")({
						PaddingBottom = PADDING,
						PaddingTop = PADDING,
						PaddingRight = PADDING,
						PaddingLeft = PADDING,
					}),
					_new("UIListLayout")({
						Padding = PADDING,
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					_new("Frame")({
						Name = "Header",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.08),
						LayoutOrder = 0,
						[_CHILDREN] = {
							_new("UIListLayout")({
								Padding = PADDING,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							_new("TextLabel")({ -- merge button
								Name = "SelectedPetCountText",
								Font = Enum.Font.Cartoon,
								BackgroundTransparency = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = TEXT_SIZE,
								Size = UDim2.fromScale(0.1, 1),
								Text = _Computed(function(petMergeSelVal)
									return string
										.format("merge: %s/%s", tostring(#petMergeSelVal), tostring(PET_MERGE_COUNT))
										:upper()
								end, PetMergeSelections),
							}),
						},
					}),
					mergeablePetCollectionsFrame,
					_new("Frame")({
						Name = "Footer",
						BackgroundTransparency = 1,
						BackgroundColor3 = BACKGROUND_COLOR,
						Size = UDim2.fromScale(1, 0.08),
						LayoutOrder = 1,
						[_CHILDREN] = {
							_new("UIListLayout")({
								Padding = PADDING,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							_new("TextButton")({ -- merge button
								Name = "Merge",
								AutoButtonColor = true,
								Visible = _Computed(function(petData: PetData?)
									local levelFound = false
									if petData then
										local PetKind =	PetKinds[petData.Class :: any] :: PetKinds.PetKindData<PetsUtil.PetClass>
										local levelStat = if PetKind
											then PetKind.LevelsStats[petData.Level + 1]
											else nil

										levelFound = if levelStat then true else false
									end
									return levelFound
								end, Selection),
								BackgroundColor3 = _Computed(function(petMergeSelVal)
									return if #petMergeSelVal ~= 3 then BACKGROUND_COLOR else EQUIP_COLOR
								end, PetMergeSelections):Tween(),
								TextColor3 = LegibilityUtil(Color3.fromRGB(100, 100, 100), EQUIP_COLOR),
								Size = UDim2.fromScale(0.3, 1),
								TextSize = TEXT_SIZE,
								AutomaticSize = Enum.AutomaticSize.XY,
								Font = Enum.Font.Cartoon,
								Text = string.upper("merge"),
								[_CHILDREN] = {
									_new("UICorner")({}),
								},
								[_ON_EVENT("Activated")] = function()
									print("On Merge") 
									OnMerge:Fire(PetMergeSelections:Get())
								end,
							}),
							_new("TextButton")({
								Name = "Back",
								Font = Enum.Font.Cartoon,	
								AutoButtonColor = true,
								BackgroundColor3 = BACKGROUND_COLOR,
								TextColor3 = LegibilityUtil(Color3.fromRGB(100, 100, 100), EQUIP_COLOR),
								Size = UDim2.fromScale(0.3, 1),
								TextSize = TEXT_SIZE,
								AutomaticSize = Enum.AutomaticSize.XY,
								Text = string.upper("back"),
								[_CHILDREN] = {
									_new("UICorner")({}),
								}, 
								[_ON_EVENT("Activated")] = function()
									print("On Merge Back") 
									IndexSelection:Set(inventory)
								end,
							}),
						},
					}),
				},
			}),
		},
	}) :: Frame

	--give mergeable pets lists
	_Computed(function(petsVal, selectionVal: PetData?)
		--clears up merge frame first
		PetMergeSelections:Set({ selectionVal })
		--for _, v: GuiObject in pairs(mergeablePetCollectionsFrame:GetChildren() :: any) do
		--if v:IsA("GuiButton") then
		--	v:Destroy()
		--end
		--end

		local mergeablePets = {}
		for _, petData: PetData in pairs(petsVal) do
			if
				selectionVal
				and (selectionVal.Name == petData.Name)
				and (selectionVal.Class == petData.Class)
				and (selectionVal ~= petData)
			then
				table.insert(mergeablePets, petData)
			end
		end
		return mergeablePets
	end, Pets, Selection):ForPairs(function(k, petData: PetData, pairMaid)
		--local petName = string.gsub(petData.Name, "%d+", "")
		local pairFuse = ColdFusion.fuse(pairMaid)
		local _pairNew = pairFuse.new

		local _pairComputed = pairFuse.Computed
		local _pairValue = pairFuse.Value

		local _pairON_EVENT = pairFuse.ON_EVENT
		local _pairCHILDREN = pairFuse.CHILDREN

		local petName = petData.Name
		if PetModelFolder:FindFirstChild(petName) then
			local vp = getViewportFrame(PetModelFolder:FindFirstChild(petName):Clone(), _pairValue(BACKGROUND_COLOR))
			pairMaid:GiveTask(_pairNew("ImageButton")({
				Name = petData.Name,
				AutoButtonColor = true,
				Parent = mergeablePetCollectionsFrame,
				BackgroundColor3 = _pairComputed(function(petMergeSelVal)
					if table.find(petMergeSelVal, petData) then
						return EQUIP_COLOR
					else
						return INVENTORY_BACKGROUND_COLOR
					end
				end, PetMergeSelections):Tween(),
				[_pairON_EVENT("Activated")] = function()
					local petMergeSelVal = PetMergeSelections:Get()
					if not table.find(petMergeSelVal, petData) then
						if #petMergeSelVal < PET_MERGE_COUNT then
							table.insert(petMergeSelVal, petData)
							PetMergeSelections:Set(petMergeSelVal)
						end
					else
						table.remove(petMergeSelVal, table.find(petMergeSelVal, petData))
						PetMergeSelections:Set(petMergeSelVal)
					end
				end,
				[_pairCHILDREN] = {
					_new("UICorner")({}),
					vp,
				},
			}))
		end
		return k, petData
	end)

	--exit button
	maid:GiveTask(ExitButton(
		mergeIndex,
		function()
			IndexSelection:Set(inventory)
		end,
		_Computed(function(indexSelectionVal: GuiObject?)
			return if indexSelectionVal and indexSelectionVal.Name == "MergeIndex" then true else false
		end, IndexSelection)
	))

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		dynamicAbsoluteSize:Set(inventory.AbsoluteSize)
		dynamicAbsolutePosition:Set(inventory.AbsolutePosition)
	end))

	return mergeIndex
end
