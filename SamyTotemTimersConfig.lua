SamyTotemTimersConfig = {}

SamyTotemTimersConfig.ONUPDATEDELAY = 0.25
SamyTotemTimersConfig.PULSESTATUSBARHEIGHT = 15
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
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
    
            ["Earthbind Totem"] = {
                ["RankOneSpellID"] = 2484,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
    
            ["Stoneclaw Totem"] = {
                ["RankOneSpellID"] = 5730,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
    
            ["Strength of Earth Totem"] = {
                ["RankOneSpellID"] = 8075,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
    
            ["Tremor Totem"] = {
                ["RankOneSpellID"] = 8143,
                ["ElementID"] = 2,
                ["PulseTime"] = 5,
                ["isEnabled"] = true,
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Earth",
        ["order"] = 1,
    },
    [2] = {
        ["totems"] = {
            ["Searing Totem"] = {
                ["RankOneSpellID"] = 3599,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },

            ["Fire Nova Totem"] = {
                ["RankOneSpellID"] = 1535,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },

            ["Frost Resistance Totem"] = {
                ["RankOneSpellID"] = 8181,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },

            ["Magma Totem"] = {
                ["RankOneSpellID"] = 8190,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },

            ["Flametongue Totem"] = {
                ["RankOneSpellID"] = 8227,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Fire",
        ["order"] = 2,
    },
    [3] = {
        ["totems"] = {
            ["Healing Stream Totem"] = {
                ["RankOneSpellID"] = 5394,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
    
            ["Mana Spring Totem"] = {
                ["RankOneSpellID"] = 5675,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
    
            ["Fire Resistance Totem"] = {
                ["RankOneSpellID"] = 8184,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
    
            ["Mana Tide Totem"] = {
                ["RankOneSpellID"] = 16190,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
    
            ["Disease Cleansing Totem"] = {
                ["RankOneSpellID"] = 8170,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
    
            ["Poison Cleansing Totem"] = {
                ["RankOneSpellID"] = 8166,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Water",
        ["order"] = 3,
    },
    [4] = {
        ["totems"] = {
            ["Grace of Air Totem"] = {
                ["RankOneSpellID"] = 8835,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
    
            ["Nature Resistance Totem"] = {
                ["RankOneSpellID"] = 10595,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
    
            ["Windwall Totem"] = {
                ["RankOneSpellID"] = 15107,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
    
            ["Windfury Totem"] = {
                ["RankOneSpellID"] = 8512,
                ["ElementID"] = 4,
                ["PulseTime"] = 5,
                ["isEnabled"] = true,
            },
    
            ["Grounding Totem"] = {
                ["RankOneSpellID"] = 8177,
                ["ElementID"] = 4,
                ["PulseTime"] = 10,
                ["isEnabled"] = true,
            },
    
            ["Sentry Totem"] = {
                ["RankOneSpellID"] = 6495,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
    
            ["Tranquil Air Totem"] = {
                ["RankOneSpellID"] = 25908,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            }
        },
        ["isEnabled"] = true,
        ["name"] = "Air",
        ["order"] = 4,
    },
    [5] = {
        ["totems"] = {
            ["Stoneskin Totem"] = {
                ["RankOneSpellID"] = 8071,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
        
            ["Earthbind Totem"] = {
                ["RankOneSpellID"] = 2484,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
        
            ["Stoneclaw Totem"] = {
                ["RankOneSpellID"] = 5730,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
        
            ["Strength of Earth Totem"] = {
                ["RankOneSpellID"] = 8075,
                ["ElementID"] = 2,
                ["isEnabled"] = true,
            },
        
            ["Tremor Totem"] = {
                ["RankOneSpellID"] = 8143,
                ["ElementID"] = 2,
                ["PulseTime"] = 5,
                ["isEnabled"] = true,
            },
            ["Searing Totem"] = {
                ["RankOneSpellID"] = 3599,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },
        
            ["Fire Nova Totem"] = {
                ["RankOneSpellID"] = 1535,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },
        
            ["Frost Resistance Totem"] = {
                ["RankOneSpellID"] = 8181,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },
        
            ["Magma Totem"] = {
                ["RankOneSpellID"] = 8190,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },
        
            ["Flametongue Totem"] = {
                ["RankOneSpellID"] = 8227,
                ["ElementID"] = 1,
                ["isEnabled"] = true,
            },
        
        
            ["Healing Stream Totem"] = {
                ["RankOneSpellID"] = 5394,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Mana Spring Totem"] = {
                ["RankOneSpellID"] = 5675,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Fire Resistance Totem"] = {
                ["RankOneSpellID"] = 8184,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Mana Tide Totem"] = {
                ["RankOneSpellID"] = 16190,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Disease Cleansing Totem"] = {
                ["RankOneSpellID"] = 8170,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Poison Cleansing Totem"] = {
                ["RankOneSpellID"] = 8166,
                ["ElementID"] = 3,
                ["isEnabled"] = true,
            },
        
            ["Grace of Air Totem"] = {
                ["RankOneSpellID"] = 8835,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
        
            ["Nature Resistance Totem"] = {
                ["RankOneSpellID"] = 10595,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
        
            ["Windwall Totem"] = {
                ["RankOneSpellID"] = 15107,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
        
            ["Windfury Totem"] = {
                ["RankOneSpellID"] = 8512,
                ["ElementID"] = 4,
                ["PulseTime"] = 5,
                ["BuffDuration"] = 10,
                ["isEnabled"] = true,
            },
        
            ["Grounding Totem"] = {
                ["RankOneSpellID"] = 8177,
                ["ElementID"] = 4,
                ["PulseTime"] = 10,
                ["isEnabled"] = true,
            },
        
            ["Sentry Totem"] = {
                ["RankOneSpellID"] = 6495,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            },
        
            ["Tranquil Air Totem"] = {
                ["RankOneSpellID"] = 25908,
                ["ElementID"] = 4,
                ["isEnabled"] = true,
            }
        }, 
        ["isEnabled"] = false,
        ["name"] = "All",
        ["order"] = 5,
        ["IsOnlyShowTimerForSelectedTotem"] = true,
    },
    [6] = {
        ["totems"] = {
            ["Windfury Totem"] = {
                ["RankOneSpellID"] = 8512,
                ["ElementID"] = 4,
                ["PulseTime"] = 5,
                ["BuffDuration"] = 10,
                ["isEnabled"] = true,
            },
        },
        ["isEnabled"] = false,
        ["isShowBuffDuration"] = true,
        ["name"] = "Twist",
        ["order"] = 6,
    },
}

SamyTotemTimersConfig.allTotems = {
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
        ["ElementID"] = 2,
        ["PulseTime"] = 5,
    },
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
    },


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
    },

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
        ["ElementID"] = 4,
        ["PulseTime"] = 5,
        ["BuffDuration"] = 10,
    },

    ["Grounding Totem"] = {
        ["RankOneSpellID"] = 8177,
        ["ElementID"] = 4,
        ["PulseTime"] = 10,
    },

    ["Sentry Totem"] = {
        ["RankOneSpellID"] = 6495,
        ["ElementID"] = 4
    },

    ["Tranquil Air Totem"] = {
        ["RankOneSpellID"] = 25908,
        ["ElementID"] = 4
    }
}