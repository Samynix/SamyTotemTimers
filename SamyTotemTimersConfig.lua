SamyTotemTimersConfig = {}

SamyTotemTimersConfig.VERTICAL_SPACING = 7
SamyTotemTimersConfig.HORIZONTAL_SPACING = 10
SamyTotemTimersConfig.BUTTON_SIZE = 32
SamyTotemTimersConfig.IS_DEBUG = false
SamyTotemTimersConfig.PRINT_PREFIX = "|cFF452347SamyTotemTimers:|r"


function SamyTotemTimersConfig:GetCastTotemButtonName(totemListId)
    return "SamyTotemTimers" .. totemListId .. "CastTotemButton"
end

SamyTotemTimersConfig.defaultTotemLists = {
    [1] = {
        ["totems"] = {
            ["Stoneskin Totem"] = {
                ["RankOneSpellID"] = 8071,
                ["ElementID"] = 2
            },
    
            ["Earthbind Totem"] = {
                ["RankOneSpellID"] = 2484,
                ["ElementID"] = 2
            },
    
            ["Stoneclaw Totem"] = {
                ["RankOneSpellID"] = 5730,
                ["ElementID"] = 2
            },
    
            ["Strength of Earth Totem"] = {
                ["RankOneSpellID"] = 8075,
                ["ElementID"] = 2
            },
    
            ["Tremor Totem"] = {
                ["RankOneSpellID"] = 8143,
                ["ElementID"] = 2
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Earth"

    },
    [2] = {
        ["totems"] = {
            ["Searing Totem"] = {
                ["RankOneSpellID"] = 3599,
                ["ElementID"] = 1
            },

            ["Fire Nova Totem"] = {
                ["RankOneSpellID"] = 1535,
                ["ElementID"] = 1
            },

            ["Frost Resistance Totem"] = {
                ["RankOneSpellID"] = 8181,
                ["ElementID"] = 1
            },

            ["Magma Totem"] = {
                ["RankOneSpellID"] = 8190,
                ["ElementID"] = 1
            },

            ["Flametongue Totem"] = {
                ["RankOneSpellID"] = 8227,
                ["ElementID"] = 1
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Fire"
    },
    [3] = {
        ["totems"] = {
            ["Healing Stream Totem"] = {
                ["RankOneSpellID"] = 5394,
                ["ElementID"] = 3
            },
    
            ["Mana Spring Totem"] = {
                ["RankOneSpellID"] = 5675,
                ["ElementID"] = 3
            },
    
            ["Fire Resistance Totem"] = {
                ["RankOneSpellID"] = 8184,
                ["ElementID"] = 3
            },
    
            ["Mana Tide Totem"] = {
                ["RankOneSpellID"] = 16190,
                ["ElementID"] = 3
            },
    
            ["Disease Cleansing Totem"] = {
                ["RankOneSpellID"] = 8170,
                ["ElementID"] = 3
            },
    
            ["Poison Cleansing Totem"] = {
                ["RankOneSpellID"] = 8166,
                ["ElementID"] = 3
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Water"
    },
    [4] = {
        ["totems"] = {
            ["Grace of Air Totem"] = {
                ["RankOneSpellID"] = 8835,
                ["ElementID"] = 4
            },
    
            ["Nature Resistance Totem"] = {
                ["RankOneSpellID"] = 10595,
                ["ElementID"] = 4
            },
    
            ["Windwall Totem"] = {
                ["RankOneSpellID"] = 15107,
                ["ElementID"] = 4
            },
    
            ["Windfury Totem"] = {
                ["RankOneSpellID"] = 8512,
                ["ElementID"] = 4
            },
    
            ["Grounding Totem"] = {
                ["RankOneSpellID"] = 8177,
                ["ElementID"] = 4
            },
    
            ["Sentry Totem"] = {
                ["RankOneSpellID"] = 6495,
                ["ElementID"] = 4
            },
    
            ["Tranquil Air Totem"] = {
                ["RankOneSpellID"] = 25908,
                ["ElementID"] = 4
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Air"
    },
    [5] = {
        ["totems"] = {
            ["Grace of Air Totem"] = {
                ["RankOneSpellID"] = 8835,
                ["ElementID"] = 4
            },
    
            ["Nature Resistance Totem"] = {
                ["RankOneSpellID"] = 10595,
                ["ElementID"] = 4
            },
    
            ["Windwall Totem"] = {
                ["RankOneSpellID"] = 15107,
                ["ElementID"] = 4
            },
    
            ["Windfury Totem"] = {
                ["RankOneSpellID"] = 8512,
                ["ElementID"] = 4
            },
    
            ["Grounding Totem"] = {
                ["RankOneSpellID"] = 8177,
                ["ElementID"] = 4
            },
    
            ["Tranquil Air Totem"] = {
                ["RankOneSpellID"] = 25908,
                ["ElementID"] = 4
            }
        },
        ["isEnabled"] = false,
        ["name"] = "Twist"
    },

}