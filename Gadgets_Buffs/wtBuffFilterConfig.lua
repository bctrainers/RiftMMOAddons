--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.1
      Project Date (UTC)  : 2014-01-27T12:31:38Z
      File Modified (UTC) : 2012-09-17T07:30:04Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

data.BuffFilterPanel = {}

local FilterPanel = {}
local FilterPanel_mt = { __index = FilterPanel }

function data.CreateBuffFilterPanel(parent)

	local panel = {}
	setmetatable(panel, FilterPanel_mt)

	panel.chkShowMyBuffs = nil
	panel.chkShowUnitBuffs = nil
	panel.chkShowOtherBuffs = nil
	panel.chkShowMyDebuffs = nil
	panel.chkShowPermanentBuffs = nil
	panel.chkShowUnitDebuffs = nil
	panel.chkShowOtherDebuffs = nil
	panel.chkShowDebuffCurse = nil
	panel.chkShowDebuffDisease = nil
	panel.chkShowDebuffPoison = nil
	panel.chkShowDebuffOther = nil
	panel.radInclude = nil
	panel.radExclude = nil
	panel.txtFilters = nil
	panel.radGroupFilters = nil
	panel.chkRemaining = nil
	panel.txtRemaining = nil

	panel.frmConfigInner = UI.CreateFrame("Frame", "buffFilterPanel", parent)

	panel.chkShowMyBuffs = UI.CreateFrame("SimpleCheckbox", "chkShowMyBuffs", panel.frmConfigInner)
	panel.chkShowUnitBuffs = UI.CreateFrame("SimpleCheckbox", "chkShowUnitBuffs", panel.frmConfigInner)
	panel.chkShowOtherBuffs = UI.CreateFrame("SimpleCheckbox", "chkShowOtherBuffs", panel.frmConfigInner)
	panel.chkShowPermanentBuffs = UI.CreateFrame("SimpleCheckbox", "chkShowPermanentBuffs", panel.frmConfigInner)
	panel.chkShowMyDebuffs = UI.CreateFrame("SimpleCheckbox", "chkShowMyDebuffs", panel.frmConfigInner)
	panel.chkShowUnitDebuffs = UI.CreateFrame("SimpleCheckbox", "chkShowUnitDebuffs", panel.frmConfigInner)
	panel.chkShowOtherDebuffs = UI.CreateFrame("SimpleCheckbox", "chkShowOtherDebuffs", panel.frmConfigInner)
	panel.chkShowDebuffCurse = UI.CreateFrame("SimpleCheckbox", "chkShowDebuffCurse", panel.frmConfigInner)
	panel.chkShowDebuffDisease = UI.CreateFrame("SimpleCheckbox", "chkShowdebuffDisease", panel.frmConfigInner)
	panel.chkShowDebuffPoison = UI.CreateFrame("SimpleCheckbox", "chkShowDebuffPoison", panel.frmConfigInner)
	panel.chkShowDebuffOther = UI.CreateFrame("SimpleCheckbox", "chkShowDebuffOther", panel.frmConfigInner)
	panel.radInclude = UI.CreateFrame("SimpleRadioButton", "radInclude", panel.frmConfigInner)
	panel.radExclude = UI.CreateFrame("SimpleRadioButton", "radExclude", panel.frmConfigInner)
	panel.txtFilters = UI.CreateFrame("SimpleTextArea", "txtFilters", panel.frmConfigInner)
	panel.chkRemaining = UI.CreateFrame("SimpleCheckbox", "chkRemaining", panel.frmConfigInner)
	panel.txtRemaining = UI.CreateFrame("RiftTextfield", "txtRemaining", panel.frmConfigInner)
	
	panel.radGroupFilters = Library.LibSimpleWidgets.RadioButtonGroup("radGroupInclude")
	panel.radGroupFilters:AddRadioButton(panel.radInclude)
	panel.radGroupFilters:AddRadioButton(panel.radExclude)

	local lblRemaining = UI.CreateFrame("Text", "lblRemaining", panel.frmConfigInner)

	panel.chkShowMyBuffs:SetText("Buffs Cast by Player")
	panel.chkShowUnitBuffs:SetText("Buffs Cast by Unit")
	panel.chkShowOtherBuffs:SetText("Buffs Cast by Anyone Else")
	panel.chkShowPermanentBuffs:SetText("Permanent Buffs")
	panel.chkShowMyDebuffs:SetText("Debuffs Cast by Player")
	panel.chkShowUnitDebuffs:SetText("Debuffs Cast by Unit")
	panel.chkShowOtherDebuffs:SetText("Debuffs Cast by Anyone Else")
	panel.chkShowDebuffCurse:SetText("Curses")
	panel.chkShowDebuffDisease:SetText("Diseases")
	panel.chkShowDebuffPoison:SetText("Poisons")
	panel.chkShowDebuffOther:SetText("Other") 
	panel.radInclude:SetText("Include Only:")
	panel.radExclude:SetText("Exclude:")
	panel.txtFilters:SetText("")
	panel.chkRemaining:SetText("Less than ")
	panel.txtRemaining:SetText("120")
	lblRemaining:SetText("seconds remaining")

	panel.chkShowMyBuffs:SetChecked(true)
	panel.chkShowUnitBuffs:SetChecked(true)
	panel.chkShowOtherBuffs:SetChecked(true)
	panel.chkShowMyDebuffs:SetChecked(true)
	panel.chkShowUnitDebuffs:SetChecked(true)
	panel.chkShowOtherDebuffs:SetChecked(true)
	panel.chkShowDebuffCurse:SetChecked(true)
	panel.chkShowDebuffDisease:SetChecked(true)
	panel.chkShowDebuffPoison:SetChecked(true)
	panel.chkShowDebuffOther:SetChecked(true)
	panel.chkShowPermanentBuffs:SetChecked(true)
	panel.radExclude:SetSelected(true)
	panel.chkRemaining:SetChecked(false)

	panel.chkShowMyBuffs:SetPoint("TOPLEFT", panel.frmConfigInner, "TOPLEFT")
	panel.chkShowUnitBuffs:SetPoint("TOPLEFT", panel.chkShowMyBuffs, "BOTTOMLEFT", 0, 4)
	panel.chkShowOtherBuffs:SetPoint("TOPLEFT", panel.chkShowUnitBuffs, "BOTTOMLEFT", 0, 4)
	panel.chkShowPermanentBuffs:SetPoint("TOPLEFT", panel.chkShowOtherBuffs, "BOTTOMLEFT", 0, 4)
	panel.chkRemaining:SetPoint("TOPLEFT", panel.chkShowPermanentBuffs, "BOTTOMLEFT", 0, 4)
	panel.txtRemaining:SetPoint("CENTERLEFT", panel.chkRemaining, "CENTERRIGHT", 0, 0)
	panel.txtRemaining:SetBackgroundColor(0.2,0.2,0.2,1.0)
	panel.txtRemaining:SetWidth(50)
	lblRemaining:SetPoint("CENTERLEFT", panel.txtRemaining, "CENTERRIGHT", 0, 0)	

	panel.chkShowMyDebuffs:SetPoint("LEFT", panel.frmConfigInner, "CENTERX")
	panel.chkShowMyDebuffs:SetPoint("TOP", panel.chkShowMyBuffs, "TOP")
	panel.chkShowUnitDebuffs:SetPoint("TOPLEFT", panel.chkShowMyDebuffs, "BOTTOMLEFT", 0, 4)
	panel.chkShowOtherDebuffs:SetPoint("TOPLEFT", panel.chkShowUnitDebuffs, "BOTTOMLEFT", 0, 4)

	panel.chkShowDebuffCurse:SetPoint("TOPLEFT", panel.chkShowOtherDebuffs, "BOTTOMLEFT", 0, 4)
	panel.chkShowDebuffDisease:SetPoint("TOPLEFT", panel.chkShowDebuffCurse, "TOPLEFT", 100, 0)
	panel.chkShowDebuffPoison:SetPoint("TOPLEFT", panel.chkShowDebuffCurse, "BOTTOMLEFT", 0, 4)
	panel.chkShowDebuffOther:SetPoint("TOPLEFT", panel.chkShowDebuffDisease, "BOTTOMLEFT", 0, 4)

	panel.radInclude:SetPoint("TOPLEFT", panel.chkShowPermanentBuffs, "BOTTOMLEFT", 0, 28)
	panel.radExclude:SetPoint("TOPLEFT", panel.radInclude, "TOPLEFT", 100, 0)

	panel.txtFilters:SetPoint("TOPLEFT", panel.radInclude, "BOTTOMLEFT", 0, 4)
	panel.txtFilters:SetPoint("BOTTOMRIGHT", panel.frmConfigInner, "BOTTOMRIGHT", 0, 0)
	panel.txtFilters:SetBackgroundColor(0.2, 0.2, 0.2, 1.0)
	panel.txtFilters:SetBorder(1, 0.7,0.7,0.3,1)

	return panel
