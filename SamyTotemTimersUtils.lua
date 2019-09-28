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

function SamyTotemTimersUtils:GetUnitBuffs(unit)
    local buffList = {}
    for i=1, 40 do
        local name, _, _, _, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, i)
        if (name) then
            table.insert(buffList, 
                { 
                    ["name"] = name,
                    ["duration"] = duration,
                    ["expirationTime"] = expirationTime,
                    ["unitCaster"] = unitCaster,
                    ["spellId"] = spellId
                }       
            )
        end
    end

    return buffList
end