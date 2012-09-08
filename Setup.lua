-- This file contains the code to be executed when a spell is casted or failed to be cast.
-- You can add and remove spells to be announced and you can alter announcements.
-- If you want to, you can completely alter the rection of the addon, when it detects a specified spell.
-- You might need a little bit of lua knowlage to alter the file.




-- Active Announces
-- The addon will only react on spells in this list.
-- Entries must be SpellIDs
-- You can look up spellIDs in www.wowhead.com. The ID is part of a spells URL (Example: "http://www.wowhead.com/spell=5185" the SpellID is 5185)
-- Available tags: "oor", "oos", "start"(cast-time spells only), "success"
-- Todo: Add and "interrupted" event to cast-time spells. Add channelled
DruidAnnounces.activeAnnounces = {
    [20484] = { -- Rebirth
        ["oor"] = true,
        ["oos"] = true,
        ["start"] = true,
    },
    [29166] = { -- Innervate
        ["oor"] = true,
        ["oos"] = true,
        ["success"] = true,
    },
}
DruidAnnounces.activeAnnounces_current = DruidAnnounces.activeAnnounces


-- Active Announces in Debug-mode
DruidAnnounces.activeAnnounces_debug = {
    [20484] = { -- Rebirth
        ["oor"] = true,
        ["oos"] = true,
        ["start"] = true,
    },
    [29166] = { -- Innervate
        ["oor"] = true,
        ["oos"] = true,
        ["success"] = true,
    },
    [5185] = { -- Healing Touch
        ["oor"] = true,
        ["oos"] = true,
        ["start"] = true,
        ["success"] = true,
    },
    [774] = { -- Rejuvenation
        ["oor"] = true,
        ["oos"] = true,
        ["success"] = true,
    },
}
if (DruidAnnounces.debug > 0) then DruidAnnounces.activeAnnounces_current = DruidAnnounces.activeAnnounces_debug end



-- triggerAnnouncement Function
-- Contains all the code to be executed when an announcement is triggered
-- Usually contains code to whisper the target of the spell
-- The "DruidAnnounces.AnnounceMessage" can be used for conveniance
-- Any other kind of code may be used
-- Arguments:
--    spellID: The ID of the spell
--    castStatus: Cast-status as listed in the DruidAnnounces.activeAnnounces object
--    targetName: Name of the spell target (Todo: Investigate server tags used in LFG groups)
--    targetIsPlayer: Identifies the target as a player or an NPC (which is usefull if you want to whisper the target)
DruidAnnounces.triggerAnnouncement = function(spellID, castStatus, targetName, targetIsPlayer)

    DruidAnnounces.DebugPrint(string.format("Spell reaction triggered. spellName: |cffffffff%s|r, castStatus: |cffffffff%s|r, targetName |cffffffff%s|r, targetIsPlayer |cffffffff%s|r", tostring(GetSpellInfo(spellID)), tostring(castStatus), tostring(targetName), tostring(targetIsPlayer)))
    
    local chatType = "SAY"
    if (GetNumSubgroupMembers()>0) then chatType = "PARTY" end
    if (GetNumGroupMembers()>0) then chatType = "RAID" end
    
    -- Rebirth
    if (spellID==20484 and targetIsPlayer) then
        if (castStatus=="start") then DruidAnnounces.AnnounceMessage("Combat-Rezz: %s", targetName, chatType, nil)
