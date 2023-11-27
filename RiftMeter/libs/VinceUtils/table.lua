local Info, Addon = ...


function Addon.all(t, f)
	for k, v in next, t do
		if not f(v, k) then
			return false
		end
	end
	return true
end

function Addon.any(t, f)
	for k, v in next, t do
		if f(v, k) then
			return true
		end
	end
	return false
end

function Addon.map(t, f)
	local result = {}
	for k, v in next, t do
		local newValue, newKey = f(v, k)
		result[newKey or k] = newValue
	end
	return result
end
Addon.collect = Addon.map

function Addon.mapi(t, f)
	local result = {}
	for k, v in next, t do
		result[#result + 1] = f(v, k)
	end
	return result
end
Addon.collecti = Addon.mapi

function Addon.each(t, f)
	for k, v in next, t do
		f(v, k)
	end
	return t
end

function Addon.eachi(t, f)
	for i = 1, #t do
		f(t[v], i)
	end
	return t
end

function Addon.select(t, f)
	local selected = {}
	for k, v in next, t do
		if f(v, k) then
			selected[k] = v
		end
	end
	return selected
end

function Addon.selecti(t, f)
	local selected = {}
	for i = 1, #t do
		if f(v, i) then
			selected[#selected] = v
		end
	end
	return selected
end

function Addon.inject(t, f, initial)
	initial = initial or select(next(t))
	for k, v in next, t do
		f(initial, v, k)
	end
	return initial
end
Addon.reduce = Addon.inject

function Addon.count(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end

function Addon.tolist(t)
	local list = {}
	for _, v in next, t do
		list[#list + 1] = v
	end
	return list
end

function deepcopy(t)
	if type(t) == "table" then
		local copy = {}
		for k, v in next, t do
			copy[deepcopy(k)] = deepcopy(v)
		end
		return copy
	else
		return t
	end
end
Addon.deepcopy = deepcopy

function Addon.extend(...)
	local args = {...}
	for i = 2, #args do
		for key, value in pairs(args[i]) do
			args[1][key] = value
		end
	end
	return args[1]
end

function deepExtend(...)
	local args = {...}
	for i = 2, #args do
		for key, value in pairs(args[i]) do
			if type(value) == "table" then
				deepExtend(args[1][key], value)
			else
				args[1][key] = value
			end
		end
	end
	return args[1]
end
Addon.deepExtend = deepExtend
