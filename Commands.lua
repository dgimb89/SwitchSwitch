--############################################
-- Namespace
--############################################
local _, addon = ...

addon.Commands = {}

local Commands = addon.Commands

--##########################################################################################################################
--                                  Commands Fnctions
--##########################################################################################################################
function Commands:Help()
    addon:Print("--------- |cff00F3FFList of commands:|r ---------");
    addon:Print("|cff188E01/ss help|r - Shows all commands.");
    addon:Print("|cff188E01/ss config|r - Shows the config frame.");
	addon:Print("|cff188E01/ss load <profileName>|r - Loads a talent profile.");
	addon:Print("-------------------------------------");
end

function Commands:LoadProfileCMD(...)
	addon:ActivateTalentProfile(string.join(" ", tostringall(...)))
end


--##########################################################################################################################
--                                  Commands handling
--##########################################################################################################################
local CommandList =
{
	["config"] = addon.ConfigFrame.ToggleFrame,
	["help"] = Commands.Help,
	["load"] = Commands.LoadProfileCMD
}

local function HandleSlashCommands(str)
	if (#str == 0) then
		Commands:Help()
		-- User entered command without any args
		return
	end	
	
	local args = {}
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg)
		end
	end
	
	local path = CommandList -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower()		
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function
					path[arg](addon, select(id + 1, unpack(args)))
					return
				elseif (type(path[arg]) == "table") then				
					path = path[arg] -- another sub-table found!
				end
			else
				-- does not exist!
				Commands:Help()
				return
			end
		end
	end
end

--##########################################################################################################################
--                                  Commands Init
--##########################################################################################################################
function Commands:Init()
    SLASH_SwitchSwitch1 = "/ss"
    SLASH_SwitchSwitch2 = "/sstalent"
    SLASH_SwitchSwitch3 = "/switchswitch"
    SlashCmdList.SwitchSwitch = HandleSlashCommands
end