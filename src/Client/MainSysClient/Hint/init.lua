--!strict
-- Services
local RunService = game:GetService("RunService")

-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))

-- Modules
local LegibilityUtil =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("LegibilityUtil"))

-- Types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>
type CanBeState<T> = ColdFusion.CanBeState<T>
-- Constants
-- Variables
-- References
-- Class
return function(backgroundColor: Color3, text: string): ScreenGui
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

	local textColor = LegibilityUtil(Color3.new(1, 1, 1), backgroundColor)

	local Position = _Value(UDim2.fromScale(0.5, 1.5))
	local ViewportSize = _Value(workspace.CurrentCamera.ViewportSize)

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		ViewportSize:Set(workspace.CurrentCamera.ViewportSize)
	end))

	local screenGui = _new("ScreenGui")({
		Name = "HintGui",
		Parent = if RunService:IsRunning()
			then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			else game:GetService("CoreGui"),
		[_CHILDREN] = {
			_new("UIPadding")({
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
			}),
			_new("TextButton")({
				Text = text,
				TextSize = 24,
				RichText = true,
				AutoButtonColor = true,
				AutomaticSize = Enum.AutomaticSize.XY,
				[_ON_EVENT("Activated")] = function()
					Position:Set(UDim2.fromScale(0.5, 1.5))
				end,
				Font = Enum.Font.Cartoon,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = Position:Tween(1),
				TextColor3 = textColor,
				BackgroundColor3 = backgroundColor,
				TextWrapped = true,
				[_CHILDREN] = {
					_new("UISizeConstraint")({
						MinSize = Vector2.new(0, 0),
						MaxSize = _Computed(function(vSize: Vector2)
							return Vector2.new(vSize.X * 0.5, math.huge)
						end, ViewportSize),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 6),
					}),
					_new("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
						Transparency = 0,
						Color = textColor,
					}),
					_new("UIPadding")({
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
					}),
				},
			}),
		},
	}) :: ScreenGui

	maid:GiveTask(screenGui.Destroying:Connect(function()
		maid:Destroy()
	end))

	task.spawn(function()
		Position:Set(UDim2.fromScale(0.5, 1))
		task.wait(string.len(text) * 0.5)
		Position:Set(UDim2.fromOffset(0.5, 1.5))
		maid:Destroy()
	end)

	return screenGui
end
