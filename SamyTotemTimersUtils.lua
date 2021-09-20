SamyTotemTimersUtils = {}

function SamyTotemTimersUtils:FirstOrDefault(list, predicate)
    for k, v in pairs(list) do
        if (not predicate or predicate(v)) then
            return v
        end
    end

    return nil
end

function SamyTotemTimersUtils:Round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function SamyTotemTimersUtils:PrintMyBuffs()
    for i=1,40 do 
        local name, _ , _ , _ , _ , _ , _ , _ , _, id = UnitBuff("player",i); 
        if name then 
            SamyTotemTimersUtils:Print(i.."=".. name .. " - " .. tostring(id)) end end
end

function SamyTotemTimersUtils:Trim(string)
    return string:match'^%s*(.*%S)' or ''
 end

function SamyTotemTimersUtils:StringIsNilOrEmpty(string)
    if (not string) then return true end

    local trimmerString = self:Trim(string)
    return trimmerString == ''
end

function SamyTotemTimersUtils:Debug(string)
    if (not SamyTotemTimersConfig.IS_DEBUG) then
        return
    end

    self:Print(string)
end

function SamyTotemTimersUtils:Print(string)
    print(SamyTotemTimersConfig.PRINT_PREFIX  .. string)
end

function SamyTotemTimersUtils:IsSpellsEqual(spellOne, spellTwo)
    if (self:StringIsNilOrEmpty(spellOne) or self:StringIsNilOrEmpty(spellTwo)) then
        return false
    end

    return spellOne == spellTwo
end

function SamyTotemTimersUtils:GetUnitBuffs(unit, additionalBuffsByGuid)
    local buffList = {}

    local unitGuid = UnitGUID(unit)
    if additionalBuffsByGuid and additionalBuffsByGuid[unitGuid] then
        additionalBuff = additionalBuffsByGuid[unitGuid]
        table.insert(buffList, 
        { 
            ["name"] = 'Windfury Totem',
            ["duration"] = additionalBuff.duration,
            ["expirationTime"] = additionalBuff.expirationTime,
            ["unitCaster"] = nil,
            ["spellId"] = nil,
            ["isRelevant"] = additionalBuff.isRelevant
        }) 
    end

    for i=1, 40 do
        local name, _, _, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, i)
        if (name) then
            expirationTime = (expirationTime and expirationTime > 0) and expirationTime or 1000
            table.insert(buffList, 
                { 
                    ["name"] = name,
                    ["duration"] = duration,
                    ["expirationTime"] = GetTime() + (tonumber(expirationTime) / 1000),
                    ["unitCaster"] = unitCaster,
                    ["spellId"] = spellId,
                    ["isRelevant"] = true,
                }       
            )
        end
    end

    return buffList
end