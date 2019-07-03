local ADDON_NAME = "SamyTotemTimers"

local _samyTotemTimers = {}
local _config = SamyTotemTimersConfig.Instance()

if not SaveBindings then
    function SaveBindings(p)
        AttemptToSaveBindings(p)
    end
end

function _samyTotemTimers:Init()
    local mainFrame = CreateFrame("FRAME", ADDON_NAME .. "Frame")

    local buttonRectangle = _config.buttonSize * (_config.buttonSpacingMultiplier  + 1)
    local totalWidth = buttonRectangle  * 4 - _config.buttonSize * _config.buttonSpacingMultiplier
    mainFrame:SetWidth(totalWidth)
    mainFrame:SetHeight(_config.buttonSize)

    local totemLists =  {
        ["Earth"] = SamyTotemTimerList:New(mainFrame, 0, "Earth"),
        ["Fire"] = SamyTotemTimerList:New(mainFrame, buttonRectangle, "Fire"),
        ["Water"] = SamyTotemTimerList:New(mainFrame, buttonRectangle * 2, "Water"),
        ["Air"] = SamyTotemTimerList:New(mainFrame, buttonRectangle * 3, "Air")
    }

    mainFrame:SetScript("OnEvent",
        function (self, event, ...)
            if (_samyTotemTimers[event]) then
                local eventArgs = { frame = self, event = event, totemLists = totemLists, args = ... }
                _samyTotemTimers[event](nil, eventArgs)
            end
        end)

    mainFrame:RegisterEvent("ADDON_LOADED")
end

function _samyTotemTimers:ADDON_LOADED(eventArgs)
    eventArgs.frame:UnregisterEvent("ADDON_LOADED")
    eventArgs.frame:RegisterEvent("SPELLS_CHANGED")
    eventArgs.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    eventArgs.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    eventArgs.frame:RegisterEvent("PLAYER_TOTEM_UPDATE")

    _config:ADDON_LOADED(eventArgs)
    eventArgs.frame:SetPoint(_config.db.position.relativePoint, _config.db.position.x, _config.db.position.y)
    
    for k, v in pairs(eventArgs.totemLists) do
        if (v["ADDON_LOADED"]) then
            v["ADDON_LOADED"]()
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff88" .. ADDON_NAME .. "|r loaded.")
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

_samyTotemTimers:Init()