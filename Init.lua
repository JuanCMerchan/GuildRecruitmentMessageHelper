local addonName, addonTable = ...

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

print("Welcome to " .. addonName .. "!\nUse /grmh to see the commands available\nMove the button by dragging it with the RIGHT mouse button")