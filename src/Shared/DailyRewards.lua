--!strict
--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))
local NetworkUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NetworkUtil"))

--modules
local NumberUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberUtil"))

--types
type Maid = Maid.Maid

export type PlayerRewardData = {
    ClaimedRewards : {[number] : ClaimedRewardData},
    StartTick : number,
    JoinedDay : number ?
}

export type ClaimedRewardData = {
    RewardName : string,
    Timestamp : number
}

export type RewardType = {
    RewardName : string,
    RewardFunc : (player : Player, ... any ?) -> any ?,
    Time : number
}
export type RewardSys = {
    __index : RewardSys,
    _Maid : Maid,
    Player : Player,
    JoinedDay : number,
    StartTick : number,
    ClaimedRewards : {[number] : ClaimedRewardData},

    new : (plr : Player) -> RewardSys,
    ClaimReward : (RewardSys, rewardName : string, ... any) -> nil,
    GetTimeLeft: (RewardSys, rewardName : string) -> number,
    CheckRewardIsClaimed : (RewardSys, rewardName : string) -> boolean,
    Destroy : (RewardSys) -> nil,
    SetData : (RewardSys, PlayerRewardData) -> nil,
    GetData : (RewardSys) -> PlayerRewardData,

    addReward : (RewardType) -> nil,
    getRewards : () -> {[number] : RewardType},
    getRewardType : (RewardName : string) -> RewardType ?,
    getPlayerRegistry : (Player : Player) -> RewardSys,

    init : (maid :Maid) -> nil
}

--constants
local ON_REWARD_CLAIM = "OnRewardClaim"
local ON_DAILY_REWARDS_DATA_UPDATE = "OnDailyRewardsDataUpdate"
local ON_CLAIMED_DAILY_REWARDS_UPDATE = "OnClaimedDailyRewardsUpdate"
local ON_TICK_UPDATE = "OnTickUpdate"

local REWARD_REFRESH_INTERVAL = 24*60*60
local UTC_TIMEZONE_DIFF = 1 -- in hour
--variables
local Rewards = {} :: {[number] : RewardType}

local Registry = {}
--references
--local functions

--module
local RewardSys = {} :: RewardSys
RewardSys.__index = RewardSys

