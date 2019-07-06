SamyTotemTimersConfig = {}
local _instance = nil
local _samyTotemTimers = nil
local _mainFrame = nil
local _totemLists = nil

function SamyTotemTimersConfig:Instance()
    if (_instance == nil) then
        _instance = {}

        local options = {
            name = 'SamyTotemTimers',
            type = 'group',
            handler = _instance,
            args = {
                reset = {
                    order = 2,
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

                keybinds = {
                    order = 3,
                    type = 'group',
                    name = 'Keybindings',
                    args = {
                        earth = {
                            order = 1,
                            type = 'keybinding',
                            name = 'Earth',
                            desc = 'Keybinding for earth totem',
                            set = 'SetKeybinding',
                            get = 'GetKeybinding',
                        },
        
                        fire = {
                            order = 2,
                            type = 'keybinding',
                            name = 'Fire',
                            desc = 'Keybinding for fire totem',
                            set = 'SetKeybinding',
                            get = 'GetKeybinding',
                        },
        
                        water = {
                            order = 3,
                            type = 'keybinding',
                            name = 'Water',
                            desc = 'Keybinding for water totem',
                            set = 'SetKeybinding',
                            get = 'GetKeybinding',
                        },
        
                        air = {
                            order = 4,
                            type = 'keybinding',
                            name = 'Air',
                            desc = 'Keybinding for air totem',
                            set = 'SetKeybinding',
                            get = 'GetKeybinding',
                        },
                    }
                    
                }
            },
        }

        local ACD3 = LibStub("AceConfigDialog-3.0")
        LibStub("AceConfig-3.0"):RegisterOptionsTable("SamyTotemTimers", options)
        local optFrame = ACD3:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")

        function _instance:GetKeybinding(info)
            local bindingName = format('CLICK %s:%s', _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
            return GetBindingKey(bindingName)
        end
        
        function _instance:SetKeybinding(info, newValue)
            local currentBindingInfo = _instance:GetKeybinding(info)
            if (currentBindingInfo) then
                SetBinding(currentBindingInfo, nil)
            end
            
            SetBindingClick(newValue, _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
            SaveBindings(GetCurrentBindingSet())
        end

        function _instance:SetScale(info, newValue)
            self.db.scale = newValue
            _mainFrame:SetScale(newValue)
        end

        function _instance:GetScale(info) 
            if (not self.db.scale) then
                self.db.scale = _mainFrame:GetScale()
            end

            return self.db.scale
        end

        local function SetDefault(ref, default, isOverride)
            if (not ref or isOverride) then
                return default
            end

            return ref
        end

        local function CheckDatabase(isOverride)
            SamyTotemTimersDB = SetDefault(SamyTotemTimersDB, {}, isOverride)
            SamyTotemTimersDB.scale = SetDefault(SamyTotemTimersDB.scale, 1, isOverride)
            SamyTotemTimersDB.lastUsedSpells = SetDefault(SamyTotemTimersDB.lastUsedSpells, {}, isOverride)
            SamyTotemTimersDB.position = SetDefault(SamyTotemTimersDB.position, {}, isOverride)
            SamyTotemTimersDB.position.x = SetDefault(SamyTotemTimersDB.position.x, 0, isOverride)
            SamyTotemTimersDB.position.y = SetDefault(SamyTotemTimersDB.position.y, 0, isOverride)
            SamyTotemTimersDB.position.relativePoint = SetDefault(SamyTotemTimersDB.position.relativePoint, "CENTER", isOverride)

            _instance.db = SamyTotemTimersDB
        end

        function _instance:ResetConfig()
            CheckDatabase(true)
            _samyTotemTimers:LoadSavedVariables(_mainFrame, _totemLists)
        end

        function _instance:ADDON_LOADED(eventArgs)
            _samyTotemTimers = eventArgs.addon
            _mainFrame = eventArgs.frame
            _totemLists = eventArgs.totemLists

            CheckDatabase()
        end

        _instance.buttonSize = 36
        _instance.buttonSpacingMultiplier = 0.15
        _instance.totems = { 
            ["EarthIndex"] = 2,
            ["Earth"] = {
                "Stoneskin Totem",
                "Earthbind Totem",
                "Stoneclaw Totem",
                "Strength of Earth Totem",
                "Tremor Totem"
            }, 
        
            ["FireIndex"] = 1,
            ["Fire"] = {
                "Searing Totem",
                "Fire Nova Totem",
                "Frost Resistance Totem",
                "Magma Totem",
                "Flametongue Totem"
            },

            ["WaterIndex"] = 3,
            ["Water"] = {
                "Healing Stream Totem",
                "Mana Spring Totem",
                "Disease Cleansing Totem",
                "Poison Cleansing Totem",
                "Mana Tide Totem",
            },

            ["AirIndex"] = 4,
            ["Air"] = {
                "Grounding Totem",
                "Nature Resistance Totem",
                "Windfury Totem",
                "Sentry Totem",
            }
        }
    end

    return _instance
end