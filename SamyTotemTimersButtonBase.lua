SamyTotemTimersButtonBase = {}

function SamyTotemTimersButtonBase:Create(parentFrame, frameName, templates)
    local instance = {}

    instance.frame = CreateFrame("Button", frameName, parentFrame, templates)
    instance.frame:SetSize(SamyTotemTimersConfig.BUTTON_SIZE, SamyTotemTimersConfig.BUTTON_SIZE)

    instance.frame:HookScript('OnEnter', function(self, motion)
        local spellName = self:GetAttribute("spell")
        if (spellName) then
            GameTooltip:SetOwner(self)
            local numOfSpellTabs = GetNumSpellTabs()
            for i = 1, numOfSpellTabs, 1 do
                local name, texture, offset, numSpells = GetSpellTabInfo(i);
                
                for j = offset + numSpells, offset+1, -1 do
                    local type, bookSpellId = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
                    local spellBookName = GetSpellInfo(bookSpellId)
                    if (spellName == spellBookName) then
                        GameTooltip:SetSpellBookItem(j, BOOKTYPE_SPELL)
                        GameTooltip:Show()
                        return
                    end
                end
            end
        end
    end)

    instance.frame:HookScript('OnLeave', function(self, motion)
        if (GameTooltip:GetOwner() == self) then
            GameTooltip:Hide()
        end
    end)

    instance.frame:SetScript("OnAttributeChanged",function(self, attribType, attribDetail)
        if attribType=="spell" then
            instance:SetTexture(attribDetail)
            if (instance.selectedSpellChanged) then
                instance:selectedSpellChanged(self, attribDetail)
            end
        end
    end)

    function instance:SetTexture(spellName)
        if (not SamyTotemTimersUtils:StringIsNilOrEmpty(spellName)) then
            instance.frame.icon:SetTexture(select(3, GetSpellInfo(spellName)))
        end
    end

    function instance:SetSpell(spellName, elementId, isSecure)
        if (not isSecure and not SamyTotemTimersUtils:StringIsNilOrEmpty(spellName)) then
            instance.frame:SetAttribute("type", "spell");
            instance.frame:SetAttribute("spell", spellName);
        end

        instance.spellName = spellName
        instance.elementId = elementId
    end
    
    function instance:SetPosition(x, y)
        instance.frame:SetPoint("CENTER", parentFrame, "CENTER", x, y);
    end

    function instance:SetVisibility(isVisible)
        if (isVisible) then
            instance.frame:Show()
        else 
            instance.frame:Hide()
        end
    end

    function instance:UpdateCooldown()
        local spellName = instance.frame:GetAttribute("spell")
        if (spellName and instance.frame.cooldown) then
            CooldownFrame_Set(instance.frame.cooldown,  GetSpellCooldown(spellName))
        end
    end

    

    return instance

end