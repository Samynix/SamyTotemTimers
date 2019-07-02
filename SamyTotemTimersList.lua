SamyTotemTimerList = {}

local function createButton(parentFrame, tX, buttonSize, name)
    local button = CreateFrame("Button", name, parentFrame, "ActionButtonTemplate, SecureActionButtonTemplate")
    button:SetWidth(buttonSize)
    button:SetHeight(buttonSize)
    button:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", tX, 0);
    button:Show()

    return button
end

local function createSelectTotemButton(spell, buttonSize, name, selectTotemCallback)
    local buttonFrame = CreateFrame("Button", name, parentFrame, "ActionButtonTemplate")
    buttonFrame:SetWidth(buttonSize)
    buttonFrame:SetHeight(buttonSize)
    buttonFrame.icon:SetTexture(select(3, GetSpellInfo(spell)))
    buttonFrame:SetScript("OnClick", selectTotemCallback)

    return {buttonFrame = buttonFrame, spell = spell}
end

local function createDropTotemButton(parentFrame, tX, name)
    local button = createButton(parentFrame, tX, SamyTotemTimersConfig:Instance().db.buttonSize, name)
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
            self.icon:SetTexture((select(3,GetSpellInfo(attribDetail))))
        end
    end)

    return button
end

local function selectTotem(totemButton, listName, spell)
    totemButton:SetAttribute("type", "spell");
    totemButton:SetAttribute("spell", spell);
    SamyTotemTimersDB.selectedTotems[listName] = spell
end

function SamyTotemTimerList:New(parentFrame, tX, listName, totemsInList)
    local instance  = {}
    local config = SamyTotemTimersConfig:Instance()
    local isTotemListVisible = false
    local totemButton = createDropTotemButton(parentFrame, tX, "SamyTotemTimersFrame" .. listName .. "Button")
    totemButton:SetScript("OnMouseUp", function (self, button) 
        if (button == "RightButton") then 
            instance:RefreshTotemSelectButtons(not isTotemListVisible)
        end
    end)

    local totemSelectButtons = {}
    for k, v in pairs(totemsInList) do
        local selectTotemButton = createSelectTotemButton(v, config.db.buttonSize, "SamyTotemTimersFrame" .. listName .. v .. "Button", function(self)
            selectTotem(totemButton, listName, v)
            instance:RefreshTotemSelectButtons(false)
        end)

        table.insert(totemSelectButtons, selectTotemButton)
    end

    function instance:SetKeyboardShortcut(shortcut)
        SetBindingClick(shortcut, totemButton:GetName())
    end

    function instance:RefreshTotemSelectButtons(isShow)
        isTotemListVisible = isShow

        local tY = config.db.buttonSize * config.buttonSpacingMultiplier
        for k, v in pairs(totemSelectButtons) do
            v.buttonFrame:Hide()
            local isUsable, noMana = IsUsableSpell(v.spell)
            if (isUsable or noMana) then
                v.buttonFrame:SetPoint("BOTTOMLEFT", totemButton, "TOPLEFT", 0, tY);
                tY = tY + config.db.buttonSize * (1 + config.buttonSpacingMultiplier)

                if (isShow and not v.buttonFrame:IsVisible()) then
                    v.buttonFrame:Show()
                end
            end
        end
    end


    if (SamyTotemTimersDB.selectedTotems[listName]) then
        selectTotem(totemButton, listName, SamyTotemTimersDB.selectedTotems[listName])
    end

    if (SamyTotemTimersDB.keyboardShortcuts[listName]) then
        instance:SetKeyboardShortcut(SamyTotemTimersDB.keyboardShortcuts[listName])
    end

    return instance
end