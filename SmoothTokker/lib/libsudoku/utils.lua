
local pairs = pairs
local ipairs = ipairs
local type = type
local tonumber = tonumber
local assert = assert
local error = error
local floor = math.floor
local insert = table.insert
local concat = table.concat
local yield = coroutine.yield
local wrap = coroutine.wrap

module(...) --, package.seeall)

--print('Loading ' .. _NAME)


--[=[  Data Types  ]=]--

function is(obj, typename) return type(obj) == typename end
function isint(n) return type(n) == 'number' and n == floor(n) end
function isnumber(obj) return type(obj) == 'number' end
function istable(obj) return type(obj) == 'table' end
function isstring(obj) return type(obj) == 'string' end
function isfunction(obj) return type(obj) == 'function' end
function isnil(obj) return obj == nil end


--[=[  Numbers  ]=]--

function interval_p(lo, hi, open_lo, open_hi)
  if open_lo then
    if open_hi then
      return function (v) return lo < v and v < hi end
    else
      return function (v) return lo < v and v <= hi end
    end
  else
    if open_hi then
      return function (v) return lo <= v and v < hi end
    else
      return function (v) return lo <= v and v <= hi end
    end
  end
end

--[=[  Factory Iterators  ]=]--

function constant(v, n)       -- returns the value v indefinitely (or n times)
  if n then
    return wrap(function () for _ = 1, n do yield(v) end end)
  else
    return wrap(function () while true do yield(v) end end)
  end
end

function tables(n)       -- returns new empty tables indefinitely (or n times)
  if n then 
    return wrap(function () for _ = 1, n do yield{} end end)
  else
    return wrap(function () while true do yield{} end end)
  end
end

function count(n)       -- returns consecutive integers indefinitely starting at 1 (or n)
  n = n or 1
  assert(isint(n), 'type error: expected integer')
  return wrap(function() while true do yield(n); n = n + 1 end end)
end

function irange(n, m, step)
-- irange(n) -> integers from 1 to floor(n)
-- irange(n, m[, step]) -> numbers from n to m with interval step (default 1)
  step = step or 1
  if not m then n, m = 1, n end
  return wrap(function () for i = n, m, step do yield(i) end end)
end


--[=[  Mapping Iterators  ]=]--

-- These functions need work, will fail if used with ipairs.

function imap(mapfunc, itr, mode)
  if not mode or mode == 'k' then
    return wrap(function () for v in itr do yield(mapfunc(v)) end end)
  elseif mode == 'v' then
    return wrap(function () for _, v in itr do yield(mapfunc(v)) end end)
  elseif mode == 'kv' then
    return wrap(function () for k, v in itr do yield(mapfunc(k, v)) end end)
  end
end

function imappairs(mapfunc, itr, mode)
  if not mode then
    return wrap(function () for v in itr do yield(v, mapfunc(v)) end end)
  elseif mode == 'k' then
    return wrap(function () for k, v in itr do yield(k, mapfunc(v)) end end)
  elseif mode == 'v' then
    return wrap(function () for _, v in itr do yield(v, mapfunc(v)) end end)
  elseif mode == 'kv' then
    return wrap(function () for k, v in itr do yield(k, mapfunc(k, v)) end end)
  end
end


--[=[  Tables  ]=]--

function map(mapfunc, tbl)        -- applies mapfunc to tbl in place
  for k, v in pairs(tbl) do tbl[k] = mapfunc(v) end
  return tbl
end
  
function totable(iter)
  local t = {}
  for v in iter do insert(t, v) end
  return t
end

function inittable(n, v)
  assert(n and v ~= nil)
  return totable(constant(v, n))
end


--[=[  Strings  ]=]--

function iterstring(str, mapfunc)
  if mapfunc then
    return wrap(function () for c in str:gmatch('.') do yield(mapfunc(c)) end end)
  else
    return wrap(function () for c in str:gmatch('.') do yield(c) end end)
  end
end

function explodestring(str, mapfunc)
  return totable(iterstring(str, mapfunc))
end

function escapemagic(str)
-- Escapes all the non-alphanumeric characters in a string, including all the
-- characters regarded as 'magic' by the Lua pattern matcher.
  return str:gsub('%W', '%%%0')
end

function escapemagic_pattern(str)
-- Escapes all the non-alphanumeric characters in a string, except that it
-- leaves alone character classes used by the Lua pattern matcher: %s %d etc
-- Assumes the zero-valued character \0 (which is not allowed in Lua patterns)
-- is not in the string.
  return str:gsub('%%([acdlpsuwxzACDLPSUWXZ])', '\0%1'):gsub('[^%w%z]', '%%%0'):gsub('%z(.)', '%%%1')
end

