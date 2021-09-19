SamyTotemTimersDbVersion = {}

local function IsDoDbVersion(versionNumber, db)
    if (db and (not db.version or db.version < versionNumber)) then
        return true
    end

    return false
end

function SamyTotemTimersDbVersion:UpdateDatabase(samyTotemTimersDb, forceRun, setDefault)
    if forceRun then
        samyTotemTimersDb.version = 0
    end

    if (IsDoDbVersion(2.1, samyTotemTimersDb)) then
        isReset = true
        SamyTotemTimersUtils:Print("Current version incompatible with old saved variables, reseting all configuration")
        samyTotemTimersDb.version = 2.1
    end

    if (IsDoDbVersion(2.3, samyTotemTimersDb)) then
        samyTotemTimersDb.totemLists = setDefault(SamyTotemTimersDB.totemLists, SamyTotemTimersConfig.defaultTotemLists, true)  
        SamyTotemTimersUtils:Print("Updated twist totem list with more totems, added order to totemlists")
        samyTotemTimersDb.version = 2.3
    end

    if (IsDoDbVersion(2.5, samyTotemTimersDb)) then
        samyTotemTimersDb.totemLists[1]["totems"]["Tremor Totem"]["PulseTime"] = 4
        samyTotemTimersDb.totemLists[5]["totems"]["Tremor Totem"]["PulseTime"] = 4
        SamyTotemTimersUtils:Print("Updated pulse timers for tbc")
        samyTotemTimersDb.version = 2.5
    end

    if (IsDoDbVersion(2.6, samyTotemTimersDb)) then
        samyTotemTimersDb.wfComClass = {}
        samyTotemTimersDb.wfComClass["WARRIOR"] = true
        samyTotemTimersDb.wfComClass["ROGUE"] = true
        samyTotemTimersDb.wfComClass["PALADIN"] = true
        samyTotemTimersDb.wfComClass["HUNTER"] = false
        samyTotemTimersDb.wfComClass["DRUID"] = false
        samyTotemTimersDb.wfComClass["MAGE"] = false
        samyTotemTimersDb.wfComClass["PRIEST"] = false
        samyTotemTimersDb.wfComClass["WARLOCK"] = false
        samyTotemTimersDb.wfComClass["SHAMAN"] = false

        SamyTotemTimersUtils:Print("Added wfcom default classes")
        samyTotemTimersDb.version = 2.6
    end
end