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

    return instance
end