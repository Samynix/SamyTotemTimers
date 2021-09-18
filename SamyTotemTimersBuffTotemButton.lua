SamyTotemTimersBuffTotemButton = {}

function SamyTotemTimersBuffTotemButton:Create(parentFrame, totemInfo, totemListId)
    local templates = "ActionButtonTemplate"
    local instance = SamyTotemTimersButtonBase:Create(parentFrame, "SamyTotemTimers" .. totemListId .. "BuffTotemButton", templates)
    instance.frame:SetEnabled(false)
    instance.frame.NormalTexture:Hide()
    instance.frame.Border:Hide()
    instance.frame:SetScript("OnShow", function(self) 
        self.NormalTexture:Hide()
        self.Border:Hide()
    end)
    instance.frame:Show()

    function instance:SetVisibility(isVisible) end --override
    function instance:SetIsShowPulse(isPulse) end
    function instance:UpdateActiveTotemAffectedCount() end

    totemInfo = totemInfo or {}

    local elementId = totemInfo["ElementID"]
    local spellName = GetSpellInfo(totemInfo["RankOneSpellID"])
    local pulseTime = totemInfo["PulseTime"]
    local buffDuration = totemInfo["BuffDuration"]
    local hasBuff = totemInfo["hasBuff"]

    local function DoWork(currentBuffTimeLeft, timestampLastCalculation)
        if (not instance.hasTotem and (not currentBuffTimeLeft or not timestampLastCalculation)) then
            C_Timer.NewTimer(0.1, function() DoWork(currentBuffTimeLeft, timestampLastCalculation) end)
            return
        end

        if (instance.hasTotem) then
            local timeLeft = instance.duration + instance.startTime - GetTime()  
            currentBuffTimeLeft = (timeLeft % pulseTime) + (buffDuration - pulseTime)
        else
            currentBuffTimeLeft = currentBuffTimeLeft - (GetTime() - timestampLastCalculation)
        end
        
        print('jalla')
        timestampLastCalculation = GetTime()
        if (currentBuffTimeLeft > 0) then
            instance:SetTexture(spellName)
            instance:SetSpell(spellName, totemIndex, true)
            instance:SetHasBuff(hasBuff)

            local d, h, m, s = ChatFrame_TimeBreakDown(currentBuffTimeLeft)
            instance.frame.Count:SetFormattedText("%01d:%02d", m, s)
            
            if (not instance.frame:IsVisible()) then
                instance.frame:Show()
            end
        else    
            instance:SetSpell(nil, nil)
            instance.frame:Hide()
        end

        C_Timer.NewTimer(0.1, function() DoWork(currentBuffTimeLeft, timestampLastCalculation) end)
    end

    DoWork(nil, nil)

    function instance:UpdateActiveTotemInfo(totemIndexChanged, latency)
        if (totemIndexChanged ~= elementId) then
            return
        end

        local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndexChanged)
        if (not haveTotem or not string.match(totemName, spellName)) then
            instance.hasTotem = false
        else
            instance.hasTotem = true
            instance.startTime = startTime + latency
            instance.duration = duration
        end
    end

    return instance
end