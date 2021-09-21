local _samyTotemTimers = LibStub("AceAddon-3.0"):NewAddon("SamyTotemTimers", "AceEvent-3.0")

local _libCallback = LibStub("CallbackHandler-1.0"):New(_samyTotemTimers)



local _totemLists = {}
local  _wfTotemList = {}
local _isUpdateTotemLists = false
local _timeSinceLastUpdate = 0
local _castChangedTime = nil
local _currentZone = nil

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
    local counter = 0

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
            frame:SetSize(totalWidth - SamyTotemTimersConfig.HORIZONTAL_SPACING, SamyTotemTimersConfig.BUTTON_SIZE)

            v:SetVisibility(true)
            v:RefreshTotemSelectList(SamyTotemTimersDatabase:GetLastUsedTotem(v.listId))
            v:SetPosition(counter * (SamyTotemTimersConfig.BUTTON_SIZE + SamyTotemTimersConfig.HORIZONTAL_SPACING), 0)
            
            if (isSelectTotem) then
                v:SetSelectedTotem(SamyTotemTimersDatabase:GetLastUsedTotem(v.listId))
            end

            counter = counter + 1
        else
            v:SetVisibility(false)
        end
    end
end

local function CreateTotemLists(parentFrame)
    local totemLists = {}

    for k, v in pairs(SamyTotemTimersDatabase:GetTotemLists()) do
        local totemList = SamyTotemTimersTotemList:Create(parentFrame, k, v["totems"], v["IsOnlyShowTimerForSelectedTotem"], v["isShowBuffDuration"], SamyTotemTimersWFCom.WfStatusList)
        totemList:SetEnabled(v["isEnabled"])
        totemList:SetOrder(v["order"])
        totemList:SetIsShowPulse(v.isShowPulseTimers)
        totemList.selectedSpellChanged = function(self, button, totemListId, spellName) 
            SamyTotemTimersDatabase:SelectedSpellChanged(totemListId, spellName)
            RefreshTotemLists(parentFrame, false)
            _libCallback:Fire("OnButtonContentsChanged", button:GetName(), 0, "action", spellName)
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

    _samyTotemTimers:RegisterCallback("OnButtonContentsChanged", function (a, b, c, d, e)
        --print(a, b, c, d, e)
    end)

    SamyTotemTimersDatabase:OnInitialize(self)
    SamyTotemTimersWFCom:UpdateGroupRooster()

    self.frame = CreateFrame("Frame", "SamyTotemTimersFrame", UIParent)
    self.frame:SetScript("OnUpdate", self.OnUpdate)
    self.overlayFrame = CreateFrame("Button", "SamyTotemTimersOverlayFrame", self.frame, BackdropTemplateMixin and "BackdropTemplate")
    self.overlayFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -5, 5)
    self.overlayFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 5, -5)
    self.overlayFrame:SetFrameStrata("DIALOG")
    self.overlayFrame:RegisterForClicks('AnyUp')
    self.overlayFrame:RegisterForDrag('LeftButton')
    self.overlayFrame:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        tile=true,
        tileSize=5,
        edgeSize= 0,
    })
    self.overlayFrame:SetBackdropColor(0,0,0,0.65)
    self.overlayFrame:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
    self.overlayFrame:SetScript("OnMouseUp", function(self) 
        self:GetParent():StopMovingOrSizing() 
        SamyTotemTimersDatabase.PositionChanged()
        RefreshTotemLists(self:GetParent(), false)
    end)
    self.overlayFrame:Hide()
 
    local totemLists = CreateTotemLists(self.frame)
    _totemLists = totemLists

    SamyTotemTimersDatabase:RestoreScaleAndPosition()
    self.frame:Show()

    SamyTotemTimersWFCom:UpdateGroupRooster()
    _currentZone = GetZoneText()
    SamyTotemTimersUtils:Print("Loaded")
end

function _samyTotemTimers:SetDraggable(isDraggable)
    if (isDraggable) then
        self.frame:SetMovable(true)
        self.overlayFrame:Show()
    else
        self.frame:SetMovable(false)
        self.overlayFrame:Hide()
    end
end

function _samyTotemTimers:SetListEnabled(listId, isEnabled)
    _totemLists[listId]:SetEnabled(isEnabled)
    RefreshTotemLists(_samyTotemTimers.frame, true)
end

function _samyTotemTimers:SetIsShowPulse(listId, isShowPulse)
    _totemLists[listId]:SetIsShowPulse(isShowPulse)
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


    SamyTotemTimersWFCom:OnUpdate()
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

local function MeasureLatency()
    local delay = 0
    if (_castChangedTime) then
        delay = GetTime() - _castChangedTime
        _castChangedTime = nil
    end

    return delay
end

_samyTotemTimers:RegisterEvent("PLAYER_TOTEM_UPDATE", function(self, totemIndex)
    local latency = MeasureLatency()
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v:UpdateActiveTotemInfo(totemIndex, latency)
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

_samyTotemTimers:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", function(event) 
    _castChangedTime = GetTime()
end)

local function ResetAllActive()
    for k, v in pairs(_totemLists) do
        if (v.isEnabled) then
            v:ResetActiveTotem()
        end
    end
end

local function HasChangedZone()
    local currentZone = GetZoneText()
    if (_currentZone ~= currentZone) then
        _currentZone = currentZone
        return true
    end

    return false
end

_samyTotemTimers:RegisterEvent("ZONE_CHANGED", function(event)
    if (not HasChangedZone()) then
        return
    end

    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("ZONE_CHANGED_INDOORS", function(event)
    if (not HasChangedZone()) then
        return
    end

    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("ZONE_CHANGED_NEW_AREA", function(event)
    if (not HasChangedZone()) then
        return
    end

    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("PLAYER_DEAD", function(event)
    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("GROUP_ROSTER_UPDATE", function(event)
    SamyTotemTimersWFCom:UpdateGroupRooster()
end)

_samyTotemTimers:RegisterEvent("CHAT_MSG_ADDON", function(...) SamyTotemTimersWFCom:ChatMessageReceived(...)
end)
