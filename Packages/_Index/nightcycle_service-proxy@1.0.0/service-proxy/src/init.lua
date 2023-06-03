--!strict
return function<T>(getService: () -> T): T

	-- Create the metatable
	local meta = {}
	function meta:__index(key: any): any
		local service = getService() :: any
		return service[key]
	end

	function meta:__newindex(key: any, val: any?): nil
		local service = getService() :: any
		service[key] = val
		return nil
	end

	function meta:__call(...): any
		local service = getService() :: any
		return service(...)
	end

	-- Create the proxy table
	local proxy = {}
	setmetatable(proxy, meta)

	return (proxy :: any) :: T
end