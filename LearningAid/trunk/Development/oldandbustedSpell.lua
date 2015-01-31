-- old and busted
  local cache = self.spellBookCache
  local flyout = self.flyoutCache
  for k, v in pairs(cache) do
    v.fresh = false
  end
  for k, v in pairs(flyout) do
    v.fresh = false
  end
  local changes = {}
  local flyoutChanges = {}
  local old
  local spellGlobalID
  local spellStatus
  local updated = 0
  -- begin spellbook scan
  local i = 1
  local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
  while spellName do
    spellStatus, spellGlobalID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
    if spellStatus == "FLYOUT" then
      local flyoutName, flyoutDescription, numFlyoutSpells, known = GetFlyoutInfo(spellGlobalID)
      old = flyout[spellGlobalID]
      if old == nil then
        updated = updated + 1
        if known then
          table.insert(flyoutChanges, {kind="NEW", bookID = i, flyoutID = spellGlobalID, name = flyoutName}) -- garbage oh noes
        end
      else
        old.fresh = true
        if old.known ~= known then
          -- assuming flyouts can go from unknown to known, but not known to unknown
          table.insert(flyoutChanges, {kind="CHANGE", bookID = i, flyoutID = spellGlobalID, name=flyoutName}) -- garbage oh noes
          updated = updated + 1
        end
      end
    else
      local known = IsSpellKnown(spellGlobalID)
      old = cache[spellGlobalID]
      if old == nil then
        updated = updated + 1
        if known then
          table.insert(changes, {kind="NEW", bookID = i, globalID = spellGlobalID, name = spellName}) -- garbage oh noes
        end
      else
        old.fresh = true
        if old.known ~= known then
          -- assuming spells can go from unknown to known, or known to removed, but not known to unknown
          updated = updated + 1
          table.insert(changes, {kind="CHANGE", bookID = i, globalID = spellGlobalID, name = spellName}) -- garbage oh noes
          self:DebugPrint("CHANGE: name "..spellName.." global "..spellGlobalID.." old status "..old.status.." old bookid "..old.bookID.." old known "..tostring(old.known)
            .." new status "..spellStatus.." new bookid "..i.." new known "..tostring(known))
        end
      end
    end
    i = i + 1
    spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
  end
  -- end spellbook scan
  for k, v in pairs(cache) do
    if not v.fresh then
      updated = updated + 1
      table.insert(changes, {kind="REMOVE", bookID = v.bookID, globalID = k, name = v.info.name}) -- garbage oh noes
    end
  end
  for k, v in pairs(flyout) do
    if not v.fresh then
      updated = updated + 1
      table.insert(flyoutChanges, {kind="REMOVE", bookID = v.bookID, flyoutID = v.flyoutID, name = v.name}) -- garbage oh noes
    end
  end
  if updated > 0 then
    self:UpdateSpellBook()
    for k, v in ipairs(changes) do
      self:DebugPrint("Spell name "..v.name.." change "..v.kind.." global "..v.globalID.." bookid "..v.bookID)
      --self:DebugPrint("Old spell removed: "..cache[i].name.." ("..cache[i].subName..") id "..(i))
      if v.kind == "REMOVE" then
        self:RemoveSpell(v.bookID)
      --self:DebugPrint("New spell found: "..spellName.." ("..subSpellName..")") -- Old spell: "..cache[i + 1].name.." ("..cache[i + 1].rank..")")
      elseif v.kind == "NEW" then
        self:AddSpell(v.bookID, true)
      elseif v.kind == "CHANGE" then
        self:AddSpell(v.bookID)
      end
    end
    for k, v in ipairs(flyoutChanges) do
      self:DebugPrint("Flyout "..v.bookID.." "..v.kind.." "..k.." "..v.flyoutID.." "..v.name)
      if v.kind == "REMOVE" then
        -- ?? TODO
      elseif v.kind == "NEW" then
        -- ?? TODO
      elseif v.kind == "CHANGE" then
        -- ?? TODO
      end
    end
  end
  if updated == 0 then updated = false end
  return updated
