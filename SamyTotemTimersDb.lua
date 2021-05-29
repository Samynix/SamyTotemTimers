SamyTotemTimersDatabase = {}

if not SaveBindings then
    function SaveBindings(p)
        AttemptToSaveBindings(p)
    end
end

local _db = nil
local _samyTotemTimers = nil
local _isSamyTotemTimersFrameLocked = true

local function IsDoDbVersion(versionNumber)
    if (SamyTotemTimersDB and (not SamyTotemTimersDB.version or SamyTotemTimersDB.version < versionNumber)) then
        return true
    end

    return false
end

local function EnsureSavedVariablesExists(isReset)
    local function SetDefault(ref, default, isOverride)
        if (ref == nil or isOverride) then
            return default
        end

        return ref
    end

    if (IsDoDbVersion(2.1)) then
        isReset = true
        SamyTotemTimersUtils:Print("Current version incompatible with old saved variables, reseting all configuration")
    end

    if (IsDoDbVersion(2.3)) then
        SamyTotemTimersDB.totemLists = SetDefault(SamyTotemTimersDB.totemLists, SamyTotemTimersConfig.defaultTotemLists, true)  
        SamyTotemTimersUtils:Print("Updated twist totem list with more totems, added order to totemlists")
    end

    local function postEnsureVariablesExists()
        for k, v in pairs(SamyTotemTimersDB.totemLists) do
            if (v.isShowPulseTimers == nil) then
                v.isShowPulseTimers = true
            end

            for k2, v2 in pairs(v.totems) do
                if (v2.isEnabled == nil) then
                    v2.isEnabled = true
                end
            end
        end

        --Ensure all totems are in config
        for k, element in pairs(SamyTotemTimersConfig.defaultTotemLists) do
            for k2, totem in pairs(element["totems"]) do
                if not SamyTotemTimersDB.totemLists[k]["totems"][k2] then
                    SamyTotemTimersDB.totemLists[k]["totems"][k2] = totem
                end
            end
        end

        SamyTotemTimersDB.version = 2.4
    end

    SamyTotemTimersDB = SetDefault(SamyTotemTimersDB, {}, isReset)
    SamyTotemTimersDB.lastUsedTotems = SetDefault(SamyTotemTimersDB.lastUsedTotems, {}, isReset)
    SamyTotemTimersDB.scale = SetDefault(SamyTotemTimersDB.scale, 1, isReset)
    SamyTotemTimersDB.position = SetDefault(SamyTotemTimersDB.position, {}, isReset)
    SamyTotemTimersDB.position.hasChanged = SetDefault(SamyTotemTimersDB.position.hasChanged, true, isReset)
    SamyTotemTimersDB.position.x = SetDefault(SamyTotemTimersDB.position.x, 0, isReset)
    SamyTotemTimersDB.position.y = SetDefault(SamyTotemTimersDB.position.y, 0, isReset)
    SamyTotemTimersDB.position.relativePoint = SetDefault(SamyTotemTimersDB.position.relativePoint, "CENTER", isReset)
    SamyTotemTimersDB.totemLists = SetDefault(SamyTotemTimersDB.totemLists, SamyTotemTimersConfig.defaultTotemLists, isReset)
    

    postEnsureVariablesExists()

    return SamyTotemTimersDB
end

