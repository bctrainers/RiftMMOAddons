--[=[
**   Smooth Tokker (RIFT addon) - colors.lua
**
**   No, I don't know why I decided to make colors this way either.
**   If you want things simple, ignore the generators and just make
**   color functions. colorgeneratorfactory(r, g, b, a) will return
**   a function that will dump the four values into an argument list
**   for you.
**
**   The main function here is colorgeneratorfactory(). Usage info:
**
**   colorgeneratorfactory(r, g, b[, a[, false]])  ->  color function
**      a is optional and defaults to 1. The fifth argument, if present
**      must evaluate to false for a color function to be returned.
**
**      A color function can be called as follows:
**         colorfunc()       ->  r, g, b, a
**         colorfunc(a1)     ->  r, g, b, a1
**         colorfunc(false)  ->  r, g, b
**
**   colorgeneratorfactory(r, g, b, a, true)  ->  color generator
**      a can be nil and will default to 1. Color generators are based
**      on the HSL (hue/saturation/lightness) color representation. (See
**      https://en.wikipedia.org/wiki/HSL_and_HSV for more info.) The 
**      color stored in the generator will have the hue and saturation
**      of the RGB values provided, but with lightness normalized to .5.
**      Calling the generator produces a color function that works the
**      same as the one shown above.
**
**      A color generator can be called as follows:
**         colorgen([L[, a]])  ->  color function
**      Called with no arguments it returns the normalized color with
**      lightness .5. If L is provided, the lightness will be adjusted to
**      that value. A new alpha value may be assigned with the second
**      argument.
--]=]

local rift, privy, __test__ = ...

local error = error
local min = math.min
local max = math.max
local format = string.format

local utils = require 'utils'
local interval_p = utils.interval_p
local isnumber = utils.isnumber

local colorvalued = interval_p(0, 1)
local function iscolor(v) return isnumber(v) and colorvalued(v) end

local function swap(tbl, i, j) tbl[i], tbl[j] = tbl[j], tbl[i] end
local function lerp(a, b, t) return a + t*(b - a) end

local function normalizelightness(r, g, b)
-- Terminology follows the article (as it appeared in May, 2017):
--    https://en.wikipedia.org/wiki/HSL_and_HSV
-- Using a chroma/lightness map, projects a line through the color value
-- onto the plane lightness = .5
-- Returns the 3 channels of the normalized color and the lightness L of 
-- the original color
  local M, m = max(r, g, b), min(r, g, b)
  if M == m then return .5, .5, .5, M end
  local keys, values = {'r', 'g', 'b'}, {r = r, g = g, b = b}
  if     r == M then                   if g == m then swap(keys, 2, 3) end
  elseif r == m then swap(keys, 1, 3); if g == M then swap(keys, 1, 2) end
  else               swap(keys, 1, 2); if g == m then swap(keys, 1, 3) end
  end
  local L = (M + m)/2
  local M1 = L > .5 and (1 - m)/(2 - M - m) or M/(M + m)
  values[keys[1]] = M1
  local m1 = L > .5 and (1 - M)/(2 - M - m) or m/(M + m)
  values[keys[3]] = m1
  values[keys[2]] = ((values[keys[2]] - m)/(M - m)) * (M1 - m1) + m1
  return values.r, values.g, values.b, L
end

local function colorgen_errorcheck(name, channel)
  if not iscolor(channel) then
    error(name .. ' component must be a number between 0 and 1, not ' .. tostring(channel), 2)
end end

local function colorgeneratorfactory(r, g, b, a1, generator)
  colorgen_errorcheck('Red', r); colorgen_errorcheck('Green', g); colorgen_errorcheck('Blue', b)
  local original_L
  r, g, b, original_L = normalizelightness(r, g, b)
  local function colorgen(lightness, a2)
    local r, g, b, a = r, g, b, a2 or a1 or 1
    if lightness then
      local pole = lightness < .5 and 0 or 1
      local t = lightness < .5 and 2*(.5 - lightness) or 2*(lightness - .5)
      r, g, b = lerp(r, pole, t), lerp(g, pole, t), lerp(b, pole, t)
    end
    return function (alpha)
      if alpha ~= false then
        return r, g, b, isnumber(alpha) and alpha or a
      else
        return r, g, b
      end
    end
  end
  return generator and colorgen or colorgen(original_L, a1)
end

privy.colorgenerators = {
  factory = colorgeneratorfactory,
  achromatic = colorgeneratorfactory(.5, .5, .5, 1, true),
  red = colorgeneratorfactory(1, 0, 0, 1, true),
  yellow = colorgeneratorfactory(1, 1, 0, 1, true),
  green = colorgeneratorfactory(0, 1, 0, 1, true),
  cyan = colorgeneratorfactory(0, 1, 1, 1, true),
  blue = colorgeneratorfactory(0, 0, 1, 1, true),
  magenta = colorgeneratorfactory(1, 0, 1, 1, true),
}

local colorgen = privy.colorgenerators
local black = colorgen.achromatic(0)
local white = colorgen.achromatic(1)
local grey15 = colorgen.achromatic(.15)
local grey70 = colorgen.achromatic(.70)
local grey90 = colorgen.achromatic(.90)
local blue40 = colorgen.blue(.40)
local blue80 = colorgen.blue(.80)
local red35 = colorgen.red(.35)

privy.colorgenerators = colorgenerators
privy.colors = {black = black, white = white,
                grey70 = grey70, grey90 = grey90,
                grey15 = grey15, blue40 = blue40,
                blue80 = blue80, red35 = red35, }

privy.cellcolors = {
  default = colorgen.achromatic(0, .6),
  hold = colorgen.achromatic(.2, .6),
  focus = colorgen.achromatic(0, 0),
  mouseoverglow = {colorG = 1, colorR = 1},
  focusglow = {colorG = 1, colorR = 1, blurX = 4, blurY = 4, strength = 4, knockout = true},
}

privy.textcolors = {
  fonttag = function (text, color) return format('<font color="%s">%s</font>', color, text) end,
  hello = '#9ff07f',
  command = '#7f5fff',
  header = '#bf9fff',
  empty = '#1f1f1f',
  hold = '#9f9fff',
}

if __test__ then
  __test__{
    colorvalued = colorvalued,
    iscolor = iscolor,
    swap = swap,
    lerp = lerp,
    normalizelightness = normalizelightness,
    colorgen_errorcheck = colorgen_errorcheck,
    colorgeneratorfactory = colorgeneratorfactory,
    colorgen = colorgen,
    colors = colors,
    cellcolors = cellcolors,
  }
end


