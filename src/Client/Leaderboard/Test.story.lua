--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))

-- Modules
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

-- Types
type Maid = Maid.Maid

-- Constants
-- Variables
-- References
-- Class
return function(coreGui: Frame)
	local maid = Maid.new()
	local _fuse = ColdFusion.fuse(maid)
	local _Value = _fuse.Value
	local _Computed = _fuse.Computed
 
	task.spawn(function()
		local Leaderboard = require(script.Parent)
		type LeaderboardEntry = Leaderboard.LeaderboardEntry

		local function generateRandomLeaderboardEntry(): LeaderboardEntry
			local value = math.random(10000)
			return {
				UserId = 100000 + math.random(1000000),
				Name = FormatUtil.pseudoWord(math.random(5, 10)),
				Value = value,
				Rank = -1,
				Text = tostring(FormatUtil.insertCommas(value)) .. " florples",
			}
		end

		local entryList = {}
		for i = 1, 100 do
			entryList[tostring(i)] = generateRandomLeaderboardEntry()
		end

		local leaderboard = maid:GiveTask(
			Leaderboard("Florples", Color3.new(0, 1, 1), _Value(entryList), _Value(generateRandomLeaderboardEntry()))
		)

		local frame = maid:GiveTask(Instance.new("Frame"))
		frame.BackgroundTransparency = 0.8
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.Size = UDim2.fromOffset(300, 400)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Parent = coreGui

		leaderboard.Parent = frame
	end)

	return function()
		maid:Destroy()
	end
end