end


function FilterPanel.WriteToConfiguration(panel, config)

	config.showMyBuffs = panel.chkShowMyBuffs:GetChecked()
	config.showUnitBuffs = panel.chkShowUnitBuffs:GetChecked()
	config.showOtherBuffs = panel.chkShowOtherBuffs:GetChecked()
	config.showPermanentBuffs = panel.chkShowPermanentBuffs:GetChecked()
	config.showMyDebuffs = panel.chkShowMyDebuffs:GetChecked()
	config.showUnitDebuffs = panel.chkShowUnitDebuffs:GetChecked()
	config.showOtherDebuffs = panel.chkShowOtherDebuffs:GetChecked()
	config.showDebuffCurses = panel.chkShowDebuffCurse:GetChecked()
	config.showDebuffDiseases = panel.chkShowDebuffDisease:GetChecked()
	config.showDebuffPoisons = panel.chkShowDebuffPoison:GetChecked()
	config.showDebuffOther = panel.chkShowDebuffOther:GetChecked()

	config.limitRemaining = panel.chkRemaining:GetChecked()
	config.limitRemainingSeconds = tonumber(panel.txtRemaining:GetText()) or 0
	
	if config.limitRemainingSeconds == 0 then config.limitRemaining = false end

	if panel.radInclude:GetSelected() then
		config.filterType = "include"
	else
		config.filterType = "exclude"
	end
	
	config.filters = 
	{
	}

	local filterlist = panel.txtFilters:GetText():wtSplit("\r")
	for idx, buff in ipairs(filterlist) do
		local blBuff = buff:wtTrim():lower()
		if blBuff:len() > 0 then
			config.filters[blBuff] = true
		end
	end
		
	return config 
