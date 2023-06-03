--!strict
local RunService = game:GetService("RunService")

local Package = script.Parent
local Packages = Package.Parent

local Maid = require(Packages:WaitForChild("Maid"))
local Types = require(Package:WaitForChild("Types"))

return function(coreGui: ScreenGui)
	local maid = Maid.new()

	task.spawn(function()
		local ColdFusion = require(script.Parent)
		local _fuse = ColdFusion.fuse(maid)
		
		local _new = _fuse.new
		local _bind = _fuse.bind
		local _import = _fuse.import
		local _Value = _fuse.Value
		local _Computed = _fuse.Computed

		-- States
		local Increment = _Value(0)

		local Text = _Computed(function(inc: number): string
			return "Button" .. tostring(inc)
		end, Increment)

		local BackgroundColor3 = _Computed(function(inc: number): Color3
			return Color3.fromHSV(1, if inc % 2 == 0 then 1 else 0, 1)
		end, Increment):Spring()

		local children: {[number]: any} = {
			_new("UIPadding")({
				PaddingBottom = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
			_new("UICorner")({
				CornerRadius = UDim.new(0, 4),
			}),
		}

		_fuse.new("TextButton")(
			{
				Name = "String",
				Text = "",
				LayoutOrder = 1,
				Position = UDim2.new(0,0),
				Events = {
				-- 	MouseButton1Down = function()
				-- 		print("Click")
				-- 	end,
					MouseButton1Click = function()

					end,
					Activated = function()

					end,
				},
				Children = {
					_new("UIPadding")({
						PaddingBottom = UDim.new(0, 4),
						PaddingTop = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),
					_new("UICorner")({
						CornerRadius = UDim.new(0, 4),
					}),
				} :: {[number]: any},
			}
		)

			local startTick = tick()
		local num = 0

		maid:GiveTask(Increment:Connect(function(cur: number)
			print(cur)
		end))

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