function SamyTotemTimersDatabase:OnInitialize(samyTotemTimers)
    _samyTotemTimers = samyTotemTimers
    _db = EnsureSavedVariablesExists(false)

    local options = {
        name = 'SamyTotemTimersV2', 
        type = "group",
        handler = self,
        args = {
            reset = {
                order = 10,
                type = 'execute',
                name = "Reset",
                func = 'ResetConfig'
            },

            scale = {
                order = 1,
                type = 'range',
                name = "Scale",
                min = 0.1,
                max = 5.0,
                step = 0.05,
                bigStep = 0.1,
                set = 'SetScale',
                get = 'GetScale'
            },

            lock = {
                order = 2,
                type = 'execute',
                name = "Lock/Unlock",
                func = 'ToggleLock',
            },

            totems = {
                order = 3,
                type = 'group',
                name = 'Totems',
                args = {}
            }
        }
    }

    for k, v in pairs(_db.totemLists) do
        local key = tostring(k)
        options.args.totems.args[key] = {
            order = k,
            type = "group",
            name = v.name,
            args = {
                isEnabled = {
                    order = 1,
                    name = "Enabled",
                    desc = "Enable/Disable totem list",
                    type = "toggle",
                    set = function(info, newValue) SamyTotemTimersDatabase:SetTotemListEnabled(k, newValue) end,
                    get = function() return SamyTotemTimersDatabase:GetTotemListEnabled(k) end,
                },
                isShowPulseTimers = {
                    order = 2,
                    name = "Show pulse",
                    desc = "Show pulse timers for supported totems?",
                    type = "toggle",
                    set = function(info, newValue) SamyTotemTimersDatabase:SetIsShowPulse(k, newValue) end,
                    get = function() return SamyTotemTimersDatabase:GetIsShowPulse(k) end
                },
                order = {
                    order = 3,
                    name = "Order",
                    min = 1,
                    max = #SamyTotemTimersDB.totemLists,
                    softMin = 1,
                    softMax = #SamyTotemTimersDB.totemLists,
                    step  = 1,
                    bigStep = 1,
                    type = "range",
                    set = function(info, newValue) SamyTotemTimersDatabase:SetTotemListOrder(k, newValue) end,
                    get = function() return SamyTotemTimersDatabase:GetTotemListOrder(k) end,
                },
                keybind = {
                    order = 4,
                    type = "keybinding",
                    name = "Keybinding",
                    desc = "Keybinding for " .. v.name,
                    set = function (info, newValue) SamyTotemTimersDatabase:SetKeybinding(k, newValue) end,
                    get = function () return SamyTotemTimersDatabase:GetKeybinding(k) end,
                },
                totems = {
                    order = 5,
                    type = "group",
                    name = "Totems",
                    desc = "Enable/Disable totems for this list",
                    args = {

                    }
                }
            }
        }

        for k2, v2 in pairs(v.totems) do
            options.args.totems.args[key].args.totems.args[k2] = {
                order = 1,
                name = k2,
                desc = "Enable/Disable " .. k2,
                type = "toggle",
                set = function(info, newValue) SamyTotemTimersDatabase:SetTotemEnabled(k, k2, newValue) end,
                get = function() return SamyTotemTimersDatabase:GetTotemEnabled(k, k2) end,
            }
        end
    end

    local ACD3 = LibStub("AceConfigDialog-3.0")
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SamyTotemTimers", options, {"stt", "samytotemtimers"})
    local optFrame = ACD3:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")
end

function SamyTotemTimersDatabase:SelectedSpellChanged(listName, spellName)
    SamyTotemTimersUtils:Debug("Totem changed for " .. listName .. ": " .. tostring(spellName))
    _db.lastUsedTotems[listName] = spellName
end

function SamyTotemTimersDatabase:PositionChanged()
    local point, relativeTo, relativePoint, x, y = _samyTotemTimers.frame:GetPoint()
    _db.position.x = x
    _db.position.y = y
    _db.position.relativePoint = relativePoint
    _db.position.hasChanged = true
end

function SamyTotemTimersDatabase:RestoreScaleAndPosition()
    if (_db.position.hasChanged) then
        _samyTotemTimers.frame:SetPoint(_db.position.relativePoint, UIParent, _db.position.x, _db.position.y)
    else
        _samyTotemTimers.frame:SetPoint("CENTER", _samyTotemTimers.frame:GetWidth() / 2.0, 0)
    end

    _samyTotemTimers.frame:SetScale(_db.scale)
end

