--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-06-11T06:19:15Z (Wildtide)
      -----------------------------------------------------------------     

	Usage:

		Declaring Translations:
			Library.Translate.Fr({Hello = "Bonjour"})
			Library.Translate.Load(
			{
				Hello = {
					en="Hello",
					fr="Bonjour",
				},
				Goodbye = {
					en="Goodbye",
					fr="Au Revoir",
				},
			})

		Fetching Translations:
			phrase = Library.Translate.Hello

--]]

-- DECLARE NAMESPACES -------------------------------------------------------
Library = Library or {}
Library.Translate = {}
-----------------------------------------------------------------------------

local ERROR_ON_MISSING_PHRASE = false

local translate = Library.Translate

-- "English", "French", "German", "Korean", "Russian"
local language = Inspect.System.Language()
local lang = "en"
if language == "French" then lang = "fr" end
if language == "German" then lang = "de" end
if language == "Korean" then lang = "ko" end
if language == "Russian" then lang = "ru" end

-- The dictionaries hold the phrase -> string lookups by language
local dictionary = {}
dictionary.en = {}
dictionary.fr = {}
dictionary.de = {}
dictionary.ko = {}
dictionary.ru = {}

translate.Language = lang

local lookupSelected = dictionary[lang]
local lookupDefault = dictionary["en"]

local function ReadPhrase(tbl, id)
	if ERROR_ON_MISSING_PHRASE and not lookupSelected[id] then error("Missing translation: (" .. lang .. ") " .. id) end
	return (lookupSelected[id]) or (lookupDefault[id]) or (id)
end

function translate.Load(tbl)
	for id, phraseTable in pairs(tbl) do
		for lang, text in pairs(phraseTable) do
			dictionary[lang][id] = text
		end
	end
end

function translate.Set(lang, key, phrase)
	if not dictionary[lang] then error("Unrecognised language code: " .. lang) end
	if not key then error("No phrase key provided for translation") end
	dictionary[lang][key] = phrase
end

-- Shortcut functions for quickly setting up translations
-- e.g. Library.Translate.FR("hello", "Bonjour")

function translate.En(tbl)
	if not tbl then return end
	for id, text in pairs(tbl) do
		translate.Set("en", id, text)
	end
end
function translate.De(tbl)
	if not tbl then return end
	for id, text in pairs(tbl) do
		translate.Set("de", id, text)
	end
end
function translate.Fr(tbl)
	if not tbl then return end
	for id, text in pairs(tbl) do
		translate.Set("fr", id, text)
	end
end
function translate.Ko(tbl)
	if not tbl then return end
	for id, text in pairs(tbl) do
		translate.Set("ko", id, text)
	end
end
function translate.Ru(tbl)
	if not tbl then return end
	for id, text in pairs(tbl) do
		translate.Set("ru", id, text)
	end
end

setmetatable(translate, { __index=ReadPhrase })
