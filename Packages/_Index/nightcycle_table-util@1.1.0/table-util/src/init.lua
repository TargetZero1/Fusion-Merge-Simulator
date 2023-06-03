--!strict
--Services
--Packages
--Modules
--Types
--Constants

--Class
local Util = {}

export type Table = {[any]: any}
export type Dict<K, V> = {[K]: V}
export type List<V> = {[number]: V}

function Util.deepCopy(read: Table, log: {[Table]: Table}?): Table
	log = log or {}
	assert(log ~= nil)

	if log[read] then
		return log[read]
	else
		local out = {}
		log[read] = out
	
		for k, v in pairs(read) do
			if type(v) == "table" then
				out[k] = Util.deepCopy(v, log)
			else
				out[k] = v
			end
		end
	
		return out
	end
end

function Util.randomize<V>(list: List<V>, seed: number?): List<V>
	local rng = Random.new(seed or tick())
	local scores = {}
	for i, v in ipairs(list) do
		scores[v] = rng:NextNumber()
	end

	local out = table.clone(list)
	table.sort(out, function(a: V,b: V)
		return scores[a] < scores[b]
	end)

	return out
end

function Util.setFromPath<V>(tree: Dict<string, any | V>, path: string, value: V, indexer: string?): nil
	indexer = indexer or "/"
	local keys = string.split(path, indexer)
	if keys[1] == "" then
		table.remove(keys, 1)
	end
	assert(#keys > 0, "Bad path")
	local function write(source: Dict<string, any | V>, depth: number?): nil
		depth = depth or 1
		assert(depth ~= nil)
		local key = keys[depth]
		local val = source[key]
		if depth == #keys then
			source[key] = value 
		else
			if not val then
				val = {}
				source[key] = val
			end
			assert(val ~= nil)
			write(val :: any, depth + 1)
		end
		return nil
	end
	return write(tree)
end

function Util.getFromPath<V>(tree: Dict<string, any | V>, path: string, indexer: string?): V?
	indexer = indexer or "/"
	local keys = string.split(path, indexer)
	if keys[1] == "" then
		table.remove(keys, 1)
	end
	assert(#keys > 0, "Bad path")
	local function read(source: Dict<string, any | V>, depth: number?): V?
		depth = depth or 1
		assert(depth ~= nil)
		local key = keys[depth]
		if not key then return end
		local val = source[key]
		if depth == #keys then
			return val
		elseif val and type(val) == "table" then
			return read(val, depth + 1)
		end
		return nil
	end
	return read(tree)
end

function Util.deduplicate<V>(list: List<V>): List<V>
	local registry = {}
	for i, v in ipairs(list) do
		registry[v] = true
	end
	local out = {}
	for v, _ in pairs(registry) do
		table.insert(out, v)
	end
	return out
end

function Util.keys<K>(dict: Dict<K, any>): List<K>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, k)
	end
	return Util.deduplicate(list)
end

function Util.values<V>(dict: Dict<any, V>): List<V>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, v)
	end
	return Util.deduplicate(list)
end

function Util.reverse<V>(list: List<V>): List<V>
	local out = {}

	for i=#list, 1, -1 do
		table.insert(out, list[i])
	end

	return out
end

function Util.merge<K,V>(a: Dict<K,V>, b: Dict<K,V>): Dict<K,V>
	local out = {}
	for k, v in pairs(a) do
		out[k] = v
	end
	for k, v in pairs(b) do
		out[k] = v
	end
	return out
end

function Util.append<V>(a: List<V>, b: List<V>): List<V>
	local out = table.clone(a)
	for i, v in ipairs(b) do
		table.insert(out, v)
	end
	return out
end

return Util
