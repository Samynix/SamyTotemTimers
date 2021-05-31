SamyTotemTimersActiveTotemButton = {}

local function CreateMissingBuffOverlay(parentFrame)
    local frame = CreateFrame("Frame", nil, parentFrame)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetWidth(parentFrame:GetWidth()) 
    frame:SetHeight(parentFrame:GetHeight())

    local texture = frame:CreateTexture(nil,"TOOLTIP")
    texture:SetColorTexture(1, 0, 0, 0.4)
    texture:SetAllPoints(frame)
    frame.texture = texture
    
    frame:SetPoint("CENTER", 0, 0)
    return frame
end

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

function SamyTotemTimersActiveTotemButton:Create(parentFrame, availableTotems, totemListId, castTotemButton, isOnlyShowSelectedTotem)
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
    instance.affectedFontString:SetPoint("TOP", instance.frame, "TOP", 0, -2)
    instance.affectedFontString:Hide()

    instance.missingBuffOverlay = CreateMissingBuffOverlay(instance.frame)
    instance.missingBuffOverlay:Hide()

    function instance:SetVisibility(isVisible) end --override

    function instance:SetIsShowPulse(isShowPulse)
        instance.isShowPulse = isShowPulse
    end

    local elementTotemDictionary = {}
    for k, v in pairs(availableTotems) do
        if (not elementTotemDictionary[v["ElementID"]]) then
            elementTotemDictionary[v["ElementID"]] = {}
        end

        local spellName = GetSpellInfo(v["RankOneSpellID"])
        table.insert(elementTotemDictionary[v["ElementID"]], {
            ["spellName"] = spellName,
            ["pulseTime"] = v["PulseTime"],
            ["buffDuration"] = v["BuffDuration"],
            ["elementId"] = v["ElementID"],
            ["hasBuff"] = v["hasBuff"],
        })
    end

    local function DoWork()
        if (not instance.hasTotem) then
            instance:SetSpell(nil, nil)
            instance.frame:Hide()

            C_Timer.NewTimer(0.1, function() DoWork() end)
            return
        end

        local timeLeft = instance.duration + instance.startTime - GetTime()

        instance:SetTexture(instance.activeTotem.spellName)
        instance:SetSpell(instance.activeTotem.spellName, instance.activeTotem.elementId, true)
        instance:SetHasBuff(instance.activeTotem.hasBuff)

        if (instance.activeTotem.pulseTime and instance.isShowPulse) then
            local pulseTime = instance.activeTotem.pulseTime - timeLeft % instance.activeTotem.pulseTime
            instance.pulseStatusBar:SetMinMaxValues(0, instance.activeTotem.pulseTime)
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

        C_Timer.NewTimer(0.1, function() DoWork() end)
    end

    DoWork()

    function instance:UpdateActiveTotemInfo(totemIndexChanged, latency)
        if (not elementTotemDictionary[totemIndexChanged]) then
            return
        end

        for k, v in pairs(elementTotemDictionary[totemIndexChanged]) do
            local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndexChanged)
            local isSelectedTotem = SamyTotemTimersUtils:IsSpellsEqual(castTotemButton.spellName, v.spellName)
    
            if (haveTotem and string.match(totemName, v.spellName) and (not isOnlyShowSelectedTotem or isSelectedTotem)) then
                instance.activeTotem = v
                instance.hasTotem = true
                instance.startTime = startTime + latency
                instance.duration = duration
                return                
            end
        end

        instance.activeTotem = nil
        instance.hasTotem = false
    end

    function instance:UpdateActiveTotemAffectedCount()
        if (instance.spellName) then
            local affected = 0
            local units = { "player", "party1", "party2", "party3", "party4" }
            for k, v in pairs(units) do
                local buffs = SamyTotemTimersUtils:GetUnitBuffs(v)
                local foundBuff = false
                for k2, v2 in pairs(buffs) do
                    if (string.match(instance.spellName, v2.name)) then
                        affected = affected + 1
                        foundBuff = true
                    end
                end

                if v == "player" then
                    if SamyTotemTimersDB.isWarnIfMissingBuff and instance.hasBuff and not foundBuff then
                        instance.missingBuffOverlay:Show()
                    else
                        instance.missingBuffOverlay:Hide()
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