SamyTotemTimersActiveTotemButton = {}

function SamyTotemTimersActiveTotemButton:Create(parentFrame, availableTotems, totemListId)
    local templates = "ActionButtonTemplate"
    local instance = SamyTotemTimersButtonBase:Create(parentFrame, "SamyTotemTimers" .. totemListId .. "ActiveTotemButton", templates)
    instance.frame:SetEnabled(false)
    instance.frame.NormalTexture:Hide()
    instance.frame.Border:Hide()
    instance.frame:SetScript("OnShow", function(self) 
        self.NormalTexture:Hide()
        self.Border:Hide()
    end)
    instance.frame:Show()

    function instance:SetVisibility(isVisible) end --override

    local elementTotemDictionary = {}
    for k, v in pairs(availableTotems) do
        if (not elementTotemDictionary[v["ElementID"]]) then
            elementTotemDictionary[v["ElementID"]] = {}
        end

        local spellName = GetSpellInfo(v["RankOneSpellID"]) or ''
        table.insert(elementTotemDictionary[v["ElementID"]], spellName)
    end

    function instance:UpdateActiveTotemInfo(totemIndexChanged)
        local function SetTimerText(totemIndex)
            if (not elementTotemDictionary[totemIndex]) then
                return
            end
    
            for k, v in pairs(elementTotemDictionary[totemIndex]) do
                local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndex)
                if (haveTotem and string.match(totemName, v)) then
                    instance:SetTexture(v)
                    local timeLeft = duration + startTime - GetTime()
                    if (timeLeft > 0) then
                        local d, h, m, s = ChatFrame_TimeBreakDown(timeLeft)
                        instance.frame.Count:SetFormattedText("%01d:%02d", m, s)
                        
                        if (not instance.frame:IsVisible()) then
                            instance.frame:Show()
                        end
        
                        C_Timer.NewTimer(0.2, function() SetTimerText(totemIndex) end)
                        return
                    end
                end
            end

            instance.frame:Hide()
        end

        SetTimerText(totemIndexChanged)
    end

    return instance
end