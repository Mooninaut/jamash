local racial = select(2, GetSpellInfo(20549)) -- War Stomp (Tauren) "Racial"
local racialPassive = select(2, GetSpellInfo(20550)) -- Endurance (Tauren) "Racial Passive"
local riding = {
   [33388] = 1, -- apprentice
   [33391] = 2, -- journeyman
   [34090] = 3, -- expert
   [34091] = 4, -- artisan
   [90265] = 5, -- master
   [90267] = 100, -- old world
   [54197] = 101 -- northrend
}
local spells = { }
local flyouts = { }
local professions = {GetProfessions()} -- { Primary1, Primary2, Archaeology, Fishing, Cooking, First Aid }
for i = 1, 6 do
   if professions[i] then
      local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo(professions[i])
      for k = spelloffset + 1, spelloffset + numSpells do
         local spellStatus, spellID = GetSpellBookItemInfo(k, BOOKTYPE_SPELL)
         spells[spellID] = "PROFESSION"
      end
   end
end
for i = 1, GetNumSpellTabs() do 
   local tabName, tabTexture, tabOffset, tabSpells, tabIsGuild = GetSpellTabInfo(i);
   --print("Tab Name: '"..tabName.."' Offset: "..tabOffset.." Spells: "..tabSpells.." IsGuild: "..tostring(tabIsGuild))
   for k = tabOffset + 1, tabOffset + tabSpells do
      
      local spellStatus, spellID = GetSpellBookItemInfo(k, BOOKTYPE_SPELL)
      local spellName, spellSubName = GetSpellBookItemName(k, BOOKTYPE_SPELL)
      local spellOrigin = (
         tabIsGuild and "GUILD" or
         (spellSubName == racial or spellSubName == racialPassive) and "RACE" or
         riding[spellID] and "RIDING" or
         --spellStatus == "FLYOUT" and spellStatus or
         "CLASS"
      )
      --print("Spell Name: '"..spellName.."' SubName: '"..spellSubName.."' ID: "..spellID.." Status: "..spellStatus)
      --print(spellName, class, spellID)
      if spellStatus=="FLYOUT" then
         local flyoutName, flyoutDescription, numFlyoutSpells, flyoutKnown = GetFlyoutInfo(spellID)
         for f = 1, numFlyoutSpells do
            local flyoutSpellID = GetFlyoutSlotInfo(spellID, f)
            spells[flyoutSpellID] = "CLASS"
         end
         flyouts[spellID] = spellOrigin
      else
         spells[spellID] = spellOrigin
      end
   end
end

local function classify(globalID, isFlyout)
   -- if a then b else if c then c else d
   return (isFlyout and flyouts or spells)[globalID] or "UNKNOWN"
end
for i = 1, 1000 do
   local name, subName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
   local status, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
   if name then
      if subName and subName:len() > 0 then
         subName = "("..subName..")"
      else
         subName = ""
      end
      print(format("%3d %30s %-16s %-11s %6d %10s",i, name, subName, status, id, classify(id,status=="FLYOUT")))
   end
end
