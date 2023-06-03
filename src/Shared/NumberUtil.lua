--!strict

return {
	LerpNumber = function(startNum: number, endNum: number, alpha: number) -- alpha float
		alpha = math.clamp(alpha, 0, 1)
		local num = startNum + (endNum - startNum) * alpha
		return num
	end,

	BaseMultiplier = function(baseNum: number, multiplierNum: number)
		return baseNum ^ (multiplierNum - 1)
	end,

	RoundNumber = function(num : number, snapNum : number, roundMode : "Floor" | "Round" | "Ceiling")
		return if roundMode == "Floor" then math.floor(num/snapNum)*snapNum elseif roundMode == "Round" then math.round(num/snapNum)*snapNum elseif roundMode == "Ceiling" then math.ceil(num/snapNum)*snapNum else -math.huge
	end,

	NumberToClock = function(num : number)
		return string.format("%.1d:%.2d:%.2d", math.floor(num/(60*60)), math.floor((num/60)%60),  num%60) 
	end
}
