SamyTotemTimersTotemList = {}

local function CreateSelectListFrame(parentFrame)
    local selectListFrame = CreateFrame("Frame", "SamyTotemTimersSelectListFrame", parentFrame)
    selectListFrame:SetSize(SamyTotemTimersConfig.BUTTON_SIZE, SamyTotemTimersConfig.BUTTON_SIZE)
    selectListFrame:SetFrameStrata("HIGH")
    selectListFrame:Hide()

    return selectListFrame
end

local function CreateCastTotemButton(totemListInstance, parentFrame, mainFrame, totemListId, selectListFrame)
    local castTotemButton = SamyTotemTimersCastTotemButton:Create(parentFrame, mainFrame, totemListId, selectListFrame)
    castTotemButton.selectedSpellChanged = function(self, spellName)
        if (totemListInstance.selectedSpellChanged) then
            totemListInstance:selectedSpellChanged(totemListId, spellName)
        end
    end

    castTotemButton.positionChanged = function() 
        if (totemListInstance.positionChanged) then
            totemListInstance:positionChanged()
        end
    end

    castTotemButton:SetVisibility(false)

    return castTotemButton
end

local function CreateActiveTotemButton(parentFrame, totemInfoList, totemListId)
    local activeTotemButton = SamyTotemTimersActiveTotemButton:Create(parentFrame, totemInfoList, totemListId)
    return activeTotemButton
end

local function CreateTotemSelectButtons(selectListFrame, totemInfoList, castTotemButton)
    local totemSelectList = {}

    for k, v in pairs(totemInfoList) do
        local selectTotemButton = SamyTotemTimersSelectTotemButton:Create(selectListFrame, v, castTotemButton)
        selectTotemButton:SetVisibility(false)
        table.insert(totemSelectList, selectTotemButton)
    end

    return totemSelectList
end

function SamyTotemTimersTotemList:Create(parentFrame, totemListId, totemInfoList)
    local instance = {}

    local frame = CreateFrame("Frame", "SamyTotemTimersTotemFrame" .. totemListId, parentFrame)
    frame:SetSize(SamyTotemTimersConfig.BUTTON_SIZE, SamyTotemTimersConfig.BUTTON_SIZE)

    local selectListFrame = CreateSelectListFrame(frame)
    local castTotemButton = CreateCastTotemButton(instance, frame, parentFrame, totemListId, selectListFrame)
    local activeTotemButton = CreateActiveTotemButton(frame, totemInfoList, totemListId)
    local totemSelectList = CreateTotemSelectButtons(selectListFrame, totemInfoList, castTotemButton)

    local lastTotemSelectButton = nil

    function instance:SetEnabled(isEnabled)
        instance.isEnabled = isEnabled
    end

    function instance:SetVisibility(isVisible)
        if (isVisible) then
            frame:Show()        
        else
            frame:Hide()
        end
    end

    function instance:SetPosition(posX, posY)
        frame:SetPoint("CENTER", parentFrame, "CENTER", posX, 0)
        selectListFrame:SetPoint("CENTER", parentFrame, "CENTER", posX, 0 + SamyTotemTimersConfig.BUTTON_SIZE * 2 + SamyTotemTimersConfig.VERTICAL_SPACING * 2)
        castTotemButton:SetPosition(0, 0)
        activeTotemButton:SetPosition(0, SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING)
    end

    function instance:SetDraggable(isDraggable)
        if (isDraggable) then
            castTotemButton.frame:RegisterForDrag('LeftButton')
            ActionButton_ShowOverlayGlow(castTotemButton.frame)
        else
            castTotemButton.frame:RegisterForDrag(nil)
            ActionButton_HideOverlayGlow(castTotemButton.frame)
        end
    end

    function instance:SetSelectedTotem(spellName)
        local totemSelectButton = nil
        for k, v in pairs(totemSelectList) do
            if (v.isAvailable and (v.spellName == spellName or not totemSelectButton)) then
                totemSelectButton = v
            end
        end

        if (totemSelectButton) then
            castTotemButton:SetSpell(totemSelectButton.spellName, totemSelectButton.elementId, false)
            castTotemButton:SetVisibility(true)
        end
    end

    function instance:RefreshTotemSelectList(spellToHide)
        local posY = 0
        local multiplier = 1
        local topOfScreen = UIParent:GetTop()
        local topOfParent = parentFrame:GetTop()

        for k, v in pairs(totemSelectList) do
            if (SamyTotemTimersUtils:IsSpellsEqual(spellToHide, v.spellName)) then
                v:SetVisibility(false)
            elseif (v.isAvailable or v:UpdateIsAvailable()) then
                v:SetVisibility(true)
                v:SetPosition(0, posY)
                
                local checkY = topOfParent + posY + (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING) * 3
                if (checkY >= topOfScreen) then
                    multiplier = -1
                    posY = -(SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING) * 2
                end

                posY = posY + (multiplier * (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING))
            end
        end
    end

    function instance:UpdateCooldown()
        for k, v in pairs(totemSelectList) do
            v:UpdateCooldown()
        end

        castTotemButton:UpdateCooldown()
    end

    function instance:UpdateActiveTotemInfo(totemIndexChanged)
        activeTotemButton:UpdateActiveTotemInfo(totemIndexChanged)
    end

    return instance
end