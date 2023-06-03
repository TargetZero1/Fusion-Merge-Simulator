--!strict
-- Based on https://gist.github.com/Fraktality/1033625223e13c01aa7144abe4aaf54d

export type Spring = {
	__index: Spring,
	Damping: number,
	Frequency: number,
	Goal: number,
	Position: number,
	Velocity: number,
	new: (dampingRatio: number, frequency: number, position: number) -> Spring,
	Set: (self: Spring, goal: number) -> nil,
	Get: (self: Spring) -> number,
	Step: (self: Spring, deltaTime: number) -> nil,
}

local Spring: Spring = {} :: any
Spring.__index = Spring

function Spring.new(dampingRatio: number, frequency: number, position: number): Spring
	local self: Spring = setmetatable({}, Spring) :: any
	
	assert(dampingRatio*frequency >= 0, 'stop that')

	self.Damping = dampingRatio -- damping ratio
	self.Frequency = frequency -- nominal frequency
	self.Goal = position -- goal position
	self.Position = position -- position
	self.Velocity = position*0 -- velocity (times 0 so the types match)
	
	return self
end

function Spring:Set(goal: number)
	self.Goal = goal
	return nil
end

function Spring:Get(): number
	return self.Position
end

function Spring:Step(deltaTime: number): nil
	local damping = self.Damping
	local frequency = self.Frequency*2*math.pi
	local goal = self.Goal
	local position = self.Position
	local velocity = self.Velocity

	local offset = position - goal
	local decay = math.exp(-deltaTime*damping*frequency)

	-- Given:
	--   frequency^2*(x[deltaTime] - goal) + 2*damping*frequency*x'[deltaTime] + x''[deltaTime] = 0,
	--   x[0] = position,
	--   x'[0] = velocity
	-- Solve for x[deltaTime], x'[deltaTime]
	
	if damping == 1 then -- critically damped

		self.Position = (velocity*deltaTime + offset*(frequency*deltaTime + 1))*decay + goal
		self.Velocity = (velocity - frequency*deltaTime*(offset*frequency + velocity))*decay

	elseif damping < 1 then -- underdamped

		local c = math.sqrt(1 - damping*damping)

		local i = math.cos(frequency*c*deltaTime)
		local j = math.sin(frequency*c*deltaTime)

		self.Position = (i*offset + j*(velocity + damping*frequency*offset)/(frequency*c))*decay + goal
		self.Velocity = (i*c*velocity - j*(velocity*damping + frequency*offset))*decay/c

	elseif damping > 1 then -- overdamped

		local c = math.sqrt(damping*damping - 1)

		local r1 = -frequency*(damping - c)
		local r2 = -frequency*(damping + c)

		local co2 = (velocity - r1*offset)/(2*frequency*c)
		local co1 = offset - co2

		local e1 = co1*math.exp(r1*deltaTime)
		local e2 = co2*math.exp(r2*deltaTime)
		
		self.Position = e1 + e2 + goal
		self.Velocity = r1*e1 + r2*e2

	end
	return nil
end

return Spring