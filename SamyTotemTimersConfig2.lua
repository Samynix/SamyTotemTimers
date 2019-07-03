SamyTotemTimersConfig = {}
local instance = nil
local _totemLists = nil

function SamyTotemTimersConfig:Instance()
    if (instance == nil) then
        instance = {}

        local options = {
            name = "Keybindings",
            handler = instance,
            type = 'group',
            args = {
                earth = {
                    order = 97,
                    type = 'keybinding',
                    name = 'Earth',
                    desc = 'Keybinding for earth totem',
                    set = 'SetKeybinding',
                    get = 'GetKeybinding',
                },

                fire = {
                    order = 98,
                    type = 'keybinding',
                    name = 'Fire',
                    desc = 'Keybinding for fire totem',
                    set = 'SetKeybinding',
                    get = 'GetKeybinding',
                },

                water = {
                    order = 99,
                    type = 'keybinding',
                    name = 'Water',
                    desc = 'Keybinding for water totem',
                    set = 'SetKeybinding',
                    get = 'GetKeybinding',
                },

                air = {
                    order = 100,
                    type = 'keybinding',
                    name = 'Air',
                    desc = 'Keybinding for air totem',
                    set = 'SetKeybinding',
                    get = 'GetKeybinding',
                },
            },
        }

        local ACD3 = LibStub("AceConfigDialog-3.0")
        LibStub("AceConfig-3.0"):RegisterOptionsTable("SamyTotemTimers", options)
        local optFrame = ACD3:AddToBlizOptions("SamyTotemTimers", "SamyTotemTimers")

        function instance:GetKeybinding(info)
            local bindingName = format('CLICK %s:%s', _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
            return GetBindingKey(bindingName)
        end
        
        function instance:SetKeybinding(info, newValue)
            local currentBindingInfo = instance:GetKeybinding(info)
            if (currentBindingInfo) then
                SetBinding(currentBindingInfo, nil)
            end
            
            SetBindingClick(newValue, _totemLists[info.option.name].DropTotemButton.buttonFrame:GetName(), GetCurrentBindingSet())
            SaveBindings(GetCurrentBindingSet())
        end

        function instance:ADDON_LOADED(eventArgs)
            _totemLists = eventArgs.totemLists

            if (SamyTotemTimersDB2 == nil) then
                SamyTotemTimersDB2 = {}
                SamyTotemTimersDB2.position = {}
                SamyTotemTimersDB2.position.x = 0
                SamyTotemTimersDB2.position.y = 0
                SamyTotemTimersDB2.position.relativePoint = "CENTER"
    
                SamyTotemTimersDB2.lastUsedSpells = {}
            end
    
            instance.db = SamyTotemTimersDB2
        end

        instance.buttonSize = 36
        instance.buttonSpacingMultiplier = 0.15
        instance.totems = { 
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

    return instance
end