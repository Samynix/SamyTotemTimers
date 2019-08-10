SamyTotemTimersConfig = {}
local _instance = nil
local _samyTotemTimers = nil
local _mainFrame = nil
local _totemLists = nil
local _isLocked = true

function SamyTotemTimersConfig:Instance()
    if (_instance == nil) then
        _instance = {}

        local options = {
            name = 'SamyTotemTimers',
            type = 'group',
            handler = _instance,
            args = {
                twist = {
                    order = 11,
                    type = 'toggle',
                    name = "Show twist totem",
                    set = 'SetTwist',
                    get = 'GetTwist'
                },

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

                        twist = {
                            order = 5,
                            type = 'keybinding',
                            name = 'Twist',
                            desc = 'Keybinding for twist totem',
                            set = 'SetKeybinding',
                            get = 'GetKeybinding',
                        },
                    }
                    
                }
            },
        }

        local ACD3 = LibStub("AceConfigDialog-3.0")
        LibStub("AceConfig-3.0"):RegisterOptionsTable("SamyTotemTimers", options, {"stt", "samytotemtimers"})
        local optFrame = ACD3:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")

        function _instance:GetTwist(info)
            return self.db.isTwist
        end

        function _instance:SetTwist(into, value)
            self.db.isTwist = value
            if (_totemLists["Twist"]) then
                _totemLists["Twist"]:UpdateVisibility(value)
            end
        end

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
            if (ref == nil or isOverride) then
                return default
            end

            return ref
        end

        function _instance:ToggleLock()
            for k, v in pairs(_totemLists) do
                v:SetDraggable(_isLocked)
            end

            _isLocked = not _isLocked
            if (_isLocked) then
                print('Frame locked')
            else
                print('Frame unlocked')
            end
        end

        local function CheckDatabase(isOverride)
            SamyTotemTimersDB = SetDefault(SamyTotemTimersDB, {}, isOverride)
            SamyTotemTimersDB.isFirstLoad  = SetDefault(SamyTotemTimersDB.isFirstLoad, true, isOverride)
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
            if (SamyTotemTimersDB.isFirstLoad == true) then
                SamyTotemTimersDB.isFirstLoad = false
                _instance:ToggleLock()
            end
        end

        _instance.buttonSize = 36
        _instance.buttonSpacingMultiplier = 0.15
        _instance.totems = { 
            ["EarthIndex"] = 2,
            ["Earth"] = {
                8071, --"Stoneskin Totem",
                2484, --"Earthbind Totem",
                5730, --"Stoneclaw Totem",
                8075, --"Strength of Earth Totem",
                8143, --"Tremor Totem"
            }, 
        
            ["FireIndex"] = 1,
            ["Fire"] = {
                3599, --"Searing Totem",
                1535, --"Fire Nova Totem",
                8181, --"Frost Resistance Totem",
                8190, --"Magma Totem",
                8227, --"Flametongue Totem"
            },

            ["WaterIndex"] = 3,
            ["Water"] = {
                5394, --"Healing Stream Totem",
                5675, --"Mana Spring Totem",
                8184, --"Fire Resistance Totem",
                16190, --"Mana Tide Totem",
                8170, --"Disease Cleansing Totem",
                8166, --"Poison Cleansing Totem",
            },

            ["AirIndex"] = 4,
            ["Air"] = {
                8835, --"Grace of Air Totem",
                10595, --"Nature Resistance Totem",
                15107, --"Windwall Totem",
                8512, --"Windfury Totem",
                8177, --"Grounding Totem",
                6495, --"Sentry Totem",
                25908, --"Tranquil Air Totem"
            },

            ["TwistIndex"] = 5,
            ["Twist"] = {
                8071, --"Stoneskin Totem",
                2484, --"Earthbind Totem",
                5730, --"Stoneclaw Totem",
                8075, --"Strength of Earth Totem",
                8143, --"Tremor Totem"
                3599, --"Searing Totem",
                1535, --"Fire Nova Totem",
                8181, --"Frost Resistance Totem",
                8190, --"Magma Totem",
                8227, --"Flametongue Totem"
                5394, --"Healing Stream Totem",
                5675, --"Mana Spring Totem",
                8184, --"Fire Resistance Totem",
                16190, --"Mana Tide Totem",
                8170, --"Disease Cleansing Totem",
                8166, --"Poison Cleansing Totem",
                8835, --"Grace of Air Totem",
                10595, --"Nature Resistance Totem",
                15107, --"Windwall Totem",
                8512, --"Windfury Totem",
                8177, --"Grounding Totem",
                6495, --"Sentry Totem",
                25908, --"Tranquil Air Totem"
            }
        }
    end

    return _instance
end