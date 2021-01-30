--############################################
-- Namespace
--############################################
local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

--##########################################################################################################################
--                                  Default configurations
--##########################################################################################################################
local dbpcDefaults =
{
    char = {
        ["Version"] = SwitchSwitch.InternalVersion,
        ["debug"] = false,
        ["autoUseTomes"] = true,
        ["talentsSuggestionFrame"] =
        {
            ["location"] =
            {
                ["point"] = "CENTER",
                ["relativePoint"] = "CENTER",
                ["frameX"] = 0,
                ["frameY"] = 0
            },
            ["enabled"] = true,
            ["fadeTime"] = 15
        },
        ["minimap"] =
        {
            ["hide"] = false,
        }
    },
}

local dbDefaults =
{
    global =
    {
        ["Version"] = SwitchSwitch.InternalVersion,
        ["TalentProfiles"] = {},
        ["TalentSuggestions"] = {}
    },
}

--##########################################################################################################################
--                                  Initialization
--##########################################################################################################################
function SwitchSwitch:OnInitialize()
    self:DebugPrint("Addon Initializing")
    self.db = LibStub("AceDB-3.0"):New("SwitchSwitchDB", dbDefaults, true)
    self.dbpc = LibStub("AceDB-3.0"):New("SwitchSwitchDBPC", dbpcDefaults, true)

    -- Register events we will liten to
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterBucketEvent({"AZERITE_ESSENCE_UPDATE", "PLAYER_TALENT_UPDATE"}, 0.75, "PLAYER_TALENT_UPDATE")

    -- #######################################################################################################
    -- UPDATE FROM < 2.0 - DEPRECTED SOON
    -- #######################################################################################################
    self.DEPRECTED_OLD_VERSION_PROFILES = SwitchSwitchProfiles
    self.DEPRECTED_OLD_VERSION_CHAR_CONF = SwitchSwitchConfig

    --Update the tables in case they are not updated
    SwitchSwitch:Update();
end

function SwitchSwitch:OnEnable()
    self:DebugPrint("Addon Enabling")

    --Load Commands
    SwitchSwitch.Commands:Init()

    --Init the minimap
    SwitchSwitch:InitMinimapIcon()

    --Load the UI if not currently loaded
    if(not IsAddOnLoaded("Blizzard_TalentUI")) then
        LoadAddOn("Blizzard_TalentUI")
    end

    -- Enable Boss detection and register instances
    self:RegisterMessage("SWITCHSWITCH_BOSS_DETECTED")
    self:EnableModule("BossDetection")
    for expansion, data in pairs(SwitchSwitch.InstancesBossData) do
        for contentType, contentData in pairs(data) do
            for jurnalID, InstanceData in pairs(contentData) do
                local suggestions = self:GetProfilesSuggestionInstanceData(InstanceData.instanceID)
                local BossDetectionData = InstanceData["bossData"] or {}
                -- Right now we want to register the whole isntance for detection
                -- As we need the data for boss down detection
                --for bossID, _ in pairs(suggestions["bosses"] or {}) do
                --    BossDetectionData[bossID] = InstanceData["bossData"][bossID]
                --end
                local hasInstanceSuggestions = next(suggestions["difficulties"] or {}, nil) ~= nil
                local hasBossSuggestions = next(BossDetectionData, nil) ~= nil
                if(hasBossSuggestions or hasInstanceSuggestions) then
                    self:GetModule("BossDetection"):RegisterInstance(InstanceData.instanceID, BossDetectionData)
                end
            end
        end
    end

    -- Lets refresh all the UIS
    self:PLAYER_TALENT_UPDATE(true)
end

function SwitchSwitch:OnDisable()
    self:DebugPrint("Addon disabling")
end

--##########################################################################################################################
--                                  Config Update to never version
--##########################################################################################################################

local function GetVersionNumber(str)
    if(str == nil) then
        return 0.0
    end

    if(type(str) == "string") then
        if(SwitchSwitch:Repeats(str, "%.") == 2) then
            local index = SwitchSwitch:findLastInString(str, "%.")
            str = string.sub( str, 1, index-1) .. string.sub( str, index+1)
        end

        str = tonumber(str)
    end

    return str
end

function SwitchSwitch:Update()
    --Get old version string
    local globalConfigVersion = GetVersionNumber(self.db.global.Version)
    local characterConfigVerison = GetVersionNumber(self.dbpc.char.Version)

    --Update Global table
    if(globalConfigVersion ~= self.InternalVersion) then

    end

    -- Update character table
    if(characterConfigVerison ~= self.InternalVersion) then

    end

    -- #######################################################################################################
    -- UPDATE FROM < 2.0 - DEPRECTED SOON
    -- #######################################################################################################
    --Update Global table
    if(type(self.DEPRECTED_OLD_VERSION_PROFILES) == "table" and self.DEPRECTED_OLD_VERSION_PROFILES.Version ~= nil) then
        local oldGCV = GetVersionNumber(self.DEPRECTED_OLD_VERSION_PROFILES.Version)

        if(oldGCV ~= self.InternalVersion) then
            self:Print("WARNING! WARNING! WARNING! WARNING! WARNING!")
            self:Print("You just updated form a pre 2.0 version to 2.0. You might need to reset the saved variables if lua errors happen")
            self:Print("WARNING! WARNING! WARNING! WARNING! WARNING!")
            self.db.global.TalentProfiles = self:deepcopy(self.DEPRECTED_OLD_VERSION_PROFILES.Profiles)
            -- We set this to nill as we dont want to import again
            self.DEPRECTED_OLD_VERSION_PROFILES = {}
            SwitchSwitchProfiles = {}
        end
    end

    if(type(self.DEPRECTED_OLD_VERSION_CHAR_CONF) == "table" and self.DEPRECTED_OLD_VERSION_CHAR_CONF.Version ~= nil) then
        local oldCCV = GetVersionNumber(self.DEPRECTED_OLD_VERSION_CHAR_CONF.Version)

        if(oldCCV ~= self.InternalVersion) then
            self:Print("WARNING! WARNING! WARNING! WARNING! WARNING!")
            self:Print("You just updated form a pre 2.0 version to 2.0. You might need to reset the saved variables if lua errors happen")
            self:Print("WARNING! WARNING! WARNING! WARNING! WARNING!")
            self.dbpc.char.debug = self.DEPRECTED_OLD_VERSION_CHAR_CONF.debug
            self.dbpc.char.autoUseTomes = self.DEPRECTED_OLD_VERSION_CHAR_CONF.autoUseItems
            self.dbpc.char.talentsSuggestionFrame.fadeTime = math.min(60,math.max(10, self.DEPRECTED_OLD_VERSION_CHAR_CONF.maxTimeSuggestionFrame))
            self.dbpc.char.talentsSuggestionFrame.enabled = self.DEPRECTED_OLD_VERSION_CHAR_CONF.maxTimeSuggestionFrame > 0
            -- Tables need deep copy
            self.dbpc.char.talentsSuggestionFrame.location = self:deepcopy(self.DEPRECTED_OLD_VERSION_CHAR_CONF.SuggestionFramePoint)
            -- We set this to nill as we dont want to import again
            self.DEPRECTED_OLD_VERSION_CHAR_CONF = {}
            SwitchSwitchConfig = {}
        end
    end
    -- #######################################################################################################

    -- Lastly we update the verison of the config
    self.db.global.Version = self.InternalVersion
    self.dbpc.char.Version = self.InternalVersion
end