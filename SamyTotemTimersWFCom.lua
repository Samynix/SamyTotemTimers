SamyTotemTimersWFCom = {}
SamyTotemTimersWFCom.WfStatusList = {}

local COMM_PREFIX_OLD = "WFC01"
local COMM_PREFIX = "WF_STATUS"

C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX_OLD)

function SamyTotemTimersWFCom:UpdateGroupRooster()
    local function addPlayerData(unitId)
        local playerGuid = UnitGUID(unitId)
        local _, unitClass = UnitClass(unitId)
        if (not playerGuid) then
            return nil
        end
        
        local unitName = UnitName(unitId)
        local oldStatus = SamyTotemTimersWFCom.WfStatusList[playerGuid]
        SamyTotemTimersWFCom.WfStatusList[playerGuid] = 
        {
            name = unitName,
            guid = playerGuid,
            hasWfCom = oldStatus and oldStatus.hasWfCom or false,
            isRelevant = SamyTotemTimersDB.wfComClass[unitClass],
            expirationTime = oldStatus and oldStatus.expirationTime or 0,
            duration = oldStatus and oldStatus.duration or 0
        }

        return playerGuid
    end
    
    local unitGuids = {}
    local playerGuid = addPlayerData("player")
    if (playerGuid) then
        unitGuids[playerGuid] = true
    end

    for index=1,4 do
        local guid = addPlayerData("party" .. index)
        if (guid) then
            unitGuids[guid] = true
        end
    end

    for k, v in pairs(SamyTotemTimersWFCom.WfStatusList) do
        if (not unitGuids[k]) then 
            SamyTotemTimersWFCom.WfStatusList[k] = nil
        end
    end
end

function SamyTotemTimersWFCom:UpdatePlayer()
    local playerGuid = UnitGUID("player")
    if (not SamyTotemTimersWFCom.WfStatusList[playerGuid]) then
        return
    end

    local hasWepEnchant, expire = GetWeaponEnchantInfo("player")
    if (SamyTotemTimersWFCom.WfStatusList[playerGuid]) then
        SamyTotemTimersWFCom.WfStatusList[playerGuid].duration = hasWepEnchant and 1 or 0
        SamyTotemTimersWFCom.WfStatusList[playerGuid].expirationTime = hasWepEnchant and expire or 0
        SamyTotemTimersWFCom.WfStatusList[playerGuid].hasWfCom = true
    end
end

function SamyTotemTimersWFCom:ChatMessageReceived(event, prefix, message, channel, sender)
    if(prefix == COMM_PREFIX_OLD) then -- wf com old API
		local commType, expiration, lag, gGUID = strsplit(":", message)
		if(not SamyTotemTimersWFCom.WfStatusList[gGUID] ) then 
            return 
        end

		if(commType == "W") then -- message w/ wf duration, should always fire on application)
            SamyTotemTimersWFCom.WfStatusList[gGUID].duration = 1
            SamyTotemTimersWFCom.WfStatusList[gGUID].expirationTime = expiration
            SamyTotemTimersWFCom.WfStatusList[gGUID].hasWfCom = true
		elseif(commType == "E") then -- message wf lost
            SamyTotemTimersWFCom.WfStatusList[gGUID].duration = 0
            SamyTotemTimersWFCom.WfStatusList[gGUID].expirationTime = 0
            SamyTotemTimersWFCom.WfStatusList[gGUID].hasWfCom = true
		elseif(commType == "I") then -- message signaling that unit has addon installed
			SamyTotemTimersWFCom.WfStatusList[gGUID].hasWfCom = true
		end

	elseif(prefix == COMM_PREFIX) then --wf com new API
		local gGUID, spellID, expiration, lag = strsplit(':', message)
        if(not SamyTotemTimersWFCom.WfStatusList[gGUID] ) then 
            return 
        end

		local spellID, expire, lagHome = tonumber(spellID), tonumber(expiration), tonumber(lagHome)
		if spellID then --update buffs
            SamyTotemTimersWFCom.WfStatusList[gGUID].duration = 1
            SamyTotemTimersWFCom.WfStatusList[gGUID].expirationTime = expire
            SamyTotemTimersWFCom.WfStatusList[gGUID].hasWfCom = true
		else --addon installed or buff expired
            SamyTotemTimersWFCom.WfStatusList[gGUID].duration = 0
            SamyTotemTimersWFCom.WfStatusList[gGUID].expirationTime = 0
            SamyTotemTimersWFCom.WfStatusList[gGUID].hasWfCom = true
		end
	end
end