--~         if (castStatus=="start") then DruidAnnounces.AnnounceMessage("Combat-Rezz: %s", targetName, "CHANNEL", 5)
        elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("Combat-Rezz failed: Not in line of sight.", targetName, "WHISPER", nil)
        elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("Combat-Rezz failed: Out of range.", targetName, "WHISPER", nil)
        end
        
    -- Innervate
    elseif (spellID==29166 and targetIsPlayer and targetName~=UnitName("player")) then
        if (castStatus=="success") then DruidAnnounces.AnnounceMessage("Innervated.", targetName, "WHISPER", nil)
        elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("Innervate failed: Not in line of sight.", targetName, "WHISPER", nil)
        elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("Innervate failed: Out of range.", targetName, "WHISPER", nil)
        end
    
    -- Healing Touch
    elseif (spellID==5185) then
        if (castStatus=="start") then DruidAnnounces.AnnounceMessage("HT start. Target: %s", targetName, chatType, nil)
        elseif (castStatus=="success") then DruidAnnounces.AnnounceMessage("HT finish. Target: %s", targetName, chatType, nil)
        elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("oos for HT.", targetName, "WHISPER", nil)
        elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("oor for HT.", targetName, "WHISPER", nil)
        end
    
    -- Rejuvenation
    elseif (spellID==774) then
        if (castStatus=="success") then DruidAnnounces.AnnounceMessage("Reju casted.", targetName, "WHISPER", nil)
        elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("oos for Reju.", targetName, "WHISPER", nil)
        elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("oor for Reju.", targetName, "WHISPER", nil)
        end
    end
end



-- German localization
if (GetLocale() == "deDE") then
    DruidAnnounces.triggerAnnouncement = function(spellID, castStatus, targetName, targetIsPlayer)
    
    local chatType = "SAY"
    if (GetNumSubgroupMembers()>0) then chatType = "PARTY" end
    if (GetNumGroupMembers()>0) then chatType = "RAID" end
    
        DruidAnnounces.DebugPrint(string.format("Spell reaction triggered. spellName: |cffffffff%s|r, castStatus: |cffffffff%s|r, targetName |cffffffff%s|r, targetIsPlayer |cffffffff%s|r", tostring(GetSpellInfo(spellID)), tostring(castStatus), tostring(targetName), tostring(targetIsPlayer)))
        
        -- Rebirth
        if (spellID==20484 and targetIsPlayer) then
            if (castStatus=="start") then DruidAnnounces.AnnounceMessage("Wiedergeburt: %s", targetName, chatType, nil)
    --~         if (castStatus=="start") then DruidAnnounces.AnnounceMessage("Combat-Rezz: %s", targetName, "CHANNEL", 5)
            elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("Wiedergeburt fehlgeschlagen: Nicht in Sichlinie.", targetName, "WHISPER", nil)
            elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("Wiedergeburt fehlgeschlagen: Ausser Reichweite.", targetName, "WHISPER", nil)
            end
            
        -- Innervate
        elseif (spellID==29166 and targetIsPlayer) then
            if (castStatus=="success") then DruidAnnounces.AnnounceMessage("Anregen auf dir.", targetName, "WHISPER", nil)
            elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("Anregen fehlgeschlagen: Nicht in Sichlinie.", targetName, "WHISPER", nil)
            elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("Anregen fehlgeschlagen: Ausser Reichweite.", targetName, "WHISPER", nil)
            end
        
        -- Healing Touch
        elseif (spellID==5185) then
            if (castStatus=="start") then DruidAnnounces.AnnounceMessage("HT start. Target: %s", targetName, chatType, nil)
            elseif (castStatus=="success") then DruidAnnounces.AnnounceMessage("HT finish. Target: %s", targetName, chatType, nil)
            elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("oos for HT.", targetName, "WHISPER", nil)
            elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("oor for HT.", targetName, "WHISPER", nil)
            end
        
        -- Rejuvenation
        elseif (spellID==774) then
            if (castStatus=="success") then DruidAnnounces.AnnounceMessage("Reju casted.", targetName, "WHISPER", nil)
            elseif (castStatus=="oos") then DruidAnnounces.AnnounceMessage("oos for Reju.", targetName, "WHISPER", nil)
            elseif (castStatus=="oor") then DruidAnnounces.AnnounceMessage("oor for Reju.", targetName, "WHISPER", nil)
            end
        end
    end
end
