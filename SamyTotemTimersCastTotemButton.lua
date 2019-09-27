SamyTotemTimersCastTotemButton = {}

function SamyTotemTimersCastTotemButton:Create(parentFrame, mainFrame, totemListId, selectListFrame)
    local templates = "ActionButtonTemplate, SecureActionButtonTemplate, SecureHandlerMouseUpDownTemplate"
    local instance = SamyTotemTimersButtonBase:Create(parentFrame, SamyTotemTimersConfig:GetCastTotemButtonName(totemListId), templates)
    local originalFrameStrata = nil

    instance.frame:SetFrameRef("selectListFrame", selectListFrame)
    instance.frame:SetAttribute("_onmousedown", [[ -- (self, button)
        local selectFrame = self:GetFrameRef("selectListFrame")
        if (button == "RightButton") then
            if (selectFrame:IsVisible()) then
                selectFrame:Hide()
            else
                selectFrame:Show()
            end
        else
            --selectFrame:Hide() Taint maybe
        end
    ]])

    function instance:SetDraggable(isDraggable)
        if (isDraggable) then
            originalFrameStrata = instance.frame:GetFrameStrata()
            instance.frame:RegisterForDrag('LeftButton')
            ActionButton_ShowOverlayGlow(instance.frame)
            instance.frame:SetFrameStrata("TOOLTIP")
        else
            instance.frame:RegisterForDrag(nil)
            ActionButton_HideOverlayGlow(instance.frame)
            instance.frame:SetFrameStrata(originalFrameStrata)
        end
    end

    instance.frame:SetScript("OnDragStart", function (self)
        mainFrame:SetMovable(true)
        mainFrame:StartMoving()
    end)

    instance.frame:SetScript("OnDragStop", function (self) 
        mainFrame:StopMovingOrSizing()
        mainFrame:SetMovable(false)
        
        if (instance.positionChanged) then
            instance:positionChanged()
        end
    end)

    return instance
end