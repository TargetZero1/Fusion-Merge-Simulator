--!strict
-- Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--References
local Assets = ReplicatedStorage:WaitForChild("Assets")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local ServiceProxy = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("ServiceProxy"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))
local BlocksUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BlocksUtil"))
local PetKinds = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetKinds"))
local MiscLists = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiscLists"))
local ExitButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("ExitButton"))
-- Types
type Maid = Maid.Maid

type Fuse = ColdFusion.Fuse
type ValueState<T> = ColdFusion.ValueState<T>
type State<T> = ColdFusion.State<T>
type ParameterValue<T> = (State<T> | T)

type Signal = Signal.Signal

type MenuOption = ("Pet" | "Object" | nil)

export type IndexMenu = {
	__index: IndexMenu,
	_Maid: Maid,
	new: (
		maid: Maid,
		onBack: Signal,
		ObjectsIndex: ValueState<{}>,
		PetsIndex: ValueState<{}>,
		isVisible: ValueState<boolean>,
		parent: Frame
	) -> IndexMenu,
	--     init : (maid : Maid, onBack : Signal, ObjectsIndex : ValueState<{}>, PetsIndex : ValueState<{}>, isVisible : ValueState<boolean>, parent : ScreenGui) -> nil,
	Instance: GuiObject,
	Destroy: (IndexMenu) -> nil,
}

--Constants
local TEXT_SIZE = 24
local INVENTORY_BACKGROUND_COLOR = Color3.fromHSV(1, 0, 0.9)
local PADDING = UDim.new(0, 10)

local MAX_OBJECT_LEVEL = MiscLists.Limits.MaxObjectLevel

--functions
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

local function getViewport(maid: Maid, model: Model)
	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN

	model:PivotTo(CFrame.new(0, 0, 0))

	local camera = _new("Camera")({
		CFrame = CFrame.lookAt(Vector3.new(4, 4, 4), Vector3.new(0, 0, 0)),
	})

	local viewportFrame = _new("ViewportFrame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		CurrentCamera = camera,
		[_CHILDREN] = {
			camera,
			_new("WorldModel")({
				[_CHILDREN] = {
					model,
				},
			}),
		},
	})

	return _new("TextButton")({
		Size = UDim2.fromScale(0.3, 1),
		[_CHILDREN] = {

			_new("UICorner")({}),
			viewportFrame,
			_new("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 3,
				Color = Color3.fromRGB(150, 150, 150),
			}),
		},
	})
end

local currentIndexMenu: IndexMenu

local IndexMenu = {} :: IndexMenu
IndexMenu.__index = IndexMenu

