SamyTotemTimersActiveTotemButton = {}

local function CreatePulseStatusBar(parentFrame)
    local statusbar = CreateFrame("StatusBar", nil, parentFrame)
    statusbar:SetPoint("BOTTOM", parentFrame, "TOP", 0, 0)
    statusbar:SetWidth(parentFrame:GetWidth())
    statusbar:SetHeight(SamyTotemTimersConfig.PULSESTATUSBARHEIGHT)
    statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    statusbar:GetStatusBarTexture():SetHorizTile(false)
    statusbar:GetStatusBarTexture():SetVertTile(false)
    statusbar:SetStatusBarColor(0, 0.65, 0)

    statusbar.value = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.value:SetPoint("LEFT", statusbar, "LEFT", 4, 0)
    statusbar.value:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    statusbar.value:SetJustifyH("LEFT")
    statusbar.value:SetShadowOffset(1, -1)
    statusbar.value:SetTextColor(0, 1, 0)

    statusbar:Hide()
    return statusbar
end

function SamyTotemTimersActiveTotemButton:Create(parentFrame, availableTotems, totemListId)
    local templates = "ActionButtonTemplate"
    local instance = SamyTotemTimersButtonBase:Create(parentFrame, "SamyTotemTimers" .. totemListId .. "ActiveTotemButton", templates)
    instance.pulseStatusBar = CreatePulseStatusBar(instance.frame)
    instance.frame:SetEnabled(false)
    instance.frame.NormalTexture:Hide()
    instance.frame.Border:Hide()
    instance.frame:SetScript("OnShow", function(self) 
        self.NormalTexture:Hide()
        self.Border:Hide()
    end)
    instance.frame:Show()

    instance.affectedFontString = instance.frame:CreateFontString(instance.frame:GetName() .. "AffectedText", "OVERLAY", "NumberFontNormal")
    --instance.affectedFontString:SetFont("Fonts\\FRIZQT__.TTF", 14)
    instance.affectedFontString:SetPoint("TOP", instance.frame, "TOP", 0, -2)
    instance.affectedFontString:Hide()

    function instance:SetVisibility(isVisible) end --override

    local elementTotemDictionary = {}
    for k, v in pairs(availableTotems) do
        if (not elementTotemDictionary[v["ElementID"]]) then
            elementTotemDictionary[v["ElementID"]] = {}
        end

        local spellName = GetSpellInfo(v["RankOneSpellID"])
        table.insert(elementTotemDictionary[v["ElementID"]], {
            ["spellName"] = spellName,
            ["pulseTime"] = v["PulseTime"],
            ["buffDuration"] = v["BuffDuration"]
        })
    end

    function instance:UpdateActiveTotemInfo(totemIndexChanged)
        local function SetTimerText(totemIndex)
            if (not elementTotemDictionary[totemIndex]) then
                return
            end
    
            for k, v in pairs(elementTotemDictionary[totemIndex]) do
                local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndex)
                if (haveTotem and string.match(totemName, v.spellName)) then
                    instance:SetTexture(v.spellName)
                    instance:SetSpell(v.spellName, totemIndex, true)
                    local timeLeft = duration + startTime - GetTime()
                    if (timeLeft > 0) then
                        if (v.pulseTime) then
                            local pulseTime = v.pulseTime - timeLeft % v.pulseTime
                            instance.pulseStatusBar:SetMinMaxValues(0, v.pulseTime)
                            instance.pulseStatusBar:SetValue(pulseTime)
                            instance.pulseStatusBar.value:SetText(SamyTotemTimersUtils:Round(pulseTime, 1))
                            instance.pulseStatusBar:Show()
                        else
                            instance.pulseStatusBar:Hide()
                        end

                        local d, h, m, s = ChatFrame_TimeBreakDown(timeLeft)
                        instance.frame.Count:SetFormattedText("%01d:%02d", m, s)
                        
                        if (not instance.frame:IsVisible()) then
                            instance.frame:Show()
                        end
        
                        C_Timer.NewTimer(0.05, function() SetTimerText(totemIndex) end)
                        return
                    end
                end
            end

            instance:SetSpell(nil, nil)
            instance.frame:Hide()
        end

        SetTimerText(totemIndexChanged)
    end

    function instance:UpdateActiveTotemAffectedCount()
        if (instance.spellName) then
            local affected = 0
            local units = { "player", "party1", "party2", "party3", "party4" }
            for k, v in pairs(units) do
                local buffs = SamyTotemTimersUtils:GetUnitBuffs(v)
                for k2, v2 in pairs(buffs) do
                    if (string.match(instance.spellName, v2.name)) then
                        affected = affected + 1
                    end
                end
            end

            if (affected > 0) then
                instance.affectedFontString:Show()
                instance.affectedFontString:SetText(tostring(affected))
            else
                instance.affectedFontString:Hide()
            end
        end
    end

    return instance
end