function split(str, sep)
-- Returns a table containing each sequence of characters in str which contains
-- none of the characters in sep. sep may contain standard Lua string matching
-- classes and defaults to '%s' (whitespace).
-- split('-', '-')  ->  {}
  local t, p = {}, '[^' .. (sep and escapemagic_pattern(sep) or '%s') .. ']+'
  for s in str:gmatch(p) do insert(t, s) end
  return t
end

function split_strict(str, sep)
-- Returns a table containing all the sequences in str separated one or more
-- characters in sep, including empty strings at the beginning or end. If
-- str is the empty string, returns an empty table. sep may contain standard
-- Lua string matching classes and defaults to '%s' (whitespace).
-- split_strict('-', '-')  ->  {'', ''}
  local t = {}
  if str ~= '' then
    sep = sep and escapemagic_pattern(sep) or '%s'
    insert(t, str:match('^[^' .. sep .. ']*'))
    for s in str:gmatch('[' .. sep .. ']+([^' .. sep .. ']*)') do insert(t, s) end
  end
  return t
end

function trim(str)      -- trim leading and trailing whitespace
  return (str:gsub('^%s*(.-)%s*$', '%1'))
end

function strip(str)     -- strip out all whitespace
  return (str:gsub('%s+', ''))
end

function njoin(str, n, sep)
  return concat(inittable(n, str), sep or '')
end

function cut(str)       -- cut a string at the first occurrence of whitespace
-- cut(str)  ->  front, rest
-- front is all characters in string before the first occurrence of whitespace
-- rest is the remainder of the string trimmed of any initial whitespace
-- cut('foo    bar zgwort')  ->  'foo', 'bar zgwort'
-- cut('foo  ')  ->  'foo', ''
-- cut('  bar  ') -> '', 'bar  '
  return str:match('^(%S*)%s*(.*)$')
end

function digits(base)
-- returns a string containing, in order, the digits tonumber() would expect
-- to represent numbers in the given base, assuming 2 <= base <= 36
   return ('0123456789abcdefghijklmnopqrstuvwxyz'):sub(1, base)
end

function digit(n)
-- returns the digit character for n, assuming a base > n
-- in other words: if b > n then tonumber(digit(n), b) returns n
   return ('0123456789abcdefghijklmnopqrstuvwxyz'):sub(n, n)
end

function digit_mod(base)
  return function (n) return digit(n % base) end
end

function condense(str, chars, discards)
-- if discards is true, all occurrences of characters in chars will be removed from str
-- if discards is false, all characters not in chars are removed from str
-- Lua predefined character classes ('%d', '%s', etc) may be included in chars
  local template = discards and '[%s]+' or '[^%s]+'
  return (str:gsub(format(template, escapemagic_pattern(chars)), ''))
end

--[=[  Miscellaneous  ]=]--

function chain(sources, tableiter)
  tableiter = tableiter or ipairs
  return wrap(function()
    for _, s in ipairs(sources) do
      if type(s) == 'table' then
        for _, v in tableiter(s) do yield(v) end
      elseif type(s) == 'function' then
        for v in s do yield(v) end
      else
        error('sources must be tables or iterators')
  end end end)
end

function openpackage (ns, _G)
  for n,v in pairs(ns) do
    if not n:match('^_%u+$') then
      if _G[n] ~= nil then
        error("name clash: " .. n .. " is already defined")
      end
      _G[n] = v
    end
  end
end


--[=[  Slightly Baroque Table Printer  ]=]--

local TS_WHAT = ''
local TS_RECURSE = false

local function _tablestring(v, iter, sort)
  if type(v) ~= 'table' then return tostring(v) end
  if not next(v) then return '{}' end

  local pieces = iter(v, {})
  if sort then table.sort(pieces) end
  pieces[1] = '{' .. pieces[1]
  pieces[#pieces] = pieces[#pieces] .. '}'
  return concat(pieces, ', ')
end

function tablestring(tbl, what, recurse, nosort)
  what = what or TS_WHAT
  recurse = recurse or TS_RECURSE
  local sort = not nosort
  local convert, iter

  if recurse then
    local seen = {}
    function convert(v)
      if type(v) ~= 'table' or seen[v] then
        return tostring(v)
      end
      seen[v] = true
      return _tablestring(v, iter, sort)
    end
  else
    convert = tostring
  end

  if what =='k' then
    function iter(t, pieces)
      for k in pairs(t) do insert(pieces, convert(k)) end
      return pieces
    end
  elseif what == 'v' then
    function iter(t, pieces)
      for _, v in pairs(t) do insert(pieces, convert(v)) end
      return pieces
    end
  else
    function iter(t, pieces)
      for k, v in pairs(t) do insert(pieces, convert(k) .. ':' .. convert(v)) end
      return pieces
    end
  end

  return _tablestring(tbl, iter, sort)
end

function tableprint(tbl, what, recurse, nosort) print(tablestring(tbl, what, recurse, nosort)) end
tp = tableprint
