SamyTotemTimerList = {}
function SamyTotemTimerList:New(parentFrame, relativeX, totemType)
    local _instance  = { ["Name"] = totemType }
    local _config = SamyTotemTimersConfig:Instance()
    local _isTotemSelectListVisible = false

    local _dropTotemButton = nil
    local _activeTotemButton = nil
    local _selectTotemTable = {}

    _dropTotemButton = SamyTotemTimerTotemButton:New(parentFrame, _config.buttonSize, relativeX, totemType)
    _dropTotemButton.mouseUpRightButton = function(self)
        _instance:Refresh(not _isTotemSelectListVisible)
    end
    _instance.DropTotemButton = _dropTotemButton

    _activeTotemButton = SamyTotemTimerActiveTotemButton:New(_dropTotemButton, _config.buttonSize, totemType)
    
    for k, v in pairs(_config.totems[totemType]) do
        local selectTotemButton = SamyTotemTimerSelectTotemButton:New(_dropTotemButton, _config.buttonSize, v)
        selectTotemButton.buttonFrame:SetScript("OnClick", function(self) 
            _dropTotemButton:SetSpell(selectTotemButton.spell, true)
            _instance:Refresh(false)
        end)

        table.insert(_selectTotemTable, selectTotemButton)
    end

    function _instance:Refresh(isShowSelectList)
        _isTotemSelectListVisible = isShowSelectList

        local tY = _config.buttonSize * _config.buttonSpacingMultiplier
        for k, v in pairs(_selectTotemTable) do
            v.buttonFrame:Hide()
            local isUsable, noMana = IsUsableSpell(v.spell)
            if (isUsable or noMana) then
                v.buttonFrame:SetPoint("BOTTOMLEFT", v.buttonFrame:GetParent(), "TOPLEFT", 0, tY);
                tY = tY + _config.buttonSize * (1 + _config.buttonSpacingMultiplier)

                if (isShowSelectList and not v.buttonFrame:IsVisible()) then
                    v.buttonFrame:Show()
                end
            end
        end
    end

    function _instance:UpdateCooldown()
        _dropTotemButton:UpdateCooldown()
        for k, v in pairs(_selectTotemTable) do
            v:UpdateCooldown()
        end
    end

    function _instance:UpdateActiveTotem()
        _activeTotemButton:Update(_config.totems[totemType .. "Index"])
    end

    function _instance:ADDON_LOADED()
        if (_config.db.lastUsedSpells[_dropTotemButton.buttonFrame:GetName()]) then
            _dropTotemButton:SetSpell(_config.db.lastUsedSpells[_dropTotemButton.buttonFrame:GetName()])
        end
    end

    return _instance
end