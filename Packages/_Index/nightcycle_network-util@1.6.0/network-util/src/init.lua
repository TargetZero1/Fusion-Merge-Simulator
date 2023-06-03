--!strict
local Package = script
local Packages = Package.Parent
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local _Maid = require(Packages.Maid)
local _Signal = require(Packages.Signal)

type Maid = _Maid.Maid

local NetworkUtil = {}
NetworkUtil.__index = NetworkUtil

local function getInstance(key: string, className: string, parent: Instance): any
	local cur = parent:FindFirstChild(key)
	if cur then
		if cur:IsA(className) then
			return cur
		else
			error(cur.ClassName .. " key [" .. key .. "] can't be reused as a " .. tostring(className))
		end
	else
		local newInst = Instance.new(className :: any)
		newInst.Name = key
		newInst.Parent = parent
		return newInst
	end
end

function NetworkUtil.getIfPlayerInGame(player: Player): boolean
	assert(RunService:IsServer())
	return Players:FindFirstChild(player.Name) ~= nil
end

function NetworkUtil.getRemoteEvent(key: string, parent: Instance?): RemoteEvent
	parent = parent or script
	assert(parent ~= nil)
	if RunService:IsServer() then
		return getInstance(key, "RemoteEvent", parent)
	else
		return parent:WaitForChild(key) :: any
	end
end

function NetworkUtil.getRemoteFunction(key: string, parent: Instance?): RemoteFunction
	parent = parent or script
	assert(parent ~= nil)
	if RunService:IsServer() then
		return getInstance(key, "RemoteFunction", parent)
	else
		return parent:WaitForChild(key) :: any
	end
end

function NetworkUtil.getBindableEvent(key: string, parent: Instance?): BindableEvent
	parent = parent or script
	assert(parent ~= nil)
	return parent:FindFirstChild(key) or getInstance(key, "BindableEvent", parent)
end

function NetworkUtil.getBindableFunction(key: string, parent: Instance?): BindableFunction
	parent = parent or script
	assert(parent ~= nil)
	return parent:FindFirstChild(key) or getInstance(key, "BindableFunction", parent)
end

function NetworkUtil.onClientEventAt(key: string, parent: Instance, func: (...any) -> nil): Maid
	assert(RunService:IsClient())
	local _maid = _Maid.new()
	if RunService:IsRunning() then
		local remEv = NetworkUtil.getRemoteEvent(key, parent)
		_maid:GiveTask(remEv.OnClientEvent:Connect(func))
	else
		local binEv = NetworkUtil.getBindableEvent(key, parent)
		_maid:GiveTask(binEv.Event:Connect(function(player: Player, ...)
			return func(...)
		end))
	end
	return _maid
end

function NetworkUtil.onClientEvent(key: string, func: (...any) -> nil): Maid
	return NetworkUtil.onClientEventAt(key, script, func)
end

function NetworkUtil.onServerEventAt(key: string, parent: Instance, func: (...any) -> nil): Maid
	assert(RunService:IsServer())
	local _maid = _Maid.new()
	if RunService:IsRunning() then
		local remEv = NetworkUtil.getRemoteEvent(key, parent)
		_maid:GiveTask(remEv.OnServerEvent:Connect(func))
	else
		local binEv = NetworkUtil.getBindableEvent(key, parent)
		_maid:GiveTask(binEv.Event:Connect(function(...)
			func(nil, ...)
		end))
	end
	return _maid
end

function NetworkUtil.onServerEvent(key: string, func: (...any) -> nil): Maid
	return NetworkUtil.onServerEventAt(key, script, func)
end

function NetworkUtil.fireServerAt(key: string, parent: Instance, ...): nil
	assert(RunService:IsClient())
	if RunService:IsRunning() then
		local remEv = NetworkUtil.getRemoteEvent(key, parent)
		remEv:FireServer(...)
	else
		local binEv = NetworkUtil.getBindableEvent(key, parent)
		binEv:Fire(...)
	end
	return nil
end

function NetworkUtil.fireServer(key: string, ...): nil
	return NetworkUtil.fireServerAt(key, script, ...)
end

function NetworkUtil.fireClientAt(key: string, parent: Instance, ...): nil
	assert(RunService:IsServer())
	if RunService:IsRunning() then
		local remEv = NetworkUtil.getRemoteEvent(key, parent)
		remEv:FireClient(...)
	else
		local binEv = NetworkUtil.getBindableEvent(key, parent)
		binEv:Fire(...)
	end
	return nil
end

function NetworkUtil.fireClient(key: string, ...): nil
	return NetworkUtil.fireClientAt(key, script, ...)
end

function NetworkUtil.fireAllClientsAt(key: string, parent: Instance, ...): nil
	assert(RunService:IsServer())
	if RunService:IsRunning() then
		local remEv = NetworkUtil.getRemoteEvent(key, parent)
		remEv:FireAllClients(...)
	else
		local binEv = NetworkUtil.getBindableEvent(key, parent)
		binEv:Fire(nil, ...)
	end
	return nil
end

function NetworkUtil.fireAllClients(key: string, ...): nil
	return NetworkUtil.fireAllClientsAt(key, script, ...)
end

function NetworkUtil.invokeServerAt<G>(key: string, parent: Instance, ...): G
	assert(RunService:IsClient())
	if RunService:IsRunning() then
		local remFun = NetworkUtil.getRemoteFunction(key, parent)
		return remFun:InvokeServer(...)
	else
		local binFun = NetworkUtil.getBindableFunction(key, parent)
		return binFun:Invoke(...)
	end
end

function NetworkUtil.invokeServer<G>(key: string, ...): G
	return NetworkUtil.invokeServerAt(key, script, ...)
end


function NetworkUtil.invokeClientAt<G>(key: string, parent: Instance, ...): G
	assert(RunService:IsServer())
	if RunService:IsRunning() then
		local remFun = NetworkUtil.getRemoteFunction(key, parent)
		return remFun:InvokeClient(...)
	else
		local binFun = NetworkUtil.getBindableFunction(key, parent)
		return binFun:Invoke(...)
	end
end

function NetworkUtil.invokeClient<G>(key: string, ...): G
	return NetworkUtil.invokeClientAt(key, script, ...)
end

function NetworkUtil.onClientInvokeAt<G>(key: string, parent: Instance, func: (...any) -> G): nil
	assert(RunService:IsClient())
	if RunService:IsRunning() then
		local remFun = NetworkUtil.getRemoteFunction(key, parent)
		remFun.OnClientInvoke = func
	else
		local binFun = NetworkUtil.getBindableFunction(key, parent)
		binFun.OnInvoke = function(player: Player, ...)
			return func(...)
		end
	end
	return nil
end

function NetworkUtil.onClientInvoke<G>(key: string, func: (...any) -> G): nil
	return NetworkUtil.onClientInvokeAt(key, script, func)
end

function NetworkUtil.onServerInvokeAt<G>(key: string, parent: Instance, func: (...any) -> G): nil
	assert(RunService:IsServer())
	if RunService:IsRunning() then
		local remFun = NetworkUtil.getRemoteFunction(key, parent)
		remFun.OnServerInvoke = func
	else
		local binFun = NetworkUtil.getBindableFunction(key, parent)
		binFun.OnInvoke = function(...)
			return func(nil, ...)
		end
	end
	return nil
end

function NetworkUtil.onServerInvoke<G>(key: string, func: (...any) -> G): nil
	return NetworkUtil.onServerInvokeAt(key, script, func)
end


return NetworkUtil
