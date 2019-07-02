local SamyTotemTimers = {}
SamyTotemTimers.addonName = "SamyTotemTimers"
SamyTotemTimers.eventHandlers = {}

function SamyTotemTimers:Init()
    local frame = CreateFrame("FRAME", "SamyTotemTimersFrame")
    frame:SetScript("OnEvent",
    function (self, event, ...)
        print(event)
        if (SamyTotemTimers.eventHandlers[event]) then
            local eventArgs = { frame = self, event = event, args = ... }
            SamyTotemTimers.eventHandlers[event](nil, eventArgs)
        end
    end)

    frame:RegisterEvent("ADDON_LOADED")
end

function SamyTotemTimers.eventHandlers:ADDON_LOADED(eventArgs)
    eventArgs.frame:UnregisterEvent("ADDON_LOADED")
    SamyTotemTimers:RegisterEvents(eventArgs.frame) 
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff88" .. SamyTotemTimers.addonName .. "|r loaded.")
end

function SamyTotemTimers:RegisterEvents(frame)
    frame:RegisterEvent("SPELLS_CHANGED")
    frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
end

function SamyTotemTimers.eventHandlers:SPELLS_CHANGED(eventArgs)
    if (SamyTotemTimers.totemLists ~= nil) then
        return
    end

    SamyTotemTimers:UpdateTotemLists(eventArgs.frame)
end

function SamyTotemTimers.eventHandlers:LEARNED_SPELL_IN_TAB(eventArgs)
    SamyTotemTimers:UpdateTotemLists(eventArgs.frame)
end

function SamyTotemTimers:UpdateTotemLists(parentFrame)
    if (SamyTotemTimers.totemLists == nil) then
        local config = SamyTotemTimersConfig.Instance()
        local buttonRectangle = config.db.buttonSize * (config.buttonSpacingMultiplier  + 1)
        local totalWidth = buttonRectangle  * 4 - config.db.buttonSize * config.buttonSpacingMultiplier
        parentFrame:SetWidth(totalWidth)
        parentFrame:SetHeight(config.db.buttonSize)
        parentFrame:SetPoint(config.db.position.relativePoint, config.db.position.x, config.db.position.y)
        parentFrame:SetBackdropBorderColor(1, 0, 0, 1)
        parentFrame:SetBackdropColor(1, 0, 0, 1)
        parentFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        parentFrame:Show()

        

        print(buttonRectangle)
        SamyTotemTimers.totemLists = {}
        SamyTotemTimers.totemLists["earth"] = SamyTotemTimerList:New(parentFrame, 0, "Earth", config.earthTotems)
        SamyTotemTimers.totemLists["fire"] = SamyTotemTimerList:New(parentFrame, buttonRectangle, "Fire", config.fireTotems)
        SamyTotemTimers.totemLists["water"] = SamyTotemTimerList:New(parentFrame, buttonRectangle * 2, "Water", config.waterTotems)
        SamyTotemTimers.totemLists["air"] = SamyTotemTimerList:New(parentFrame, buttonRectangle * 3, "Air", config.airTotems)
    end

    for k, v in pairs(SamyTotemTimers.totemLists) do
        v:RefreshTotemSelectButtons()
    end
end

SamyTotemTimers:Init()

