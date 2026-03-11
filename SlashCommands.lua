SLASH_GRMH1 = "/grmh"

local addonName, addonTable = ...
local editFrame = addonTable.editFrame
local button = addonTable.button

SlashCmdList["GRMH"] = function(msg)
  if msg == "edit" then
    if editFrame:IsShown() then
      editFrame:Hide()
    else
      editFrame:Show()
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