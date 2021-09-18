assert(LibStub, "WindfuryComm requires LibStub")

local major, minor = "LibWFcomm", 2
local LibWFcomm = LibStub:NewLibrary(major, minor)
local CTL = _G.ChatThrottleLib
local COMM_PREFIX = "WF_STATUS"
C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)

pGUID = UnitGUID("player")
pClass = select(2, UnitClass("player"))


-- new message format C_ChatInfo.SendAddonMessage("WF_STATUS", "<guid>:<id>:<expire>:<lagHome>:additional:stuff", "PARTY")
function windfuryDurationCheck()
	msg = nil
	local _,_,lagHome,_ = GetNetStats()
	local mh,expiration,_,enchid,_,_,_,_ = GetWeaponEnchantInfo("player")
	if mh then
		msg = format("%s:%d:%d:%d", pGUID, enchid, expiration, lagHome) -- message: wf active + duration
	else
		msg = format("%s:nil:nil:%s", pGUID, lagHome) -- message: wf expired
	end
	if CTL and msg then
		CTL:SendAddonMessage("BULK", COMM_PREFIX, msg, 'PARTY')
	end
	msg = nil
end

function checkForShaman()
	local shamanPresent = nil
	for index=1,4 do
		local pstring = "party"..index
		local gclass = select(2, UnitClass(pstring))
		if (gclass == "SHAMAN") then
			shamanPresent = true
		end
	end
	return shamanPresent
end
		

function LibWFcomm:PLAYER_LOGIN()
	self.eventReg:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:GROUP_ROSTER_UPDATE()
	print( "WindfuryComm sender module loaded" )
end

function LibWFcomm:GROUP_ROSTER_UPDATE()
	if( GetNumGroupMembers() ~= 0 and checkForShaman()) then
		LibWFcomm.eventReg:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
		C_Timer.After(0.15, function() windfuryDurationCheck() end)
	else
		LibWFcomm.eventReg:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	end
end

function LibWFcomm:UNIT_INVENTORY_CHANGED()
	C_Timer.After(0.15, function() windfuryDurationCheck() end)
end

local function OnEvent(self, event, ...)
	LibWFcomm[event](LibWFcomm, ...)
end

if ( pClass == "WARRIOR" or pClass == "ROGUE" or pClass == "PALADIN" or pClass == "HUNTER" ) then
	LibWFcomm.eventReg = LibWFcomm.eventReg or CreateFrame("Frame")
	LibWFcomm.eventReg:SetScript("OnEvent", OnEvent)
	if( not IsLoggedIn() ) then
		LibWFcomm.eventReg:RegisterEvent("PLAYER_LOGIN")
	else
		LibWFcomm:PLAYER_LOGIN()
	end
end