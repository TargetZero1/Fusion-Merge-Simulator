--!strict
local RunService = game:GetService("RunService")

local _Package = script.Parent
local _Packages = _Package.Parent

local _Maid = require(_Packages.Maid)

return function(coreGui: ScreenGui)
	local maid = _Maid.new()

	task.spawn(function()
		local _Fuse = require(script.Parent)
		maid:GiveTask(_Fuse)

		-- Symbol constructors
		local _OUT = _Fuse.OUT
		local _REF = _Fuse.REF
		local _ON_EVENT = _Fuse.ON_EVENT
		local _ON_PROPERTY = _Fuse.ON_PROPERTY

		-- Instance functions
		local _new = _Fuse.new
		local _mount = _Fuse.mount

		-- Helper functions
		local _import = _Fuse.import

		-- Symbols
		local _CHILDREN = _Fuse.CHILDREN

		-- States
		local _Value = _Fuse.Value
		local _Computed = _Fuse.Computed

		local Increment = _Value(0)

		local Text = _Computed(function(inc: number): string
			return "Button" .. tostring(inc)
		end, Increment)

		local BackgroundColor3 = _Computed(function(inc: number): Color3
			return Color3.fromHSV(1, if inc % 2 == 0 then 1 else 0, 1)
		end, Increment):Spring()

		_Fuse.new("TextButton")({
			Name = "Button",
			Text = Text,
			ZIndex = 3,
			BackgroundTransparency = 0,
			BackgroundColor3 = BackgroundColor3,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Parent = coreGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			[_ON_EVENT("MouseButton1Down")] = function()
				print("Click")
			end,
			[_CHILDREN] = {
				_new("UIPadding")({
					PaddingBottom = UDim.new(0, 4),
					PaddingTop = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				}) :: any,
				_new("UICorner")({
					CornerRadius = UDim.new(0, 4),
				}),
			},
		})

		local startTick = tick()
		local num = 0
		maid:GiveTask(RunService.RenderStepped:Connect(function()
			local curNum = math.round(tick() - startTick)
			if num ~= curNum then
				print("N", num)
				num = curNum
				Increment:Set(math.round(tick() - startTick))
			end
		end))
	end)

	return function()
		maid:Destroy()
	end
end
