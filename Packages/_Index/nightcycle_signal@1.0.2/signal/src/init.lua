export type Signal = {
	new: () -> Signal,
	Wrap: (RBXScriptSignal) -> Signal,
	Is: (any?) -> boolean,
	Connect: (self: Signal, (...any) -> nil) -> SignalConnection,
	ConnectOnce: (self: Signal, (...any) -> nil) -> SignalConnection,
	GetConnections: (self: Signal) -> {[number]: SignalConnection},
	DisconnectAll: (self: Signal) -> nil,
	Fire: (self: Signal, ...any) -> nil,
	FireDeferred: (self: Signal, ...any) -> nil,
	Wait: (self: Signal) -> nil,
	Destroy: (self: Signal) -> nil,
}

export type SignalConnection = {
	Connected: boolean,
	Disconnect: (self: SignalConnection) -> nil,
	new: (Signal, (() -> any?)) -> SignalConnection,
}


-- License:                                                                   --
--   Licensed under the MIT license.                                          --
--                                                                            --
-- Authors:                                                                   --
--   stravant - July 31st, 2021 - Created the file.                           --
--   sleitnick - August 3rd, 2021 - Modified for Knit.                        --
--	CJ Oyer - Summer, 2022 - Made it Worse.							   --
-- -----------------------------------------------------------------------------

-- The currently idle thread to run the next handler on
local freeRunnerThread = nil

-- Function which acquires the currently idle handler runner thread, runs the
-- function fn on it, and then releases the thread, returning it to being the
-- currently idle one.
-- If there was a currently idle runner thread already, that's okay, that old
-- one will just get thrown and eventually GCed.
local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

-- Coroutine runner that we create coroutines of. The coroutine can be 
-- repeatedly resumed with functions to run followed by the argument to run
-- them with.
local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

-- Connection class
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn): SignalConnection
	local self = setmetatable({
		Connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
	self = self :: any
	return self
end


function Connection.Disconnect(self: any)
	if not self.Connected then return end
	self.Connected = false

	-- Unhook the node, but DON'T clear it. That way any fire calls that are
	-- currently sitting on this node will be able to iterate forwards off of
	-- it, but any subsequent fire calls will not hit it, and it will be GCed
	-- when no more fire calls are sitting on it.
	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
end

Connection.Destroy = Connection.Disconnect

-- Make Connection strict
setmetatable(Connection, {
	__index = function(_tb, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

local Signal = {}
Signal.__index = Signal


function Signal.new(): Signal
	local self = setmetatable({
		_handlerListHead = false,
		_proxyHandler = nil,
	}, Signal)
	return self
end

function Signal.Wrap(rbxScriptSignal)
	assert(typeof(rbxScriptSignal) == "RBXScriptSignal", "Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(rbxScriptSignal))
	local signal = Signal.new()
	signal._proxyHandler = rbxScriptSignal:Connect(function(...)
		signal:Fire(...)
	end)
	return signal
end

function Signal.Is(obj)
	return type(obj) == "table" and getmetatable(obj) == Signal
end

function Signal:Connect(fn)
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

function Signal:ConnectOnce(fn)
	local connection
	local done = false
	connection = self:Connect(function(...)
		if done then return end
		done = true
		connection:Disconnect()
		fn(...)
	end)
	return connection
end


function Signal:GetConnections()
	local items = {}
	local item = self._handlerListHead
	while item do
		table.insert(items, item)
		item = item._next
	end
	return items
end

function Signal:DisconnectAll()
	local item = self._handlerListHead
	while item do
		item.Connected = false
		item = item._next
	end
	self._handlerListHead = false
end

function Signal:Fire(...)
	local item = self._handlerListHead
	while item do
		if item.Connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end

function Signal:FireDeferred(...)
	local item = self._handlerListHead
	while item do
		task.defer(item._fn, ...)
		item = item._next
	end
end

function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local connection
	local done = false
	connection = self:Connect(function(...)
		if done then return end
		done = true
		connection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

function Signal:Destroy()
	self:DisconnectAll()
	local proxyHandler = rawget(self, "_proxyHandler")
	if proxyHandler then
		proxyHandler:Disconnect()
	end
end

-- Make signal strict
setmetatable(Signal, {
	__index = function(_tb, key)
		error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_tb, key, _value)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

return Signal
