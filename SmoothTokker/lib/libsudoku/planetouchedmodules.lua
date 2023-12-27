--[[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=]
<{
<{                            Planetouched Modules
<{ 
<{ An implementation of Lua's module system for use in RIFT addons.
<{ 
<{ As the RIFT addon environment does not allow direct file access, and all
<{ loading is done through toc directives, the usual Lua module facilities are
<{ not available. The intention here is to allow files set up as standard
<{ Lua 5.1 modules to be used in RIFT addons without changes -- at least if
<{ they don't need anything too fancy. This library adds module() and require()
<{ functions and the package table to the global environment. The system
<{ follows the specifications in the Lua 5.1 Reference Manual and chapter 15
<{ of Programming in Lua, 2nd ed. (available online at
<{     http://www.inf.puc-rio.br/~roberto/pil2/chapter15.pdf
<{ ) as closely as I was able given the specifics of the RIFT loading process.
<{
<{ Because there is no direct file access, the library relies on simply
<{ counting the number of times the module() function is called to figure out
<{ where to find the current file name in the RunOnStartup table in
<{ RiftAddon.toc. Thus, all files that make use of the module() function must
<{ follow consecutively after the Planetouched Modules file in that table. For
<{ simple setups, nothing more should be required. See the Configuration
<{ section below for options, if needed.
<{
--[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=][=[]=]]

--[=[  The RIFT Environment  ]=]--
local rift, private = ...
local toc = rift.toc


--[=[  Declarations  ]=]--
local insert = table.insert
local yield = coroutine.yield
local wrap = coroutine.wrap
local match = string.match
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local error = error
local assert = assert


--[=[  Configuration
**   If variables having the same names as those in this section appear in the
**   private addon storage or in RiftAddon.toc (which will be checked in that
**   order), the values found there will be used to override the defaults.
**
**   If a value for the table 'package' is found, it will be used as is. If you
**   are only interested in altering a small number of fields in that table, it
**   is probably better to set them individually.
]=]
-- The following variable must evaluate to the name of the Planetouched Modules
-- file as it appears in the RunOnStartup table in RiftAddon.toc.
local modulesfile = private.modulesfile or toc.modulesfile or
                 'planetouchedmodules.lua'

-- Names to be used for the RIFT environment variables. These will be set 
-- automatically in each module.
--local riftarg1 = private.riftarg1 or toc.riftarg1 or 'rift'
--local riftarg2 = private.riftarg2 or toc.riftarg2 or 'private'

-- Preloader searcher for package.loaders
-- Note that this is an important mechanism for the library even for packages
-- that make no use of preloaders.
local function preloadersearch(name)
  return package.preload[name]
end

-- Regular Lua file loader searcher for package.loaders
-- This is a no-op as require() can do nothing concerning a module RIFT has not
-- loaded except to set package.loaded[name] to true.
local function luafileloadersearch(name) end

-- package.loaders
-- There are only two loaders as the other two standard ones are for C libraries.
local loaders = private.loaders or toc.loaders or
                {preloadersearch, luafileloadersearch}

-- package.path
-- Note that the path entries must be ordered carefully as they are checked
-- against strings rather than an actual filesystem.
local luapath = private.luapath or toc.luapath or
                'lib\\?\\init.lua;lib\\?.lua;?\\init.lua;?.lua'

-- other package table fields
local preload = private.preload or toc.preload or {}
local loaded = private.loaded or toc.loaded or {}

-- Global package table
package = private.package or toc.package or {
  loaders = loaders,
  path = luapath,
  preload = preload,
  loaded = loaded,
  seeall = function (mod) return setmetatable(mod, {__index = _G}) end,
}


--[=[  Utility functions
**   Included here to make the library a single file.
]=]
-- Escapes all the non-alphanumeric characters in a string, including all the
-- characters regarded as 'magic' by the Lua pattern matcher.
local function escapemagic(str)
  return str:gsub('%W', '%%%0')
end

-- Escapes all the non-alphanumeric characters in a string, except that it
-- leaves alone character classes used by the Lua pattern matcher: %s %d etc
-- Assumes the zero-valued character \0 (which is not allowed in Lua patterns)
-- is not in the string.
local function escapemagic_pattern(str)
  return str:gsub('%%([acdlpsuwxzACDLPSUWXZ])', '\0%1'):gsub('[^%w%z]', '%%%0'):gsub('%z(.)', '%%%1')
end

local function split(str, sep)
  local t, p = {}, '[^' .. (escapemagic_pattern(sep) or '%s') .. ']+'
  for s in str:gmatch(p) do insert(t, s) end
  return t
end

local function nestget(tbl, keys)             -- tbl[keys[1]][keys[2]]...
  for _, k in ipairs(keys) do tbl = tbl[k]; if not tbl then break end end
  return tbl
end

local function nestput(tbl, keys, value)      -- tbl[keys[1]][keys[2]]... = value
  for i, k in ipairs(keys) do tbl[k] = i < #tbl and (tbl[k] or {}) or value; tbl = tbl[k] end
end

local function listiter(list)
  return wrap(function () for _, v in ipairs(list) do yield(v) end end)
end

local function listmap(mapfunc, tbl)
  for i, v in ipairs(tbl) do tbl[i] = mapfunc(v) end
  return tbl
end

local function ipairsafter(pred, list)
  local n, typ, iter = pred, type(pred), ipairs(list)
  if typ == 'function' then
    for i, v in iter, list, 0 do if pred(v) then n = i; break end end
  elseif typ ~= 'number' then
    error('Invalid predicate: expected function or number, not ' .. typ, 2)
  end
  return iter, list, n
end

local function equal_p(v)
  return function (test) return test == v end
end

local function any(itr)
  for v in itr do if v then return v end end
  return false
end

local function itermatch(str, patterns, matchfunc)
  matchfunc = matchfunc or match
  return wrap(function () for _, p in ipairs(patterns) do yield(matchfunc(str, p) or false) end end)
end


--[=[  Setup
**   This section processes the file names in RunOnStartup for ease of use by
**   module() and require(). Since RIFT runs on Windows, paths are normalized to use
**   backslashes as directory separators.
]=]
local function pathmatcher(path)
  path = escapemagic(path)
  local pattern, n = path:gsub('%%%?', '(.+)')
  assert(n == 1, 'Invalid path')
  return pattern
end

local pathmatchers = listmap(pathmatcher, split(package.path:gsub('/', '\\'), ';'))

local modnames = {}
for _, filepath in ipairsafter(equal_p(modulesfile), toc.RunOnStartup) do
  local name = any(itermatch(filepath, pathmatchers)):gsub('\\', '.')
  insert(modnames, name)
  modnames[name] = split(name, '.')
end


--[=[  require()
**   The mechanism of the require() function is pretty much exactly the same
**   as the standard one even if the loaders it calls are not. Indeed, the
**   code of the require() function proper is taken from Programming in Lua,
**   2nd ed., p 139. The relevant chapter of the 2nd edition is available
**   online at:     http://www.inf.puc-rio.br/~roberto/pil2/chapter15.pdf
]=]
local function findloader(name)
  for _, searcher in ipairs(package.loaders) do
    local loader = searcher(name)
    if type(loader) == 'function' then return loader end
  end
end

function require(name)
  if not package.loaded[name] then                -- module not loaded yet?
    local loader = findloader(name)
    if loader == nil then error("unable to load module " .. name, 2) end
    package.loaded[name] = true                   -- mark module as loaded
    local res = loader(name)                      -- initialize module
    if res ~= nil then package.loaded[name] = res end
  end
  return package.loaded[name]
end


--[=[  module()
**   For standard Lua modules, the require() function is effectively in
**   control: a file is loaded when requested, and all the effects of
**   running module() are expected to be apparent. In the RIFT environment,
**   however, require() can have no control over when a file is loaded, so it
**   is necessary for module() to deal with both the possibility its file may
**   have already been requested and with making the module's resources
**   available for future requests.
**
**   The scheme here is to:
**       1) make sure all the attributes of the internal module environment
**          are in place
**       2) check if the module has already been requested (that is, check
**          if package.loaded[name] has been set to true)
**       3) if it has been requested already, proceed to set up the attributes
**          external to the module (that is, the references in package.loaded
**          and the global environment)
**       4) if it has not been requested, add a function to package.preload
**          that will complete the module setup once require() is called.
]=]
local function finalize(mod)
  nestput(_G, modnames[mod._NAME], mod)
  package.loaded[mod._NAME] = mod
end

local startupindex = 0

function module(_, ...)
  startupindex = startupindex + 1
  local name = modnames[startupindex]
  local package = package
  local mod = {
    _NAME = name,
    _PACKAGE = name:match('^(.*%.)[^%.]+$'),
--    [riftarg1] = rift,
--    [riftarg2] = private,
  }
  mod._M = mod
  setfenv(2, mod)
  if type((...)) == 'function' then
    for i = 1, select('#', ...) do select(i, ...)(mod) end
  end
  if package.loaded[name] then
    finalize(mod)
  else
    package.preload[name] = function () finalize(mod) end
  end
end

