local eventCount = {}
local eventFrame = CreateFrame("Frame", nil, UIParent)
eventFrame:RegisterAllEvents()

eventFrame:SetScript("OnEvent", function (self, event, ...)
      if eventCount[event] then
         eventCount[event] = eventCount[event] + 1
      else
         eventCount[event] = 1
      end
      --local actionType, actionID, actionSubType, globalID = GetActionInfo(1)
      --if actionType then
      --  print("Action Bar info available at event", event, ...)
      --  print(actionType, actionID, actionSubType, globalID)
      --  eventFrame:UnregisterAllEvents()
      --end
      local isInGuild = IsInGuild()
      if isInGuild and not self.isInGuild then
         print("IsInGuild at event",event,eventCount[event],...)
      end
      local guildName = GetGuildInfo("player")
      if guildName and not self.guildName then
         print("Guild Name",guildName,"available at event",event,eventCount[event],...)
      end

      if isInGuild and guildName then
         print("Full guild info available at event", event, eventCount[event], ...)
         eventFrame:UnregisterAllEvents()
      end
      self.isInGuild = isInGuild
      self.guildName = guildName
end)

login
  at some point PlayerInGuild returns true
  at some point the guild name is available
  at some point the guild perks appear
