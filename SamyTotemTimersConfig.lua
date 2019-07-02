SamyTotemTimersConfig = {}
local instance = nil

function SamyTotemTimersConfig:Instance()
    if (instance == nil) then
        instance = {}
        
        if (SamyTotemTimersDB == nil) then
          
            SamyTotemTimersDB = {}
            SamyTotemTimersDB.position = {}
            SamyTotemTimersDB.position.x = 0
            SamyTotemTimersDB.position.y = 0
            SamyTotemTimersDB.position.relativePoint = "CENTER"
            SamyTotemTimersDB.buttonSize = 36

            SamyTotemTimersDB.selectedTotems = {}

            SamyTotemTimersDB.keyboardShortcuts = {} 
        end

        instance.db = SamyTotemTimersDB

        instance.buttonSpacingMultiplier = 0.15
        instance.earthTotems = {
            "Stoneskin Totem",
            "Earthbind Totem",
            "Stoneclaw Totem",
            "Strength of Earth Totem",
            "Tremor Totem"
        }
        
        instance.fireTotems = {
            "Searing Totem",
            "Fire Nova Totem",
            "Frost Resistance Totem",
            "Magma Totem",
            "Flametongue Totem"
        }

        instance.waterTotems = {
            "Healing Stream Totem",
            "Mana Spring Totem",
            "Disease Cleansing Totem",
            "Poison Cleansing Totem",
            "Mana Tide Totem",
        }

        instance.airTotems = {
            "Grounding Totem",
            "Nature Resistance Totem",
            "Windfury Totem",
            "Sentry Totem",
        }
    end

    return instance
end