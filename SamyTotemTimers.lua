local _samyTotemTimers = LibStub("AceAddon-3.0"):NewAddon("SamyTotemTimers", "AceEvent-3.0")

local _libCallback = LibStub("CallbackHandler-1.0"):New(_samyTotemTimers)



local _totemLists = {}
local  _wfTotemList = {}
local _isUpdateTotemLists = false
local _timeSinceLastUpdate = 0
local _castChangedTime = nil

local COMM_PREFIX_OLD = "WFC01"
local COMM_PREFIX = "WF_STATUS"

C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX_OLD)

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
        local totemList = SamyTotemTimersTotemList:Create(parentFrame, k, v["totems"], v["IsOnlyShowTimerForSelectedTotem"], v["isShowBuffDuration"], _wfTotemList)
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
    _samyTotemTimers:UpdateGroupRooster()
    
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

    local playerGuid = UnitGUID("player")
    local hasWepEnchant, expire = GetWeaponEnchantInfo("player")
    if (_wfTotemList[playerGuid]) then
        _wfTotemList[playerGuid].duration = hasWepEnchant and 1 or 0
        _wfTotemList[playerGuid].expirationTime = hasWepEnchant and expire or 0
        _wfTotemList[playerGuid].missingPrereq = false
    end

    _timeSinceLastUpdate = 0
    for k, v in pairs(_totemLists) do
        v:UpdateActiveTotemAffectedCount()
    end


    -- print(table.getn(_samyTotemTimers.wfData))
    -- for k, v in pairs(_samyTotemTimers.wfData) do
    --     print(k, v.hasWepEnchant, v.hasWfCom)
    -- end
end

function _samyTotemTimers:UpdateGroupRooster()
    local function addPlayerData(unitId)
        local playerGuid = UnitGUID(unitId)
        if not playerGuid then
            return nil
        end
        
        _wfTotemList[playerGuid] = 
        {
            guid = playerGuid,
            missingPrereq = true,
            expirationTime = 0,
            duration = 0
        }

        return playerGuid
    end
    
    local unitGuids = {}
    unitGuids[addPlayerData("player")] = true
    for index=1,4 do
        local guid = addPlayerData("party" .. index)
        if (guid) then
            unitGuids[guid] = true
        end
    end

    for k, v in pairs(_wfTotemList) do
        if (not unitGuids[k]) then 
            print(k, v)
            table.remove(_wfTotemList, k)
            print('removed')
        end
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

_samyTotemTimers:RegisterEvent("ZONE_CHANGED", function(event)
    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("ZONE_CHANGED_INDOORS", function(event)
    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("ZONE_CHANGED_NEW_AREA", function(event)
    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("PLAYER_DEAD", function(event)
    ResetAllActive()
end)

_samyTotemTimers:RegisterEvent("GROUP_ROSTER_UPDATE", function(event)
    _samyTotemTimers:UpdateGroupRooster()
end)

_samyTotemTimers:RegisterEvent("CHAT_MSG_ADDON", function(event, prefix, message, channel, sender)
	if(prefix == COMM_PREFIX_OLD ) then -- wf com old API
		local commType, expiration, lag, gGUID = strsplit(":", message)
		-- local expiration, lag = tonumber(expiration), tonumber(lag)
		if(not _wfTotemList[gGUID] ) then 
            return 
        end

        print('old', gGUID)
		if( commType == "W" ) then -- message w/ wf duration, should always fire on application)
            _wfTotemList[gGUID].duration = 1
            _wfTotemList[gGUID].expirationTime = expiration
            _wfTotemList[gGUID].missingPrereq = false
		elseif( commType == "E" ) then -- message wf lost
            _wfTotemList[gGUID].duration = 0
            _wfTotemList[gGUID].expirationTime = 0
            _wfTotemList[gGUID].missingPrereq = false
		elseif( commType == "I") then -- message signaling that unit has addon installed
			_wfTotemList[gGUID].missingPrereq = false
		end

	elseif( prefix == COMM_PREFIX ) then --wf com new API
		local gGUID, spellID, expiration, lag = strsplit(':', message)
        if(not _wfTotemList[gGUID] ) then 
            return 
        end

		local spellID, expire, lagHome = tonumber(spellID), tonumber(expiration), tonumber(lagHome)
		if spellID then --update buffs
            _wfTotemList[gGUID].duration = 1
            _wfTotemList[gGUID].expirationTime = expire
            _wfTotemList[gGUID].missingPrereq = false
		else --if( not spellID ) then --addon installed or buff expired
            _wfTotemList[gGUID].duration = 0
            _wfTotemList[gGUID].expirationTime = 0
            _wfTotemList[gGUID].missingPrereq = false
		end
	end
end)

