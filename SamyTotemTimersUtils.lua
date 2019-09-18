SamyTotemTimersUtils = {}

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
