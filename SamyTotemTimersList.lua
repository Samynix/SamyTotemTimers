SamyTotemTimerList = {}
function SamyTotemTimerList:New(parentFrame, relativeX, totemType)
    local _instance  = { ["Name"] = totemType }
    local _config = SamyTotemTimersConfig:Instance()
    local _isTotemSelectListVisible = false

    local _dropTotemButton = nil
    local _activeTotemButton = nil
    local _selectTotemTable = {}

    local _foundSpells = false

    _dropTotemButton = SamyTotemTimerTotemButton:Create(parentFrame, _config.buttonSize, relativeX, totemType)
    _dropTotemButton.mouseUpRightButton = function(self)
        if (UnitAffectingCombat('player')) then
            return
        end
        
        _instance:Refresh(not _isTotemSelectListVisible)
    end
    _instance.DropTotemButton = _dropTotemButton

    _activeTotemButton = SamyTotemTimerActiveTotemButton:Create(_dropTotemButton, _config.buttonSize, totemType)
    
    for k, v in pairs(_config.totems[totemType]) do
        local selectTotemButton = SamyTotemTimerSelectTotemButton:Create(_dropTotemButton, _config.buttonSize, v)
        selectTotemButton.buttonFrame:SetScript("OnClick", function(self, button) 
            if (UnitAffectingCombat('player')) then
                return
            end

            _dropTotemButton:SetSpell(selectTotemButton.spell, true)
            _instance:Refresh(false)
        end)

        table.insert(_selectTotemTable, selectTotemButton)
    end

    function _instance:SetDraggable(isDraggable)
        _dropTotemButton:SetDraggable(isDraggable)
    end

    function _instance:Refresh(isShowSelectList)
        _isTotemSelectListVisible = isShowSelectList

        local tY = _config.buttonSize * _config.buttonSpacingMultiplier
        for k, v in pairs(_selectTotemTable) do
            v.buttonFrame:Hide()
            if (GetSpellBookItemInfo(v.spell)) then
                v.buttonFrame:SetPoint("BOTTOMLEFT", v.buttonFrame:GetParent(), "TOPLEFT", 0, tY);
                tY = tY + _config.buttonSize * (1 + _config.buttonSpacingMultiplier)

                if (isShowSelectList and not v.buttonFrame:IsVisible()) then
                    v.buttonFrame:Show()
                end

                if (not _dropTotemButton.spell) then
                    _dropTotemButton.SetSpell(v.spell)
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

    function _instance:OnUpdate()
        if (not _foundSpells) then
            if (GetSpellBookItemInfo('Lightning Bolt')) then
                _foundSpells = true
                _instance:LoadSavedVariables()
            end
        end

        _dropTotemButton.UpdateSpellUsable()
    end

    function _instance:PLAYER_ENTER_COMBAT()
        _isTotemSelectListVisible = false
    end

    function _instance:ADDON_LOADED()
        for k, v in pairs(_selectTotemTable) do
            v:ADDON_LOADED()
        end
    end

    function _instance:LoadSavedVariables()
        local savedSpell = _config.db.lastUsedSpells[_dropTotemButton.buttonFrame:GetName()]
        if (savedSpell and GetSpellBookItemInfo(savedSpell)) then
            _dropTotemButton:SetSpell(savedSpell)
        else
            for k, v in pairs(_selectTotemTable) do
                if (GetSpellBookItemInfo(v.spell)) then
                    _dropTotemButton:SetSpell(v.spell)
                    return
                end
            end
        end
    end

    return _instance
end