function RewardSys.new(plr : Player)
    local self : RewardSys  = setmetatable({}, RewardSys) :: any
    self._Maid = Maid.new()
    self.Player = plr
    self.JoinedDay = NumberUtil.RoundNumber(DateTime.now().UnixTimestamp + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Floor") 
    self.StartTick = DateTime.now().UnixTimestamp
    self.ClaimedRewards = {}

    --updating reward claims
    local refreshTick = tick()
    --local refreshBuffer = false

    local nextDay = NumberUtil.RoundNumber(DateTime.now().UnixTimestamp  + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Ceiling") 

    self._Maid:GiveTask(RunService.Stepped:Connect(function()
        if (tick() - refreshTick) >= 1 then
            refreshTick = tick()

            local currentTime = (DateTime.now().UnixTimestamp  + (UTC_TIMEZONE_DIFF*3600))
            --[[
            for k,claimedRewardData : ClaimedRewardData in ipairs(self.ClaimedRewards) do
                if (DateTime.now().UnixTimestamp - claimedRewardData.Timestamp) >= REWARD_REFRESH_INTERVAL  then
                    table.remove(self.ClaimedRewards, k)
                    NetworkUtil.fireClient(ON_CLAIMED_DAILY_REWARDS_UPDATE, self.Player, self.ClaimedRewards)

                    self.StartTick = DateTime.now().UnixTimestamp
                    NetworkUtil.fireClient(ON_TICK_UPDATE, self.Player, self.StartTick)
                    break
                end
            end]]
            local hour = ((DateTime.now().UnixTimestamp  + UTC_TIMEZONE_DIFF*3600)%(60*60*24))/60/60
            --[[if hour == 0 and not refreshBuffer then
                print("Refreshing because UK time :", hour, " and refresh buffer is ", refreshBuffer)
                refreshBuffer = true
                
                self.StartTick = DateTime.now().UnixTimestamp
                NetworkUtil.fireClient(ON_TICK_UPDATE, self.Player, self.StartTick)
            elseif hour ~= 0 and refreshBuffer then

                refreshBuffer = false
            end]]
            --new
            print("Time Until Reset : ", (nextDay - currentTime)/60/60, "Hour: ", hour, UTC_TIMEZONE_DIFF, "Days passed: ", (currentTime - self.JoinedDay)/(24*60*60))
            if (nextDay - currentTime <= 0) or (currentTime - self.JoinedDay) >= 24*60*60  then
                nextDay = NumberUtil.RoundNumber(DateTime.now().UnixTimestamp  + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Ceiling") 
                self.JoinedDay = NumberUtil.RoundNumber(DateTime.now().UnixTimestamp  + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Floor") 
                --resets
                self.StartTick =  DateTime.now().UnixTimestamp --tick()

                NetworkUtil.fireClient(ON_TICK_UPDATE, self.Player, self.StartTick)

                for k,claimedRewardData : ClaimedRewardData in ipairs(self.ClaimedRewards) do
                    table.remove(self.ClaimedRewards, k)
                    NetworkUtil.fireClient(ON_CLAIMED_DAILY_REWARDS_UPDATE, self.Player, self.ClaimedRewards)
                end
                
            end
           --[[ if NumberUtil.RoundNumber(clock, 5) then
                
            end ]]

        end
    end))

    --registring
    Registry[self.Player] = self

    NetworkUtil.fireClient(ON_DAILY_REWARDS_DATA_UPDATE, self.Player, Rewards)

    return self
end

function RewardSys:ClaimReward(rewardName : string, ...)
    local rewardType = RewardSys.getRewardType(rewardName)
    assert(rewardType, "Unable to find the reward type!")
    local timeLeft = self:GetTimeLeft(rewardName)
    print(timeLeft)
    if timeLeft <= 0 and not self:CheckRewardIsClaimed(rewardName) then
        
        rewardType.RewardFunc(self.Player, ...)
        table.insert(self.ClaimedRewards, {
            RewardName = rewardName,
            Timestamp = DateTime.now().UnixTimestamp
        })

    end

    NetworkUtil.fireClient(ON_CLAIMED_DAILY_REWARDS_UPDATE, self.Player, self.ClaimedRewards)
    return nil
end

function RewardSys:CheckRewardIsClaimed(rewardName : string)
    for _,v in pairs(self.ClaimedRewards) do
        if v.RewardName == rewardName then
            return true
        end
    end
    return false
end

function RewardSys:GetTimeLeft(rewardName : string) 
    local rewardType = RewardSys.getRewardType(rewardName)
    assert(rewardType, "Reward type not found!")

    return rewardType.Time - (DateTime.now().UnixTimestamp - self.StartTick) 
end

function RewardSys:Destroy()
    --unregisters
    Registry[self.Player] = nil

    self._Maid:Destroy()

    local t : RewardSys = self :: any
    for k,v in pairs(t) do
        t[k] = nil
    end

    setmetatable(self, nil)
    return nil
end

function RewardSys:GetData()
    local data = {
        ClaimedRewards = self.ClaimedRewards,
        StartTick = self.StartTick,
        JoinedDay = self.JoinedDay
    } :: PlayerRewardData
    return table.clone(data)
end

function RewardSys:SetData(plrRewardData : PlayerRewardData)
    --setting claimed rewards data
    table.clear(self.ClaimedRewards)
    for _,claimedReward : ClaimedRewardData in pairs(plrRewardData.ClaimedRewards) do
        if RewardSys.getRewardType(claimedReward.RewardName) then
            table.insert(self.ClaimedRewards, claimedReward)
        else
            warn(claimedReward.RewardName, ' Reward not found in registered rewards!')
        end
    end
    self.StartTick = plrRewardData.StartTick or DateTime.now().UnixTimestamp
    self.JoinedDay = plrRewardData.JoinedDay or NumberUtil.RoundNumber(DateTime.now().UnixTimestamp + (UTC_TIMEZONE_DIFF*3600), 24*60*60, "Floor") 

   --[[ if self.Player.Name == "aryoseno11" then
        self.StartTick = DateTime.now().UnixTimestamp - ((24*60*60)*5)
        self.JoinedDay = self.JoinedDay - ((24*60*60)*5)
    end]]

    NetworkUtil.fireClient(ON_CLAIMED_DAILY_REWARDS_UPDATE, self.Player, self.ClaimedRewards)
    NetworkUtil.fireClient(ON_TICK_UPDATE, self.Player, self.StartTick)
    return nil
end

function RewardSys.addReward(rewardType : RewardType)
    table.insert(Rewards, rewardType)
    return nil
end

function RewardSys.getRewards()
    return Rewards
end

function RewardSys.getRewardType(rewardName : string) : RewardType ?
    for _,RewardType in pairs(Rewards) do
        if RewardType.RewardName ==rewardName then
            return RewardType
        end
    end
    return nil
end

function RewardSys.getPlayerRegistry(plr : Player)
    return Registry[plr]
end

function RewardSys.init(maid : Maid)
    --server <-> client comms
    NetworkUtil.onServerInvoke(ON_REWARD_CLAIM, function(plr : Player, rewardType : RewardType)
        local plrReward = Registry[plr]
        assert(plrReward, "Player reward data not found!")

        plrReward:ClaimReward(rewardType.RewardName)

        return nil
    end)

    NetworkUtil.getRemoteEvent(ON_CLAIMED_DAILY_REWARDS_UPDATE)
    NetworkUtil.getRemoteEvent(ON_TICK_UPDATE)

    return nil
end

return  RewardSys