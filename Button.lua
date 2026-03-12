local addonName, addonTable = ...

local button = CreateFrame("Button", nil, UIParent, "ActionButtonTemplate")
button:SetSize(45, 45)
button:EnableMouse(true)
button:SetMovable(true)
button:RegisterForDrag("RightButton")
button:RegisterForClicks("LeftButtonUp")
button:RegisterEvent("ADDON_LOADED")
button:RegisterEvent("PLAYER_ENTERING_WORLD")
button:Hide()

button.backgroundTexture = button:CreateTexture(nil, "BACKGROUND")
button.backgroundTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
button.backgroundTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
button.backgroundTexture:SetTexture("Interface/Icons/INV_Rareguildtabard")

function button:ShowButtonInChannel()
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
    self:UnregisterEvent("ADDON_LOADED")
  end
  if event == "PLAYER_ENTERING_WORLD" then
    C_Timer.After(5, function()
      if GRMHDB.buttonShow then
        self:ShowButtonInChannel()
        self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
      else
        self:Hide()
      end
    end)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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

addonTable.button = button