function IndexMenu.new(
	maid: Maid,
	OnBack: Signal,
	ObjectsIndex: ValueState<{ [number]: number }>,
	PetsIndex: ValueState<{ [number]: string }>,
	isVisible: ValueState<boolean>,
	parent: Frame
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

	--which is selected? object or pet?
	local ObjectOrPetSelection: ValueState<GuiObject> = _Value(nil) :: any

	local self = setmetatable({}, IndexMenu) :: any

	--making displayer for block/pet
	local objectDisplayFrame = _new("ScrollingFrame")({
		Name = "Object" :: MenuOption,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0.7),
		Position = UDim2.fromScale(0.3, 0),
		BackgroundColor3 = Color3.fromRGB(200, 200, 200),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = _Computed(function(selectionFrame: GuiObject)
			return (if selectionFrame then (selectionFrame.Name == "Object") else false)
		end, ObjectOrPetSelection :: ValueState<GuiObject>),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 15),
				PaddingTop = UDim.new(0, 15),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),
			_new("UIGridLayout")({
				CellSize = UDim2.fromOffset(70, 70),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		},
	}) :: ScrollingFrame

	local petDisplayFrame = _new("ScrollingFrame")({
		Name = "Pet" :: MenuOption,
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0.7),
		Position = UDim2.fromScale(0.3, 0),
		BackgroundColor3 = Color3.fromRGB(200, 200, 200),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = _Computed(function(selectionFrame: GuiObject)
			return (if selectionFrame then (selectionFrame.Name == "Pet") else false)
		end, ObjectOrPetSelection :: ValueState<GuiObject>),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 15),
				PaddingTop = UDim.new(0, 15),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),
			_new("UIGridLayout")({
				CellSize = UDim2.fromOffset(70, 70),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		},
	}) :: ScrollingFrame

	local objectsIndexCount = #ObjectsIndex:Get()
	local petsIndexCount = #PetsIndex:Get()

	--computing for index inventory changes
	_Computed(function(petsIndex: { [number]: string }): { [number]: string }
		for _, v in pairs(petDisplayFrame:GetChildren()) do --clears up first the stff
			if v:IsA("GuiObject") then
				v:Destroy()
			end
		end
		--    print("PETS", petsIndex)
		return petsIndex or {}
	end, PetsIndex):ForPairs(function(index: number, value: string, pairMaid: Maid)
		-- print("PET UI")
		local petModels = Assets:FindFirstChild("PetModels")
		local petModel = petModels and petModels:FindFirstChild(value)
		local model = petModel and petModel:Clone() :: Model
		if model then
			local veiwport = getViewport(maid, model)
			veiwport.Parent = petDisplayFrame
		end
		--makes the question mark for objs stuff
		local petKindsCount = 0
		for _, v in pairs(PetKinds) do
			petKindsCount += 1
		end
		for i = 1, petKindsCount - petsIndexCount do
			local questionMark = getButton(
				maid,
				"?",
				nil,
				_Computed(function()
					return Color3.fromRGB(100, 100, 100)
				end) :: ValueState<Color3>
			)
			questionMark.Parent = petDisplayFrame
		end
		return index, value
	end)

	_Computed(function(objectsIndex: { [number]: number })
		for _, v in pairs(objectDisplayFrame:GetChildren()) do
			if v:IsA("GuiObject") then
				v:Destroy()
			end
		end
		return objectsIndex or {}
	end, ObjectsIndex):ForPairs(function(index: number, value: number, pairMaid: Maid)
		local objectModels = Assets:FindFirstChild("ObjectModels")
		local objectModel = objectModels and objectModels:FindFirstChild("TypeA")
		local model = objectModel and objectModel:Clone() :: Model
		if model then
			local fakeBlockData = BlocksUtil.newBlockData(0, value, false)
			BlocksUtil.applyBlockData(model, fakeBlockData)
			BlocksUtil.BlockLeveLVisualUpdate(model, fakeBlockData)

			local veiwport = getViewport(maid, model) :: ViewportFrame
			veiwport.LayoutOrder = value
			veiwport.Parent = objectDisplayFrame
		end
		--makes the question mark for objs stuff
		for i = 1, MAX_OBJECT_LEVEL - objectsIndexCount do
			local questionMark = getButton(
				maid,
				"?",
				nil,
				_Computed(function()
					return Color3.fromRGB(100, 100, 100)
				end) :: ValueState<Color3>
			) :: TextButton
			questionMark.LayoutOrder = 1000000
			questionMark.Parent = objectDisplayFrame
		end
		return index, value
	end)

	--signals for object/pet tab clicks
	local OnObjectTabClick = maid:GiveTask(Signal.new())
	local OnPetTabClick = maid:GiveTask(Signal.new())

	OnObjectTabClick:Connect(function()
		ObjectOrPetSelection:Set(objectDisplayFrame)
	end)

	OnPetTabClick:Connect(function()
		ObjectOrPetSelection:Set(petDisplayFrame)
	end)

	petDisplayFrame.Visible = false

	--making main frmae instance
	local frame = _new("Frame")({
		Parent = parent,
		Name = "IndexInventory",
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 0.55),
		Position = UDim2.fromScale(0.2, 0.2),
		Visible = isVisible,
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 15),
				PaddingTop = UDim.new(0, 25),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),
			_new("UIAspectRatioConstraint")({
				AspectRatio = 1.5,
			}),
			_new("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = PADDING,
			}),
			_new("UICorner")({}),
			_new("UIStroke")({
				Thickness = 4,
				Color = INVENTORY_BACKGROUND_COLOR,
			}),
			_new("Frame")({
				Name = "Options",
				LayoutOrder = 2,
				--BackgroundColor3 = Color3.fromRGB(100,100,100),
				Size = UDim2.fromScale(1, 0.2),
				Position = UDim2.fromScale(0.6, 0.8),
				[_CHILDREN] = {
					_new("UIListLayout")({
						Padding = PADDING,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					_new("UIPadding")({
						PaddingBottom = UDim.new(0, 4),
						PaddingTop = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
					--getButton(maid, "<b>BACK</b>", OnBack),
					getButton(
						maid,
						"OBJECT",
						OnObjectTabClick,
						_Computed(function(selectionFrame: GuiObject)
							return if (selectionFrame and selectionFrame.Name == "Object")
								then Color3.fromRGB(25, 20, 200)
								else Color3.fromRGB(200, 200, 200)
						end, ObjectOrPetSelection):Tween() :: ValueState<Color3>
					),
					getButton(
						maid,
						"PET",
						OnPetTabClick,
						_Computed(function(selectionFrame: GuiObject)
							return if (selectionFrame and selectionFrame.Name == "Pet")
								then Color3.fromRGB(25, 20, 200)
								else Color3.fromRGB(200, 200, 200)
						end, ObjectOrPetSelection):Tween() :: ValueState<Color3>
					),
				},
			}),
			objectDisplayFrame,
			petDisplayFrame,
		},
	}) :: GuiObject

	self._Maid = maid
	self.Instance = frame

	--set selection to object
	ObjectOrPetSelection:Set(objectDisplayFrame)

	--EXIT button
	maid:GiveTask(ExitButton(frame, function()
		OnBack:Fire()
	end, isVisible))

	currentIndexMenu = self
	return self
end

function IndexMenu:Destroy()
	if currentIndexMenu == self then
		currentIndexMenu = nil :: any
	end
	for k, v in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
	return nil
end

-- function IndexMenu.init(maid : Maid, OnBack : Signal, ObjectsIndex : ValueState<{}> , PetsIndex : ValueState<{}>, isVisible : ValueState<boolean>, parent : any)

--     maid:GiveTask(IndexMenu.new(OnBack, ObjectsIndex, PetsIndex, isVisible, parent))

--     return nil
-- end

return ServiceProxy(function()
	return currentIndexMenu or IndexMenu
end)
