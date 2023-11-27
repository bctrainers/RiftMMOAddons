function iif (condition, trueExpression, falseExpression)
	if condition then  
		return trueExpression
	else  
		return falseExpression
	end  
end

function colorRGBtoHEX (rgb)
	return string.format("%02X%02X%02X", rgb[1], rgb[2], rgb[3])
end

function colorRGBtoHSB (rgb)
	local ext = { mn = math.min(rgb[1], rgb[2], rgb[3]), mx = math.max(rgb[1], rgb[2], rgb[3]) }
	ext.delta = 60 / (ext.mx - ext.mn)
	return { h = iif(ext.mn == ext.mx, 0, iif(ext.mx == rgb[1], (rgb[2] - rgb[3]) * ext.delta + iif(rgb[2] >= rgb[3], 0, 360), iif(ext.mx == rgb[2], (rgb[3] - rgb[1]) * ext.delta + 120, (rgb[1] - rgb[2]) * ext.delta + 240))),
		 s = 100 * iif(ext.mx == 0, 0, 1 - ext.mn / ext.mx),
		 b = ext.mx / 2.55 }
end

function colorHSBtoRGB (value)
	local Hi = math.floor(value.h / 60)
	local f = value.h / 60 - Hi
	local sep = { p = value.b * (100 - value.s) * 0.0255, q = value.b * (100 - value.s * f) * 0.0255, t = value.b * (100 - (1 - f) * value.s) * 0.0255, v = value.b * 2.55 }
	return { math.floor(iif(Hi == 0 or Hi == 5, sep.v, iif(Hi == 1, sep.q, iif(Hi == 4, sep.t, sep.p)))),
		 math.floor(iif(Hi == 1 or Hi == 2, sep.v, iif(Hi == 3, sep.q, iif(Hi == 0, sep.t, sep.p)))),
		 math.floor(iif(Hi == 3 or Hi == 4, sep.v, iif(Hi == 5, sep.q, iif(Hi == 2, sep.t, sep.p)))) }
end

function colorRGBtoGradient (rgb, position)
	return { r = rgb[1] / 255, g = rgb[2] / 255, b = rgb[3] / 255, position = position }
end

function TimeToString (value)
	return iif(value <= 0, "", iif(value < 60, value .. MinionSender.Data.Language.Current.InfoSecond, 
		iif(value < 3600, math.ceil(value / 60) .. MinionSender.Data.Language.Current.InfoMinute,
		math.ceil(value / 3600) .. MinionSender.Data.Language.Current.InfoHour)))
end

function tableLength (T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function tableFirst (T)
	local idx
	for k, v in pairs(T) do if idx == nil or idx > k then idx = k end end
	return idx
end

function tableLast (T)
	local idx
	for k, v in pairs(T) do if idx == nil or idx < k then idx = k end end
	return idx
end

function tableCopy (T)
	local C = { }
	for ik, iv in pairs(T) do
		if type(iv) == "table" then
			C[ik] = tableCopy(iv)
		else
			C[ik] = iv
		end
	end
	return C
end

function pairsByKeys (T)
	local a = {}
	for n in pairs(T) do table.insert(a, n) end
	table.sort(a)

	local i = 0
	local iterator = function ()
		i = i + 1
		if a[i] == nil then return nil else return a[i], T[a[i]] end
	end

	return iterator
end

function tableGetByPath (T, P)
	if type(P) ~= "table" then if P:sub(1, 1) == "#" then P = stringSplit(P:sub(2)) else P = { P } end end
	for k, v in pairs(P) do
		if v == nil or T == nil then return nil end
		if tonumber(v) ~= nil then T = T[tonumber(v)] else T = T[v] end
	end
	return T
end

function tableSetByPath (T, P, V)
	if type(P) ~= "table" then if P:sub(1, 1) == "#" then P = stringSplit(P:sub(2)) else P = { P } end end
	for k, v in pairs(P) do
		if v == nil or T == nil then return end
		if k == #P then T[v] = V end
		if tonumber(v) ~= nil then T = T[tonumber(v)] else T = T[v] end
	end
end

function getPath (P, R)
	local path = "#"
	if type(P) ~= "table" then P = { P } end

	for k, v in pairs(P) do
		if k > (#P - (R or 0)) then break end
		if k > 1 then path = path .. "." end
		path = path .. v
	end

	return path
end

function stringSplit (S)
	local f = {}
	S:gsub("([^.]+)[.]*", function(c) table.insert(f, c) end)
	return f
end