end

function FilterPanel.ReadFromConfiguration(panel, config)

	panel.chkShowMyBuffs:SetChecked(WT.Utility.ToBoolean(config.showMyBuffs)) 
	panel.chkShowUnitBuffs:SetChecked(WT.Utility.ToBoolean(config.showUnitBuffs))
	panel.chkShowOtherBuffs:SetChecked(WT.Utility.ToBoolean(config.showOtherBuffs))
	panel.chkShowPermanentBuffs:SetChecked(WT.Utility.ToBoolean(config.showPermanentBuffs)) 
	panel.chkShowMyDebuffs:SetChecked(WT.Utility.ToBoolean(config.showMyDebuffs)) 
	panel.chkShowUnitDebuffs:SetChecked(WT.Utility.ToBoolean(config.showUnitDebuffs)) 
	panel.chkShowOtherDebuffs:SetChecked(WT.Utility.ToBoolean(config.showOtherDebuffs)) 
	panel.chkShowDebuffCurse:SetChecked(WT.Utility.ToBoolean(config.showDebuffCurses)) 
	panel.chkShowDebuffDisease:SetChecked(WT.Utility.ToBoolean(config.showDebuffDiseases)) 
	panel.chkShowDebuffPoison:SetChecked(WT.Utility.ToBoolean(config.showDebuffPoisons))
	panel.chkShowDebuffOther:SetChecked(WT.Utility.ToBoolean(config.showDebuffOther)) 

	panel.chkRemaining:SetChecked(WT.Utility.ToBoolean(config.limitRemaining))
	panel.txtRemaining:SetText(tostring(config.limitRemainingSeconds or "")) 

	if config.filterType == "include" then
		panel.radInclude:SetSelected(true)
	else
		panel.radExclude:SetSelected(true)
	end

	local filterText = ""
	for filter, active in pairs(config.filters or {}) do
		if active then filterText = filterText .. filter .. "\r" end
	end 
	panel.txtFilters:SetText(filterText)

end

