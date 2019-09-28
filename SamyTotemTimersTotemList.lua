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
    castTotemButton.selectedSpellChanged = function(self, button, spellName)
        if (totemListInstance.selectedSpellChanged) then
            totemListInstance:selectedSpellChanged(button, totemListId, spellName)
        end
    end

    castTotemButton:SetVisibility(false)

    return castTotemButton
end

local function CreateActiveTotemButton(parentFrame, totemInfoList, totemListId, castTotemButton, isOnlyShowTimerForSelectedTotem)
    local activeTotemButton = SamyTotemTimersActiveTotemButton:Create(parentFrame, totemInfoList, totemListId, castTotemButton, isOnlyShowTimerForSelectedTotem)
    return activeTotemButton
end

local function CreateTotemSelectButtons(selectListFrame, totemInfoList, castTotemButton)
    local totemSelectList = {}

    for k, v in pairs(totemInfoList) do
        local selectTotemButton = SamyTotemTimersSelectTotemButton:Create(selectListFrame, v, castTotemButton)
        selectTotemButton:SetVisibility(false)
        selectTotemButton.isEnabled = v.isEnabled
        totemSelectList[k] = selectTotemButton
    end

    return totemSelectList
end

function SamyTotemTimersTotemList:Create(parentFrame, totemListId, totemInfoList, isOnlyShowTimerForSelectedTotem, isShowBuffDuration)
    local instance = {}

    local frame = CreateFrame("Frame", "SamyTotemTimersTotemFrame" .. totemListId, parentFrame)
    frame:SetSize(SamyTotemTimersConfig.BUTTON_SIZE, SamyTotemTimersConfig.BUTTON_SIZE)

    local selectListFrame = CreateSelectListFrame(frame)
    local castTotemButton = CreateCastTotemButton(instance, frame, parentFrame, totemListId, selectListFrame)
    local activeTotemButton = nil

    if (isShowBuffDuration) then
        activeTotemButton = SamyTotemTimersBuffTotemButton:Create(frame, SamyTotemTimersUtils:FirstOrDefault(totemInfoList), totemListId)
    else
        activeTotemButton =  CreateActiveTotemButton(frame, totemInfoList, totemListId, castTotemButton, isOnlyShowTimerForSelectedTotem, isShowPulse)
    end

    local totemSelectList = CreateTotemSelectButtons(selectListFrame, totemInfoList, castTotemButton)

    local lastTotemSelectButton = nil

    function instance:SetEnabled(isEnabled)
        instance.isEnabled = isEnabled
    end

    function instance:SetOrder(order)
        instance.order = order or 0
    end

    function instance:SetVisibility(isVisible)
        if (isVisible) then
            frame:Show()        
        else
            frame:Hide()
        end
    end

    function instance:SetPosition(posX, posY)
        frame:SetPoint("LEFT", parentFrame, "LEFT", posX, 0)

        local selectListExtraHeight = SamyTotemTimersConfig.PULSESTATUSBARHEIGHT
        if (not instance.hasPulseTotems or not instance.isShowPulse) then
            selectListExtraHeight = 0
        end

        selectListFrame:SetPoint("LEFT", parentFrame, "LEFT", posX,  selectListExtraHeight + SamyTotemTimersConfig.BUTTON_SIZE * 2 + SamyTotemTimersConfig.VERTICAL_SPACING * 2)
        castTotemButton:SetPosition(0, 0)
        activeTotemButton:SetPosition(0, SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING)
    end

    function instance:SetTotemEnabled(totemName, isEnabled) 
        totemSelectList[totemName].isEnabled = isEnabled
    end

    function instance:SetIsShowPulse(isShowPulse)
        instance.isShowPulse = isShowPulse
        activeTotemButton:SetIsShowPulse(isShowPulse)
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

        local firstAvailableTotem = nil
        for k, v in pairs(totemSelectList) do
            if (SamyTotemTimersUtils:IsSpellsEqual(spellToHide, v.spellName) or not v.isEnabled) then
                v:SetVisibility(false)
                if (not v.isEnabled and SamyTotemTimersUtils:IsSpellsEqual(castTotemButton.spellName, v.spellName)) then
                    castTotemButton:ClearSpell()
                end
            elseif (v.isAvailable or v:UpdateIsAvailable()) then
                firstAvailableTotem = firstAvailableTotem or v
                v:SetVisibility(true)
                v:SetPosition(0, posY)
                instance.hasPulseTotems = instance.hasPulseTotems or v.pulseTime ~= nil 
                
                local checkY = topOfParent + posY + (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING) * 3
                if (checkY >= topOfScreen) then
                    multiplier = -1
                    posY = -(SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING) * 2.5
                end

                posY = posY + (multiplier * (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.VERTICAL_SPACING))
            end
        end

        if (not castTotemButton.spellName) then
            if (firstAvailableTotem) then
                castTotemButton:SetSpell(firstAvailableTotem.spellName, firstAvailableTotem.elementId, false, true)
                castTotemButton:SetVisibility(true)
            else
                castTotemButton:SetVisibility(false)
            end
        end
    end

    function instance:UpdateCooldown()
        for k, v in pairs(totemSelectList) do
            v:UpdateCooldown()
        end

        castTotemButton:UpdateCooldown()
    end

    function instance:UpdateActiveTotemInfo(totemIndexChanged, delay)
        activeTotemButton:UpdateActiveTotemInfo(totemIndexChanged, delay)
    end

    function instance:UpdateActiveTotemAffectedCount()
        activeTotemButton:UpdateActiveTotemAffectedCount()
    end

    return instance
end