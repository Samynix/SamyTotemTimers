local ADDON_NAME = "SamyTotemTimers"
local UPDATE_RATE = 0.3

local _samyTotemTimers = {}
local _config = SamyTotemTimersConfig.Instance()
local _timeSinceLastUpdate = 0
local _addonLoaded = false

if not SaveBindings then
    function SaveBindings(p)
        AttemptToSaveBindings(p)
    end
end

function _samyTotemTimers:Init()
    local mainFrame = CreateFrame("FRAME", ADDON_NAME .. "Frame", UIParent)
    local buttonRectangle = _config.buttonSize * (_config.buttonSpacingMultiplier  + 1)
    local totalWidth = buttonRectangle  * 4 - _config.buttonSize * _config.buttonSpacingMultiplier
    mainFrame:SetWidth(totalWidth)
    mainFrame:SetHeight(_config.buttonSize)

    local totemLists =  {
        ["Earth"] = SamyTotemTimerList:New(mainFrame, 0, "Earth"),
        ["Fire"] = SamyTotemTimerList:New(mainFrame, buttonRectangle, "Fire"),
        ["Water"] = SamyTotemTimerList:New(mainFrame, buttonRectangle * 2, "Water"),
        ["Air"] = SamyTotemTimerList:New(mainFrame, buttonRectangle * 3, "Air"),
        ["Twist"] = SamyTotemTimerList:New(mainFrame, buttonRectangle * 4, "Twist")
    }

    mainFrame:SetScript("OnEvent",
        function (self, event, ...)
            if (_samyTotemTimers[event]) then
                local eventArgs = { addon = _samyTotemTimers, frame = self, event = event, totemLists = totemLists, args = ... }
                _samyTotemTimers[event](nil, eventArgs)
            end
        end)
    
    mainFrame:SetScript("OnUpdate", 
        function(self, elapsed) 
            _samyTotemTimers:OnUpdate({ frame = self, event = "OnUpdate", totemLists = totemLists, args = elapsed }) end)

    mainFrame:RegisterEvent("ADDON_LOADED")
end

function _samyTotemTimers:ADDON_LOADED(eventArgs)
    eventArgs.frame:UnregisterEvent("ADDON_LOADED")
    eventArgs.frame:RegisterEvent("SPELLS_CHANGED")
    eventArgs.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    eventArgs.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    eventArgs.frame:RegisterEvent("PLAYER_TOTEM_UPDATE")
    eventArgs.frame:RegisterEvent("PLAYER_LOGIN")
    eventArgs.frame:RegisterEvent("PLAYER_ENTER_COMBAT")
   

    _config:ADDON_LOADED(eventArgs)

    
    for k, v in pairs(eventArgs.totemLists) do
        if (v["ADDON_LOADED"]) then
            v["ADDON_LOADED"]()
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff88" .. ADDON_NAME .. "|r loaded.")
end

function _samyTotemTimers:PLAYER_LOGIN(eventArgs)
    _samyTotemTimers:LoadSavedVariables(eventArgs.frame, eventArgs.totemLists)
    _addonLoaded = true
end

function _samyTotemTimers:LoadSavedVariables(frame, totemLists)
    frame:ClearAllPoints()
    frame:SetPoint(_config.db.position.relativePoint, UIParent, _config.db.position.x, _config.db.position.y)
    frame:SetScale(_config.db.scale)

    for k, v in pairs(totemLists) do
        if (v["LoadSavedVariables"]) then
            v["LoadSavedVariables"]()
        end
    end

    totemLists["Twist"]:UpdateVisibility(_config.db.isTwist)
end

function _samyTotemTimers:SPELLS_CHANGED(eventArgs)
    for k, v in pairs(eventArgs.totemLists) do
        v:ADDON_LOADED()
    end
end

function _samyTotemTimers:LEARNED_SPELL_IN_TAB(eventArgs)
    for k, v in pairs(eventArgs.totemLists) do
        v:Refresh()
    end
end

function _samyTotemTimers:ACTIONBAR_UPDATE_COOLDOWN(eventArgs)
    for k, v in pairs(eventArgs.totemLists) do
        v:UpdateCooldown()
    end
end

function _samyTotemTimers:PLAYER_TOTEM_UPDATE(eventArgs)
    for k, v in pairs(eventArgs.totemLists) do
        v:UpdateActiveTotem()
    end
end

function _samyTotemTimers:PLAYER_ENTER_COMBAT(eventArgs) 
    for k, v in pairs(eventArgs.totemLists) do
        v:PLAYER_ENTER_COMBAT()
    end
end

function _samyTotemTimers:OnUpdate(eventArgs)
    _timeSinceLastUpdate = _timeSinceLastUpdate + eventArgs.args
    if (not _addonLoaded or _timeSinceLastUpdate < UPDATE_RATE) then
        return
    end

    _timeSinceLastUpdate = 0
    for k, v in pairs(eventArgs.totemLists) do
        v:OnUpdate()
    end
end


_samyTotemTimers:Init()