function SamyTotemTimersDatabase:GetLastUsedTotem(totemListId)
    return _db.lastUsedTotems[totemListId]
end

function SamyTotemTimersDatabase:GetTotemLists()
    return _db.totemLists
end

function SamyTotemTimersDatabase:SetTotemListEnabled(totemListId, isEnabled)
    _db.totemLists[totemListId].isEnabled = isEnabled
    _samyTotemTimers:SetListEnabled(totemListId, isEnabled)
end

function SamyTotemTimersDatabase:GetTotemListEnabled(totemListId)
    return _db.totemLists[totemListId].isEnabled
end


function SamyTotemTimersDatabase:SetIsShowPulse(totemListId, isShowPulseTimers)
    _db.totemLists[totemListId].isShowPulseTimers = isShowPulseTimers
    _samyTotemTimers:SetIsShowPulse(totemListId, isShowPulseTimers)
end

function SamyTotemTimersDatabase:GetIsShowPulse(totemListId)
    return _db.totemLists[totemListId].isShowPulseTimers
end


function SamyTotemTimersDatabase:SetTotemEnabled(totemListId, totemName, isEnabled)
    _db.totemLists[totemListId].totems[totemName].isEnabled = isEnabled
    _samyTotemTimers:SetTotemEnabled(totemListId, totemName, isEnabled)
end

function SamyTotemTimersDatabase:GetTotemEnabled(totemListId, totemName, isEnabled)
    if (_db.totemLists[totemListId].totems[totemName].isEnabled == nil) then
        _db.totemLists[totemListId].totems[totemName].isEnabled = true
    end

    return _db.totemLists[totemListId].totems[totemName].isEnabled
end

function SamyTotemTimersDatabase:SetTotemListOrder(totemListId, newValue)
    local ordersChanged = {}
    local oldOrder = _db.totemLists[totemListId].order
    for k, v in pairs(_db.totemLists) do
        if (v.order == newValue) then
            v.order = oldOrder
            ordersChanged[k] = v.order
        end
    end

    _db.totemLists[totemListId].order = newValue
    ordersChanged[totemListId] = _db.totemLists[totemListId].order
    _samyTotemTimers:TotemListsOrderChanged(ordersChanged)
end

function SamyTotemTimersDatabase:GetTotemListOrder(totemListId)
    return _db.totemLists[totemListId].order
end

function SamyTotemTimersDatabase:GetKeybinding(totemListId)
    local bindingName = format('CLICK %s:%s', SamyTotemTimersConfig:GetCastTotemButtonName(totemListId), GetCurrentBindingSet())
    return GetBindingKey(bindingName)
end

function SamyTotemTimersDatabase:SetKeybinding(totemListId, newValue)
    local currentBindingInfo = self:GetKeybinding(totemListId)
    if (currentBindingInfo) then
        SetBinding(currentBindingInfo, nil)
    end

    SetBindingClick(newValue, SamyTotemTimersConfig:GetCastTotemButtonName(totemListId), GetCurrentBindingSet())
    SaveBindings(GetCurrentBindingSet())
end

function SamyTotemTimersDatabase:SetScale(info, newValue)
    _db.scale = newValue
    _samyTotemTimers.frame:SetScale(newValue)
end

function SamyTotemTimersDatabase:GetScale(info) 
    return _db.scale
end

function SamyTotemTimersDatabase:ToggleLock()
    _isSamyTotemTimersFrameLocked = not _isSamyTotemTimersFrameLocked
    _samyTotemTimers:SetDraggable(not _isSamyTotemTimersFrameLocked)
    if (_isSamyTotemTimersFrameLocked) then
        SamyTotemTimersUtils:Print("Frame locked")
    else
        SamyTotemTimersUtils:Print("Frame unlocked")
    end
end

function SamyTotemTimersDatabase:ResetConfig()
    EnsureSavedVariablesExists(true)
    ReloadUI()
end
