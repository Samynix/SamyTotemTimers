local SamyTotemTimerButtonWrapper = {}
local config = SamyTotemTimersConfig:Instance()

function SamyTotemTimerButtonWrapper:New(buttonFrame)
    local instance = {}

    instance.buttonFrame = buttonFrame
    instance.mouseUpRightButton = nil
    instance.mouseUpLeftButton = nil
    instance.buttonFrame:SetScript("OnMouseUp", function(self, buttonPressed) 
        if (buttonPressed == "LeftButton" and instance.mouseUpLeftButton) then
            instance.mouseUpLeftButton(self)
        elseif (buttonPressed == "RightButton" and instance.mouseUpRightButton) then
            instance.mouseUpRightButton(self)
        end
    end)

    function instance:SetSpell(spell, isSave) 
        instance.buttonFrame:SetAttribute("type", "spell");
        instance.buttonFrame:SetAttribute("spell", spell);

        instance.spell = spell
        if (isSave) then
            config.db.lastUsedSpells[instance.buttonFrame:GetName()] = spell
        end
    end

    function instance:UpdateCooldown()
        if (instance.spell and instance.buttonFrame.cooldown) then
            CooldownFrame_Set(instance.buttonFrame.cooldown,  GetSpellCooldown(instance.spell))
        end
    end

    return instance
end

SamyTotemTimerTotemButton = {}
function SamyTotemTimerTotemButton:New(parentFrame, buttonSize, realtiveX, buttonName)
    local button = CreateFrame("Button", parentFrame:GetName() .. buttonName, parentFrame, "ActionButtonTemplate, SecureActionButtonTemplate")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    button:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", realtiveX, 0);
    button:RegisterForDrag('LeftButton')
    button:SetScript("OnDragStart", function (self)
        self:GetParent():SetMovable(true)
        self:GetParent():StartMoving()
    end)

    button:SetScript("OnDragStop", function (self) 
        self:GetParent():StopMovingOrSizing()
        self:GetParent():SetMovable(false)
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()

        local db = SamyTotemTimersConfig:Instance().db
        db.position.x = xOfs
        db.position.y = yOfs
        db.position.relativePoint = relativePoint
    end)

    button:SetScript("OnAttributeChanged",function(self, attribType, attribDetail)
        if attribType=="spell" then
            local spellId = (select(3,GetSpellInfo(attribDetail)))
            self.icon:SetTexture(spellId)
        end
    end)
    
    return SamyTotemTimerButtonWrapper:New(button)
end

SamyTotemTimerSelectTotemButton = {}
function SamyTotemTimerSelectTotemButton:New(samyTotemTimerTotemButton, buttonSize, spell)
    local parentFrame = samyTotemTimerTotemButton.buttonFrame
    local button = CreateFrame("Button", parentFrame:GetName() .. spell, parentFrame, "ActionButtonTemplate")
    button:SetFrameStrata("TOOLTIP")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    button.icon:SetTexture(select(3, GetSpellInfo(spell)))
    
    local buttonWrapper = SamyTotemTimerButtonWrapper:New(button)
    buttonWrapper.spell = spell
    return buttonWrapper
end

SamyTotemTimerActiveTotemButton = {}
function SamyTotemTimerActiveTotemButton:New(samyTotemTimerTotemButton, buttonSize, buttonName)
    local parentFrame = samyTotemTimerTotemButton.buttonFrame
    local name = parentFrame:GetName() .. buttonName .. "Active"
    local button = CreateFrame("Frame", name, parentFrame, "ActionButtonTemplate", "Background")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    
    local tY = buttonSize * config.buttonSpacingMultiplier
    button:SetPoint("BOTTOMLEFT", parentFrame, "TOPLEFT", 0, tY);
    button:Hide()

    local buttonWrapper = SamyTotemTimerButtonWrapper:New(button)

    local lastActiveTotem = nil
    function buttonWrapper:Update(totemIndex)
        local function setTimerText()
            local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totemIndex)
            local timeLeft = duration + startTime - GetTime()

            CooldownFrame_Set(button.cooldown, startTime, duration, haveTotem, true)

            if (haveTotem and timeLeft > 0) then
                if (lastActiveTotem ~= totemName) then
                    button.icon:SetTexture(icon)
                    lastActiveTotem = totemName
                end

                local d, h, m, s = ChatFrame_TimeBreakDown(timeLeft)
                button.Count:SetFormattedText("%01d:%02d", m, s)
                
                if (not button:IsVisible()) then
                    button:Show()
                end

                C_Timer.NewTimer(0.2, function() setTimerText() end)
            else
                button:Hide()
            end
        end

        setTimerText()
    end

    return buttonWrapper
end

