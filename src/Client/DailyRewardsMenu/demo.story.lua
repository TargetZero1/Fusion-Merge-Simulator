--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local ColdFusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("ColdFusion"))   
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))   
--modules
local DailyRewardsMenu = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("DailyRewardsMenu"))
local MainButton = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("DailyRewardsMenu"):WaitForChild("MainButton"))
local DailyRewards = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DailyRewards"))
--types
--constants
--variables
--references
return function(target)
    local maid = Maid.new()

	local _fuse = ColdFusion.fuse(maid)
	local _new = _fuse.new
	local _mount = _fuse.mount
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local _CHILDREN = _fuse.CHILDREN
	local _ON_EVENT = _fuse.ON_EVENT


    local Rewards = _Value({{
        RewardFunc = function() return nil end,
        RewardName = "Test 1",
        Time = 250
    }, {
        RewardFunc = function() return nil end,
        RewardName = "Test 2",
        Time = 150
    }})
    local claimedRewardData = _Value({
        
    })

    local isMenuVisible = _Value(false)
    local onRewardClick = maid:GiveTask(Signal.new())

    local menu = maid:GiveTask(
        DailyRewardsMenu(
            maid, 
            Rewards :: ColdFusion.ValueState<{any}>,
            claimedRewardData,

            isMenuVisible,
            _Value(DateTime.now().UnixTimestamp),
            onRewardClick
        )

    )
    menu.Parent = target


    local onRewardMainButtonClick = maid:GiveTask(Signal.new())

    local mainButton = maid:GiveTask(MainButton(maid, onRewardMainButtonClick))
    mainButton.Parent = target

    maid:GiveTask(onRewardClick:Connect(function(rewardType : DailyRewards.RewardType)
        print("Test ", rewardType.RewardName)
    end))

    maid:GiveTask(onRewardMainButtonClick:Connect(function()
        isMenuVisible:Set(not isMenuVisible:Get())
    end))

    return function()
        maid:Destroy()
    end
end