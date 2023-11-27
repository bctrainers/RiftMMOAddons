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
--]]

local toc, data = ...
local AddonId = toc.identifier

--[[
	Tags currently used by Gadgets:
		bar - texture is suitable for use as a bar
		colorize - texture will work OK with a background colour
		circular - texture is circular (suitable for use in the Orb template)

	Usage:
		Library.Media.AddTexture(mediaId, addonId, fileName, tblTags)
			Adds a texture to the library.

		Library.Media.GetTexture(mediaId) -> AddonId, Filename, {Tags}
			Gets a texture from the library
			
		Library.Media.FindMedia(tag) -> mediaId[]
			Returns a list of media that matches the specified tag 

		Library.Media.SetTexture(mediaId)
			An extension to the Texture class, allows the setting of a media item
			
--]]

-- DECLARE NAMESPACES -------------------------------------------------------
Library = Library or {}
Library.Media = {}
-----------------------------------------------------------------------------

local textures = {}
local fonts = {}

-- Add a texture to the library.
-- Tags are simple strings, which are used to specify characteristics of the texture.
function Library.Media.AddTexture(mediaId, addonId, filename, arrayTags)
	local textureEntry = {}
	textureEntry.mediaId = mediaId
	textureEntry.addonId = addonId
	textureEntry.filename = filename
	textureEntry.tags = {}
	for idx,tag in ipairs(arrayTags) do
		textureEntry.tags[tag] = true
	end
	textures[mediaId] = textureEntry
end

function Library.Media.GetTexture(mediaId) --> textureEntry
	return textures[mediaId]
end

function Library.Media.FindMedia(tag) --> {textureEntry}, count
	local matched = {}
	local count = 0
	for k,v in pairs(textures) do
		if v.tags[tag] then 
			matched[k] = v
			count = count + 1
		end
	end
	return matched, count
end

function Library.Media.SetTexture(textureFrame, mediaId)
	local media = textures[mediaId]
	if media then
		textureFrame:SetTexture(media.addonId, media.filename)
	else
		error("LibMedia(SetMedia) - Unknown media id: " .. mediaId)
	end
end


-- Add a texture to the library.
-- Tags are simple strings, which are used to specify characteristics of the texture.
function Library.Media.AddFont(mediaId, addonId, filename)
	local fontEntry = {}
	fontEntry.mediaId = mediaId
	fontEntry.addonId = addonId
	fontEntry.filename = filename
	fonts[mediaId] = fontEntry
end

function Library.Media.GetFont(mediaId) --> fontEntry
	return fonts[mediaId]
end

function Library.Media.SetFont(frame, mediaId, fontSize)
	frame:SetFont(fonts[mediaId].addonId, fonts[mediaId].filename)
	if fontSize then
		frame:SetFontSize(fontSize)
	end
end

function Library.Media.ListFonts()
	return fonts
end

--- Returns a sorted list of available font names
function Library.Media.GetFontIds()
	local ret = {}
	for k, _ in pairs(fonts) do
		table.insert(ret, k)
	end
	table.sort(ret)
	return ret
end

Library.Media.AddFont("#Default", "Rift", "$Flareserif_medium")
