-- There is no copyright on this code

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
-- associated documentation files (the "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is furnished to do so.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
-- NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--
-- Global variables
--
local addon, Completionist = ...

local function Show(self, page1)
	if page1 == true then
		self.page1:SetVisible(true)
		self.page2:SetVisible(false)
	else
		self.page1:SetVisible(false)
		self.page2:SetVisible(true)
	end
end

local function Close(self)
	self.page1:SetVisible(false)
	self.page2:SetVisible(false)
end

local function Create(channelName)
	local margin = 5
	local wizard = UI.CreateContext(Completionist.name .. "page1Context")
	wizard:SetSecureMode("restricted")
	local page1 = UI.CreateFrame("SimpleWindow", "page1", wizard)
	page1:SetSecureMode("restricted")
	page1:SetVisible(false)
	page1:SetCloseButtonVisible(true)
	page1:SetTitle("Completionist Chat Channel wizard")
	page1:SetPoint("CENTER", UIParent, "CENTER")
	page1:SetWidth(450)
	page1:SetHeight(350)
	
	page1.mainFrame = UI.CreateFrame("Frame", "CompletionistMainFrame", page1:GetContent())
	page1.mainFrame:SetAllPoints()
	
	page1.label = UI.CreateFrame("Text", "CompletionistLabel", page1.mainFrame)
	page1.label:SetPoint("TOPLEFT", page1.mainFrame, "TOPLEFT", margin, margin)
	page1.label:SetPoint("TOPRIGHT", page1.mainFrame, "TOPRIGHT", -margin, margin)
	page1.label:SetWordwrap(true)
	page1.label:SetText("This latest version of the Completionist addon allows users to automatically sharing information over a custom chat channel.\n\nJoining the Completionist chat channel will allow you to send and receive quest information with other Completionist users.  This improves the addon database of unavailble information such as the quest start coordinates.  Press the Join button below to join the channel.")
	
	page1.joinButton = UI.CreateFrame("RiftButton", "CompletionistButton1", page1)
	page1.joinButton:SetSecureMode("restricted")
	page1.joinButton:SetPoint("BOTTOMCENTER", page1.mainFrame, "BOTTOMCENTER", 0, - (margin * 10))
	page1.joinButton:SetText("Join Channel")
	page1.joinButton.Event.LeftClick = "join " .. channelName .. "\ncmpl joined"

	page1.noButton = UI.CreateFrame("RiftButton", "CompletionistButton2", page1.mainFrame)
	page1.noButton:SetPoint("BOTTOMCENTER", page1.mainFrame, "BOTTOMCENTER", 0, - (margin * 2))
	page1.noButton:SetText("Don't Join")
	page1.noButton.Event.LeftClick = function() Close(wizard) end

	local page2 = UI.CreateFrame("SimpleWindow", "page2", wizard)
	page2:SetVisible(false)
	page2:SetCloseButtonVisible(true)
	page2:SetTitle("Completionist Chat Channel wizard - 2")
	page2:SetPoint("CENTER", UIParent, "CENTER")
	page2:SetWidth(450)
	page2:SetHeight(550)
	
	page2.mainFrame = UI.CreateFrame("Frame", "CompletionistMainFrame2", page2:GetContent())
	page2.mainFrame:SetAllPoints()
	
	page2.label = UI.CreateFrame("Text", "CompletionistLabel2.1", page2.mainFrame)
	page2.label:SetPoint("TOPLEFT", page2.mainFrame, "TOPLEFT", margin, margin)
	page2.label:SetWidth(420)
	page2.label:SetWordwrap(true)
	page2.label:SetText("These next two steps are completely optional, but they will stop you receiving Player joined/left messages everytime someone joins the Completionist channel.\n\nStep 1. Right click on the word General on the Rift chat window tab headings and choose the Settings option on the popup menu as shown below:")
	
	page2.picture1 = UI.CreateFrame("Texture", "CompletionistPicture2.1", page2.mainFrame)
	page2.picture1:SetPoint("TOPLEFT", page2.label, "BOTTOMLEFT", 0, margin)
	page2.picture1:SetTexture("Completionist", "ChatPopup.png");
	
	page2.label2 = UI.CreateFrame("Text", "CompletionistLabel2.2", page2.mainFrame)
	page2.label2:SetPoint("TOPLEFT", page2.picture1, "BOTTOMLEFT", 0, margin)
	page2.label2:SetWidth(420)
	page2.label2:SetWordwrap(true)
	page2.label2:SetText("Step 2. Select the Channel Messages option on the Console Settings dialog that appears.  Now make sure that the checkbox to the left of the Completionist channel is not ticked.")
	
	page2.okButton = UI.CreateFrame("RiftButton", "CompletionistButton3", page2)
	page2.okButton:SetPoint("BOTTOMRIGHT", page2.mainFrame, "BOTTOMRIGHT", - (margin * 2), - (margin * 2))
	page2.okButton:SetText("OK")
	page2.okButton.Event.LeftClick = function() Close(wizard) end

	page2.picture2 = UI.CreateFrame("Texture", "CompletionistPicture2.2", page2.mainFrame)
	page2.picture2:SetPoint("TOPLEFT", page2.label2, "BOTTOMLEFT", 0, margin)
	page2.picture2:SetPoint("BOTTOMRIGHT", page2.okButton, "TOPRIGHT", 0, -margin)
	page2.picture2:SetTexture("Completionist", "ChatSettings.png");
	
	wizard.page1 = page1
	wizard.page2 = page2
	wizard.channelName = channelName
	
	wizard.Show = Show
	wizard.Close = Close
	
	return wizard
end

Completionist.CreateChannelWizard = Create
