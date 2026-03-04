SLASH_GRMH1 = "/grmh"

if not GRMHDB then
  GRMHDB = {
    buttonShow = true,
    buttonPosition = {
      point = "CENTER",
      relativeTo = UIParent,
      relativePoint = "CENTER",
      xOffset = 0.0,
      yOffset = 0.0
    },
    recruitmentMessage = ""
  }
end

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

-- mainFrame code --
local mainFrame = CreateFrame("Frame", "RecruitmentMessageEditor", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(300, 200)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOP", mainFrame.TitleBg, "TOP", 0, -3)
mainFrame.title:SetText("Guild recruitment message")
mainFrame.description = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.description:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 30, -30)
mainFrame.description:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -30, -30)
mainFrame.description:SetText("Edit your recruitment message and then press ENTER to save it.")
mainFrame.description:SetJustifyH("LEFT")

mainFrame:SetScript("OnDragStart", function(self)
  self:StartMoving()
end)

mainFrame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
end)

mainFrame:SetScript("OnShow", function(self)
  PlaySound(808)
end)

mainFrame:SetScript("OnHide", function(self)
  PlaySound(808)
end)

table.insert(UISpecialFrames, "RecruitmentMessageEditor")

-- editBox code --
local editBox = CreateFrame("EditBox", nil, mainFrame, "BackdropTemplate")
editBox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -55)
editBox:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 20)
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

editBox:SetScript("OnEscapePressed", function(self)
  self:ClearFocus()
end)

editBox:SetScript("OnEnterPressed", function(self)
  GRMHDB.recruitmentMessage = self:GetText()
  print("Your message will be: \"[Guild Link]: " .. GRMHDB.recruitmentMessage .. "\"")
  self:GetParent():Hide()
end)

editBox:SetScript("OnShow", function(self)
  self:SetText(GRMHDB.recruitmentMessage)
  local num = string.len(self:GetText())
  local max = self:GetMaxLetters()
  self.counter:SetText("(" .. num .. "/" .. max .. ")")
end)

editBox:SetScript("OnTextChanged", function(self, userInput)
  if userInput then
    local num = string.len(self:GetText())
    local max = self:GetMaxLetters()
    self.counter:SetText("(" .. num .. "/" .. max .. ")")
  end
end)

-- button code --
local button = CreateFrame("Button", nil, UIParent, "ActionButtonTemplate")
button:SetSize(45, 45)
button:EnableMouse(true)
button:SetMovable(true)
button:RegisterForDrag("RightButton")
button:RegisterForClicks("LeftButtonUp")
button:RegisterEvent("ADDON_LOADED")

button.backgroundTexture = button:CreateTexture(nil, "BACKGROUND")
button.backgroundTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
button.backgroundTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
button.backgroundTexture:SetTexture("Interface/Icons/INV_Rareguildtabard")

function button:ShowButtonInChannel(self)
  local channelId = GetChannelName("2")
  if channelId == 0 then
    self:Hide()
  else
    self:Show()
  end
end

button:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "GuildRecruitmentMessageHelper" then
    self:SetPoint(GRMHDB.buttonPosition.point, GRMHDB.buttonPosition.relativeTo, GRMHDB.buttonPosition.relativePoint,
      GRMHDB.buttonPosition.xOffset, GRMHDB.buttonPosition.yOffset)
    if GRMHDB.buttonShow then
      self:ShowButtonInChannel()
      self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    else
      self:Hide()
    end
    self:UnregisterEvent("ADDON_LOADED")
  end
  if event == "CHAT_MSG_CHANNEL_NOTICE" then
    self:ShowButtonInChannel()
  end
end)

button:SetScript("OnDragStart", function(self)
  self:StartMoving()
end)

button:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  GRMHDB.buttonPosition.point, GRMHDB.buttonPosition.relativeTo, GRMHDB.buttonPosition.relativePoint, GRMHDB.buttonPosition.xOffset, GRMHDB.buttonPosition.yOffset =
      self:GetPoint()
end)

button:SetScript("OnClick", function()
  local clubId = C_Club.GetGuildClubId()
  local club = ClubFinderGetCurrentClubListingInfo(clubId)

  if (club ~= nil) then
    local recruitmentMessage = GetClubFinderLink(club.clubFinderGUID, club.name) .. " " .. GRMHDB.recruitmentMessage
    C_ChatInfo.SendChatMessage(recruitmentMessage, "CHANNEL", nil, "2")
  else
    print("Open the guild tab at least once before using the button!")
  end
end)

-- slash commands --
SlashCmdList["GRMH"] = function(msg)
  if msg == "edit" then
    if mainFrame:IsShown() then
      mainFrame:Hide()
    else
      mainFrame:Show()
    end
  elseif msg == "show" then
    if GRMHDB.buttonShow then
      button:Hide()
      GRMHDB.buttonShow = false
      print("Recruitment button now hidden")
      button:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    else
      GRMHDB.buttonShow = true
      print("Recruitment button will show up if Trade channel is active")
      button:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
      button:ShowButtonInChannel()
    end
  else
    print("/grmh edit - Edit your recruitment message")
    print("/grmh show - Toggle the visibility of the message button")
  end
end
