--[[-- By Neetha @ Destromath(eu) --]]--

--~ Overview

--~ Why Hooking funktions?
--~ Spells that fail because of Line Of Sight (oos) or Spellrange (oor) will trigger COMBAT_LOG_EVENT_UNFILTERED->SPELL_CAST_FAILED and UNIT_SPELLCAST_FAILED
--~ Both events do not contain information about the spell's target
--~ To find out the target you need to watch the action that starts the spell. This is done by the hooking functions

--~ For oor, the hooked function is executed AFTER the event. For oos, it's triggered before.

DruidAnnounces = {}

DruidAnnounces.enabled = true
DruidAnnounces.debug = 0

DruidAnnounces.waitingSpell = {}

DruidAnnounces.activeAnnounces_current = {}


-- Following variables are filled in setup.lua
DruidAnnounces.activeAnnounces = {} -- list of spells with active announces (by id)   This is partually redundant and might be removed in a future version
DruidAnnounces.activeAnnounces_debug = {} -- list of spells with active announces, when in debug mode (by id)
DruidAnnounces.triggerAnnouncement = {} -- function containing all the code to be executed once a spell is cast or fails to cast



--[[--### Input Functions ###--]]--

DruidAnnounces.Slash = function(msg)
	if (msg == "debug") then
		DruidAnnounces.debug = (DruidAnnounces.debug+1)%3
		DruidAnnounces.ChatPrint("|cffff0000Debug|r mode: |cffffffff"..DruidAnnounces.debug.."|r")
        
        if (DruidAnnounces.debug>0) then
            DruidAnnounces.activeAnnounces_current = DruidAnnounces.activeAnnounces_debug
        else
            DruidAnnounces.activeAnnounces_current = DruidAnnounces.activeAnnounces
        end
        
	else
		DruidAnnounces.RegisterEvents(not DruidAnnounces.enabled)
        DruidAnnounces.ChatPrint("Available commands: |cffffffff debug |r")
	end
end	

SLASH_DRUIDANNOUNCES1 = "/druidannounces"
--SLASH_DRUIDANNOUNCES2 = "/da"
SlashCmdList["DRUIDANNOUNCES"] = DruidAnnounces.Slash


--[[--### Event Functions ###--]]--

-- Reroutes all registered events to the corresponding DruidAnnounces.EVENT function
DruidAnnounces.OnEvent = function(this, event, ...)
	--DruidAnnounces.DebugPrint("Event: "..event)
	
    if type(DruidAnnounces[event]) == 'function' then
        DruidAnnounces[event](...)
    end
end
DruidAnnounces.eventFrame = CreateFrame("Frame")
DruidAnnounces.eventFrame:SetScript("OnEvent", DruidAnnounces.OnEvent)

-- Reroutes all registered combatlog events to the corresponding DruidAnnounces.LOG_EVENT function
DruidAnnounces.COMBAT_LOG_EVENT_UNFILTERED = function(timestamp, event, hideCaster, ...)
	--DruidAnnounces.DebugPrint("Combat Log Event: "..event)
    
    if type(DruidAnnounces[event]) == 'function' then
        DruidAnnounces[event](...)
    end
end


DruidAnnounces.SPELL_CAST_FAILED = function(sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool, failedType)
    DruidAnnounces.DebugPrint(string.format("SPELL_CAST_FAILED Event: %s %s %s",tostring(spellID),tostring(spellName), tostring(failedType)))
	if (DruidAnnounces.activeAnnounces_current[spellID] and sourceGUID==UnitGUID("player")) then
    
            
        if (failedType==SPELL_FAILED_OUT_OF_RANGE and DruidAnnounces.activeAnnounces_current[spellID].oor) then
            
            local cooldown = GetSpellCooldown(spellID)
            local currentlyCasting = UnitCastingInfo("player")
            if (cooldown==0 and currentlyCasting==nil) then
            
                DruidAnnounces.waitingSpell.waitInfo = "oor spell, waiting for target"
                DruidAnnounces.waitingSpell.spellName = spellName
                DruidAnnounces.waitingSpell.spellID = spellID
                DruidAnnounces.waitingSpell.targetName = nil
                DruidAnnounces.waitingSpell.targetIsPlayer = nil
--~                 DruidAnnounces.waitingSpell.timeStamp = GetTime()
--~                 DruidAnnounces.waitingSpell.cooldown = cooldown
            
                
                DruidAnnounces.DebugPrint(string.format("Spell failed due to range: %s", spellName))
            end
            
            
            
        elseif (failedType==SPELL_FAILED_LINE_OF_SIGHT and DruidAnnounces.activeAnnounces_current[spellID].oos) then
            if (DruidAnnounces.waitingSpell.waitInfo=="spell triggered, waiting for event" and DruidAnnounces.waitingSpell.spellID==spellID) then    
                DruidAnnounces.triggerAnnouncement(spellID, "oos", DruidAnnounces.waitingSpell.targetName, DruidAnnounces.waitingSpell.targetIsPlayer)
                DruidAnnounces.waitingSpell.waitInfo = nil
            end
        else
            DruidAnnounces.waitingSpell.waitInfo = nil
        end
    end
end

DruidAnnounces.SPELL_CAST_SUCCESS = function(sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool)
--~     DruidAnnounces.DebugPrint(string.format("SPELL_CAST_SUCCESS/SPELL_CAST_SUCCEEDED Event: %s %s %s",tostring(spellID),tostring(spellName), tostring(destName)))
    if (DruidAnnounces.activeAnnounces_current[spellID] and DruidAnnounces.activeAnnounces_current[spellID].success and sourceGUID==UnitGUID("player")) then
        DruidAnnounces.triggerAnnouncement(spellID, "success", destName, bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER)>0)
    end
end

DruidAnnounces.SPELL_CAST_START = function(sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool)
--~     DruidAnnounces.DebugPrint(string.format("SPELL_CAST_START Event: %s %s %s",tostring(spellID),tostring(spellName), tostring(destName)))
	if (DruidAnnounces.activeAnnounces_current[spellID] and DruidAnnounces.activeAnnounces_current[spellID].start and sourceGUID==UnitGUID("player")) then
--~         DruidAnnounces.DebugPrint(string.format("Matches spell in wait? waitInfo:%s, sam ID?:%s",tostring(DruidAnnounces.waitingSpell.waitInfo), tostring(DruidAnnounces.waitingSpell.spellID==spellID)))
        if (DruidAnnounces.waitingSpell.waitInfo=="spell triggered, waiting for event" and DruidAnnounces.waitingSpell.spellID==spellID) then
            DruidAnnounces.triggerAnnouncement(spellID, "start", DruidAnnounces.waitingSpell.targetName, DruidAnnounces.waitingSpell.targetIsPlayer)
            DruidAnnounces.waitingSpell.waitInfo = "spell started, waiting for success"
        end
    end
end

DruidAnnounces.UNIT_SPELLCAST_SUCCEEDED = function(sourceUnit, spellName, _, _, spellID)
--~     DruidAnnounces.DebugPrint(string.format("SPELL_CAST_SUCCESS/SPELL_CAST_SUCCEEDED Event: %s %s %s",tostring(spellID),tostring(spellName), tostring(destName)))
    if (DruidAnnounces.activeAnnounces_current[spellID] and DruidAnnounces.activeAnnounces_current[spellID].success and sourceUnit=="player") then
        if (DruidAnnounces.waitingSpell.waitInfo=="spell started, waiting for success" and DruidAnnounces.waitingSpell.spellID==spellID) then
            DruidAnnounces.triggerAnnouncement(spellID, "success", DruidAnnounces.waitingSpell.targetName, DruidAnnounces.waitingSpell.targetIsPlayer)
            DruidAnnounces.waitingSpell.waitInfo = nil
        end
    end
end

--[[--### Hooking Functions ###--]]--
-- These are required to get the targets for oor errors, since no UNIT_SPELLCAST_SENT fires for those
-- We also need em to check for cooldown (no warnings while spell is on cooldown)

DruidAnnounces.SpellByName = function(spellName, target)
	DruidAnnounces.DebugPrint(string.format("NameCast caught: %s %s", spellName, tostring(target)))
		
    		
    local skillType, spellID = GetSpellBookItemInfo(spellName)
    if (not spellID) then
        return
    end


    DruidAnnounces.SpellTriggered(spellID, target)
end

DruidAnnounces.SpellByAction = function(slot, target, button)
	DruidAnnounces.DebugPrint("Action caught. Target:"..tostring(target))
	
    local actionType, spellID = GetActionInfo(slot)
    if (actionType ~= "spell") then
        return
    end
    DruidAnnounces.DebugPrint("Action is a spell: "..actionType.." "..spellID)
    
    if (target==nil) then
        if (UnitExists("target")) then
            target = "target"
        else
            target = "player"
        end
    end
    
    DruidAnnounces.SpellTriggered(spellID, target)
end

DruidAnnounces.SpellById = function(spellID, spellbookType)
	DruidAnnounces.DebugPrint("IDCast caught ("..spellID .." "..spellbookType..")")
    
    DruidAnnounces.SpellTriggered(spellID, "target")
end

DruidAnnounces.SpellByNameHook = DruidAnnounces.SpellByName
DruidAnnounces.SpellByActionHook = DruidAnnounces.SpellByAction
DruidAnnounces.SpellByIdHook = DruidAnnounces.SpellById

hooksecurefunc("CastSpellByName", DruidAnnounces.SpellByNameHook)
hooksecurefunc("CastSpell", DruidAnnounces.SpellByIdHook)
hooksecurefunc("UseAction", DruidAnnounces.SpellByActionHook)

DruidAnnounces.SpellTriggered = function(spellID, target)
    local spellName = GetSpellInfo(spellID)
    -- The cooldown will be 0 if the spell is about to fail (oor) and produce an error.
    -- If the spell is about to be cast normally, the cooldown will be set already.
    -- Thus, if the spell does not have a cooldown, you can be pretty sure the spell is about to fail.
    
    targetName = nil
    if (target and UnitExists(target)) then targetName = UnitName(target) end
    
    DruidAnnounces.DebugPrint(string.format("Spell triggered. Checkin Spell Conditions TargetExists:%s, UnitIsPlayer:%s, Spell in List:%s",tostring(UnitExists(target)),tostring(targetName), tostring(DruidAnnounces.activeAnnounces_current[spellID])))
    
    if (DruidAnnounces.activeAnnounces_current[spellID] and UnitExists(target)) then
    
        
--~         DruidAnnounces.DebugPrint(string.format("Matches oor-spell in wait? waitInfo:%s, sam ID?:%s",tostring(DruidAnnounces.waitingSpell.waitInfo), tostring(DruidAnnounces.waitingSpell.spellID==spellID)))

        -- Check if an oor spell just failed and is waiting for the target-info
        if (DruidAnnounces.waitingSpell.waitInfo=="oor spell, waiting for target" and DruidAnnounces.waitingSpell.spellID==spellID) then    
            DruidAnnounces.triggerAnnouncement(spellID, "oor", UnitName(target), UnitIsPlayer(target))
            DruidAnnounces.waitingSpell.waitInfo = nil
            
        -- Spell triggered. It might fail due to oos, so the information is saved
        else
        
            local cooldown = GetSpellCooldown(spellID)
            
            DruidAnnounces.waitingSpell.waitInfo = "spell triggered, waiting for event"
            DruidAnnounces.waitingSpell.spellName = spellName
            DruidAnnounces.waitingSpell.spellID = spellID
            DruidAnnounces.waitingSpell.targetName = UnitName(target)
            DruidAnnounces.waitingSpell.targetIsPlayer = UnitIsPlayer(target)
--~             DruidAnnounces.waitingSpell.timeStamp = GetTime()
--~             DruidAnnounces.waitingSpell.cooldown = cooldown
                
            DruidAnnounces.DebugPrint(string.format("Spell triggered, waiting for event: %s", spellName))
        
        
        end
        
        
    end
    
end


--[[--### Output Functions ###--]]--

DruidAnnounces.DebugPrint = function(msg, mode)
	mode = mode or 2
	if ( DEFAULT_CHAT_FRAME ) then
		if (DruidAnnounces.debug>=mode) then debugstring = " |cffff0000debug|r"
			DEFAULT_CHAT_FRAME:AddMessage("<|cffff0000DA_debug|r> "..msg, 1, 0.8, 0)
--~ 			ChatFrame5:AddMessage("<|cffff0000DA_debug|r> "..msg, 1, 0.8, 0)
		end
	end
end

DruidAnnounces.ChatPrint = function(msg)
	if ( DEFAULT_CHAT_FRAME ) then
		if (type(msg)=="string" or type(msg)=="number") then
			DEFAULT_CHAT_FRAME:AddMessage("<DruidAnnounces> "..msg, 1, 0.8, 0)
		end
	end
end

DruidAnnounces.AnnounceMessage = function (msg, targetName, chatType, channel)
    if (chatType=="WHISPER") then
        channel = targetName
    elseif (chatType=="CHANNEL" and type(channel)=="string") then
        channel = GetChannelName(channel)
    end
    
    DruidAnnounces.ChatMessage(string.format(msg, targetName), chatType, channel)
end

DruidAnnounces.ChatMessage = function (msg, chatType, channel)
	if (DruidAnnounces.debug>0) then
		DruidAnnounces.DebugPrint(string.format("ChatMsg. Type:'|cffffffff%s|r' Channel:'|cffffffff%s|r' Text:'|cffffffff%s|r'", tostring(chatType), tostring(channel), tostring(msg)), 1)
	else
		SendChatMessage(msg, chatType, nil, channel)
	end
end




--[[--### Internal Functions ###--]]--



DruidAnnounces.RegisterEvents = function(enable)

	if (enable==nil) then enable = true end
	DruidAnnounces.enabled = enable
		
	if (DruidAnnounces.enabled) then
		
	
		DruidAnnounces.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
        
        
        
--~ 		DruidAnnounces.eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
		
--~ 		DruidAnnounces.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
--~ 		DruidAnnounces.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		DruidAnnounces.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		
--~ 		DruidAnnounces.eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
--~ 		DruidAnnounces.eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
--~ 		DruidAnnounces.eventFrame:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
	
		DruidAnnounces.ChatPrint("DruidAnnounces |cff00ff00enabled|r.")
	else
		
		DruidAnnounces.eventFrame:UnregisterAllEvents()
		
		DruidAnnounces.ChatPrint("DruidAnnounces |cffff0000disabled|r.")
	end
end

DruidAnnounces.RegisterEvents(DruidAnnounces.enabled)
