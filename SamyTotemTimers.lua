local _samyTotemTimers = LibStub("AceAddon-3.0"):NewAddon("SamyTotemTimers", "AceEvent-3.0")

local _totemLists = {}
local _isUpdateTotemLists = false
local _timeSinceLastUpdate = 0

local function IsPlayerShaman()
    local localizedClass, englishClass, classIndex = UnitClass("player");
    return englishClass == "SHAMAN"
end

local function RefreshTotemLists(frame, isSelectTotem)
    if (UnitAffectingCombat("PLAYER")) then
        _isUpdateTotemLists = true
        return
    end

    local totalWidth = 0
    local counter = 1

    local sortedTotemList = {}
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v.listId = k
            table.insert(sortedTotemList, v)
        else
            v:SetVisibility(false)
        end
    end
    table.sort(sortedTotemList, function(left, right)
        local leftValue = 0
        if (left and left.order) then
            leftValue = left.order
        end

        local rightValue = 0
        if (right and right.order) then
            rightValue = right.order
        end
        
        return leftValue < rightValue
    end)
    
    for k, v in pairs(sortedTotemList) do
        if (v.isEnabled) then
            totalWidth = totalWidth + SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.HORIZONTAL_SPACING
            frame:SetSize(totalWidth, SamyTotemTimersConfig.BUTTON_SIZE)

            v:SetVisibility(true)
            v:SetPosition(counter * (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.HORIZONTAL_SPACING), 0)
            v:RefreshTotemSelectList(SamyTotemTimersDb:GetLastUsedTotem(v.listId))
            if (isSelectTotem) then
                v:SetSelectedTotem(SamyTotemTimersDb:GetLastUsedTotem(v.listId))
            end

            counter = counter + 1
        else
            v:SetVisibility(false)
        end
    end
end

local function CreateTotemLists(parentFrame)
    local totemLists = {}

    for k, v in pairs(SamyTotemTimersDb:GetTotemLists()) do
        local totemList = SamyTotemTimersTotemList:Create(parentFrame, k, v["totems"], v["IsOnlyShowTimerForSelectedTotem"])
        totemList:SetEnabled(v["isEnabled"])
        totemList:SetOrder(v["order"])
        totemList.selectedSpellChanged = function(self, totemListId, spellName) 
            SamyTotemTimersDb:SelectedSpellChanged(totemListId, spellName)
            RefreshTotemLists(parentFrame, false)
        end

        totemList.positionChanged = function () 
            SamyTotemTimersDb.PositionChanged()
            RefreshTotemLists(parentFrame, false)
        end

        totemLists[k] = totemList
    end

    return totemLists
end

function _samyTotemTimers:OnInitialize()
    if (not IsPlayerShaman()) then
        SamyTotemTimersUtils:Print("Not loaded. Only works for shamans")
        return
    end

    SamyTotemTimersDb:OnInitialize(self)

    self.frame = CreateFrame("Frame", "SamyTotemTimersFrame", UIParent)
    self.frame:SetScript("OnUpdate", self.OnUpdate) 

    local totemLists, totalWidth = CreateTotemLists(self.frame)
    _totemLists = totemLists

    SamyTotemTimersDb:RestoreScaleAndPosition()
    self.frame:Show()

    SamyTotemTimersUtils:Print("Loaded")
end

function _samyTotemTimers:SetDraggable(isDraggable)
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v:SetDraggable(isDraggable)
        end
    end
end

function _samyTotemTimers:SetListEnabled(listId, isEnabled)
    _totemLists[listId]:SetEnabled(isEnabled)
    RefreshTotemLists(_samyTotemTimers.frame, true)
end

function _samyTotemTimers:SetTotemEnabled(listId, totemName, isEnabled)
    _totemLists[listId]:SetTotemEnabled(totemName, isEnabled)
    RefreshTotemLists(_samyTotemTimers.frame, true)
end

function _samyTotemTimers:TotemListsOrderChanged(listOfOrdersChanged)
    for k, v in pairs(listOfOrdersChanged) do
        _totemLists[k]:SetOrder(v)
    end

    RefreshTotemLists(_samyTotemTimers.frame, true)
end

function _samyTotemTimers:OnUpdate(elapsed)
    _timeSinceLastUpdate = _timeSinceLastUpdate + elapsed
    if (_timeSinceLastUpdate < SamyTotemTimersConfig.ONUPDATEDELAY) then
        return
    end

    _timeSinceLastUpdate = 0
    for k, v in pairs(_totemLists) do
        v:UpdateActiveTotemAffectedCount()
    end
end

_samyTotemTimers:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", function()
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v:UpdateCooldown()
        end
    end
end)

_samyTotemTimers:RegisterEvent("PLAYER_TOTEM_UPDATE", function(self, totemIndex) 
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v:UpdateActiveTotemInfo(totemIndex)
        end
    end
end)

_samyTotemTimers:RegisterEvent("SPELLS_CHANGED", function()
    RefreshTotemLists(_samyTotemTimers.frame, true)
end)

_samyTotemTimers:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    if (not _isUpdateTotemLists) then
        return
    end

    _isUpdateTotemLists = false
    RefreshTotemLists(_samyTotemTimers.frame, true)
end)
