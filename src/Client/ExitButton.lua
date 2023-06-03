--!strict

--[[
	If you're looking at this script and wondering "Why did you do it like this CJ", I get it.
	Basically, most of the UI I've made rely on constraints to dynamically solve for the size based on the text size and such.
	As a result, it's not easy to just pin an exit button to the corner of menus.
	So, instead I'm super-imposing an exit button over the corner each frame. 
	This should be the fastest least messy way to complete this task,
	But there is an undeniably feeling of "why" that will be impossible to shake.
]]

-- Services
local RunService = game:GetService("RunService")
-- Packages
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Gamework
-- Modules
local Assets = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"))
-- Types
type Maid = Maid.Maid
type State<T> = ColdFusion.State<T>
-- Constants
local EXIT_ICON = Assets.Texture.Menu.ExitButton
-- Variables
-- References
-- Class+
return function(focus: GuiObject, onClick: () -> nil, Visible: State<boolean>): ScreenGui
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

	local function getButtonPosition(): UDim2
		local absPos = focus.AbsolutePosition
		local absSize = focus.AbsoluteSize
		return UDim2.fromOffset(absPos.X + absSize.X, absPos.Y)
	end

	local Position = _Value(getButtonPosition())

	local button = _new("ImageButton")({
		Position = Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(40, 40),
		AutoButtonColor = false,
		Image = EXIT_ICON.Default,
		HoverImage = EXIT_ICON.Hovered,
		PressedImage = EXIT_ICON.Pressed,
		[_ON_EVENT("Activated")] = function()
			onClick()
		end,
	}) :: ImageButton

	local out = _new("ScreenGui")({
		Parent = if RunService:IsRunning()
			then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			else game:GetService("CoreGui"),
		Name = focus.Name .. "ExitButton",
		Enabled = Visible,
		DisplayOrder = 10000,
		[_CHILDREN] = {
			button,
		},
	}) :: ScreenGui

	local playerGui: PlayerGui? = if RunService:IsRunning()
		then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
		else nil

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		if playerGui then
			for i, screenGui in ipairs(playerGui:GetChildren()) do
				if screenGui:IsA("ScreenGui") and screenGui:IsAncestorOf(focus) then
					out.DisplayOrder = screenGui.DisplayOrder + 1
					break
				end
			end
		end
		Position:Set(getButtonPosition())
	end))

	maid:GiveTask(focus.Destroying:Connect(function()
		maid:Destroy()
	end))

	maid:GiveTask(out.Destroying:Connect(function()
		maid:Destroy()
	end))

	return out
end
