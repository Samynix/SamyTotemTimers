SamyTotemTimersSelectTotemButton = {}

function SamyTotemTimersSelectTotemButton:Create(parentFrame, totemInfo, castTotemButton)
    local spellName = GetSpellInfo(totemInfo["RankOneSpellID"]) or ''
    local templates = "ActionButtonTemplate, SecureActionButtonTemplate, SecureHandlerMouseUpDownTemplate"
    local instance = SamyTotemTimersButtonBase:Create(parentFrame, "SamyTotemTimers" .. spellName .. "SelectTotemButton", templates)
    instance.pulseTime = totemInfo["PulseTime"]

    instance.frame:SetFrameRef("selectListFrame", parentFrame)
    instance.frame:SetFrameRef("castTotemButton", castTotemButton.frame)
    instance.frame:SetAttribute("_onmousedown", [[ -- (self, button)
        local selectFrame = self:GetFrameRef("selectListFrame")
        local castTotemButton = self:GetFrameRef("castTotemButton")

        if (button == "RightButton") then
            if (selectFrame:IsVisible()) then
                selectFrame:Hide()
                if (castTotemButton) then
                    castTotemButton:SetAttribute("type", "spell");
                    castTotemButton:SetAttribute("spell", self:GetAttribute("spell"));
                end
            end
        else
            --selectFrame:Hide() Taint maybe
        end
    ]])

    instance.frame:HookScript("OnMouseDown", function(self, button)
        if (button == "RightButton") then
            castTotemButton:SetSpell(instance.spellName, instance.elementId, true)
        end
    end)

    instance.frame:SetScript("OnShow", function(self) 
        self.NormalTexture:Show()
    end)

    function instance:UpdateIsAvailable()
        if (SamyTotemTimersUtils:StringIsNilOrEmpty(spellName) or not GetSpellBookItemInfo(spellName)) then
            instance.isAvailable = false
            return false
        end

        if (not instance.isAvailable) then
            instance:SetSpell(spellName, totemInfo["ElementID"])
        end

        instance.isAvailable = true        
        return true
    end

    return instance
end