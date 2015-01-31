--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

ActionAPI.lua is part of Learning Aid.

  Learning Aid is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  Learning Aid is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with Learning Aid.  If not, see
  <http://www.gnu.org/licenses/>.

To download the latest official version of Learning Aid, please visit 
either Curse or WowInterface at one of the following URLs: 

http://wow.curse.com/downloads/wow-addons/details/learningaid.aspx

http://www.wowinterface.com/downloads/info10622-LearningAid.html

Other sites that host Learning Aid are not official and may contain 
outdated or modified versions. If you have obtained Learning Aid from 
any other source, I strongly encourage you to use Curse or WoWInterface 
for updates in the future. 

]]

local ActionBarMax = 10
local ActionMax = ActionBarMax * 12

local addonName, private = ...
local LA = private.LA

local actionBarObjectMeta  = { }                             -- One of the ten (?) bars
local actionSlotObjectMeta = { _method = { Pickup = true } } -- One of the action ids from 1-120
local actionObjectMeta     = { _method = { Drop   = true } } -- an abstract action value, not attached to a particular slot

LA.Action = { }
local actionMeta = { }
setmetatable(LA.Action, actionMeta)

function actionMeta.__index(t, index)
  index = tonumber(index)
  assert(index >= 1 and index <= ActionMax) -- there's a temporary extra bar from 121-132, maybe later
  local actionObject = { _aID = index }
  setmetatable(actionObject, actionObjectMeta)
  return actionObject
end

LA.ActionBar = { }
local actionBarMeta = { }
setmetatable(LA.ActionBar, actionBarMeta)

function actionBarMeta.__index(t, index)
  index = tonumber(index)
  assert(index >= 1 and index <= ActionBarMax)
  local actionBarObject = { _bID = index }
  setmetatable(actionBarObject, actionBarObjectMeta)
  return actionBarObject
end

function actionBarObjectMeta.__index(bar, index)
  if not actionBarObjectMeta[index] then
    error("ActionAPI: Invalid Action Bar object method '"..tostring(index).."'", 2)
  end
  if actionBarObjectMeta._method[index] then
end
-- Spell object instances
function spellMeta.__index(spell, index)
  -- Use rawget to avoid an infinite loop if _gid doesn't exist for some reason
  -- LA:DebugPrint("SpellMeta "..index.."("..tostring(rawget(spell, "_gid"))..")")
  if not spellMeta[index] then
    error("SpellAPI: Invalid Spell object method '"..tostring(index).."'", 2)
  end
  if spellMeta._method[index] then
    -- return value will be called as a method, see spellMeta._method
    LA:DebugPrint("SpellMeta "..index.."("..tostring(spell)..")")
    return spellMeta[index]
  else
    -- simple return value
    local result = spellMeta[index](spell)
    LA:DebugPrint(tostring(result).." = SpellMeta "..tostring(index).."("..tostring(spell)..")")
    return result
  end
end
