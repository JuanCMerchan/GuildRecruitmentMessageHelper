local addonName, addonTable = ...

local backdropInfo = {
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  edgeSize = 16,
  insets = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5
  }
}

-- frame code --
local editFrame = CreateFrame("Frame", "RecruitmentMessageEditor", UIParent, "BasicFrameTemplateWithInset")
editFrame:SetSize(300, 200)
editFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
editFrame:EnableMouse(true)
editFrame:SetMovable(true)
editFrame:RegisterForDrag("LeftButton")
editFrame.title = editFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
editFrame.title:SetPoint("TOP", editFrame.TitleBg, "TOP", 0, -3)
editFrame.title:SetText("Guild recruitment message")
editFrame.description = editFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
editFrame.description:SetPoint("TOPLEFT", editFrame, "TOPLEFT", 30, -30)
editFrame.description:SetPoint("TOPRIGHT", editFrame, "TOPRIGHT", -30, -30)
editFrame.description:SetText("Edit your recruitment message and then press ENTER to save it.")
editFrame.description:SetJustifyH("LEFT")

editFrame:SetScript("OnDragStart", function(self)
  self:StartMoving()
end)

editFrame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
end)

editFrame:SetScript("OnShow", function(self)
  PlaySound(808)
end)

editFrame:SetScript("OnHide", function(self)
  PlaySound(808)
end)

table.insert(UISpecialFrames, "RecruitmentMessageEditor")

-- editBox code --
local editBox = CreateFrame("EditBox", nil, editFrame, "BackdropTemplate")
editBox:SetPoint("TOPLEFT", editFrame, "TOPLEFT", 20, -55)
editBox:SetPoint("BOTTOMRIGHT", editFrame, "BOTTOMRIGHT", -20, 20)
editBox:SetFontObject("ChatFontNormal")
editBox:SetMultiLine(true)
editBox:SetAutoFocus(false)
editBox:SetMaxLetters(225)
editBox:SetBackdrop(backdropInfo)
editBox:SetBackdropColor(0, 0, 0)
editBox:SetBackdropBorderColor(0.5, 0.5, 0.5)
editBox:SetTextInsets(10, 10, 10, 10)

editBox.counter = editBox:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
editBox.counter:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", -5, -5)
local guildLink = "[Guild: Your guild name] "

editBox:SetScript("OnEscapePressed", function(self)
  self:ClearFocus()
end)

editBox:SetScript("OnEnterPressed", function(self)
  GRMHDB.recruitmentMessage = self:GetText()
  print("Your message will be: \"" .. guildLink .. GRMHDB.recruitmentMessage .. "\"")
  self:GetParent():Hide()
end)

editBox:SetScript("OnShow", function(self)
  local clubId = C_Club.GetGuildClubId()
  local club = ClubFinderGetCurrentClubListingInfo(clubId)
  if club ~= nil then
    guildLink = "[Guild: " .. club.name .. "] "
    self:SetMaxLetters(255 - string.len(guildLink))
    self:SetText(GRMHDB.recruitmentMessage)
    local num = string.len(self:GetText())
    local max = self:GetMaxLetters()
    self.counter:SetText("(" .. num .. "/" .. max .. ")")
  else
    self:GetParent():Hide()
    print("Open the guild tab at least once before editing the message!")
  end
end)

editBox:SetScript("OnTextChanged", function(self, userInput)
  if userInput then
    local num = string.len(self:GetText())
    local max = self:GetMaxLetters()
    self.counter:SetText("(" .. num .. "/" .. max .. ")")
  end
end)

addonTable.editFrame = editFrame
