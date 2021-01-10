local SwitchSwitch, L, AceGUI, LibDBIcon = unpack(select(2, ...))

local LDBSwitchSwitch = LibStub("LibDataBroker-1.1"):NewDataObject("SwitchSwitchIcon", {
    type = "data source", 
    text = "Switch Switch",
    icon = "Interface\\Icons\\INV_Artifact_Tome02",
});
local mmIcon = LibStub("LibDBIcon-1.0")
local AlreadyRegistered = false

function LDBSwitchSwitch:OnTooltipShow()
    local tooltip = self
    tooltip:AddLine("Switch Switch V" .. SwitchSwitch.InternalVersion)
    tooltip:AddLine(" ")
    tooltip:AddLine(("%s%s: %s%s|r"):format(RED_FONT_COLOR_CODE, L["Click"], NORMAL_FONT_COLOR_CODE, L["Show config panel"]))
    tooltip:AddLine(" ")
    if(SwitchSwitch.dbpc.char.SelectedTalentsProfile ~= SwitchSwitch.CustomProfileName) then
        tooltip:AddLine(("%s%s: |cffa0522d%s|r"):format(NORMAL_FONT_COLOR_CODE, L["Current Profile"], SwitchSwitch.dbpc.char.SelectedTalentsProfile))
    else
        tooltip:AddLine(("%s%s. |r"):format(NORMAL_FONT_COLOR_CODE, L["No profile is active, select or create one"]))
    end
end

function LDBSwitchSwitch:OnClick(button, down)
    SwitchSwitch.ConfigFrame:ToggleFrame()
end

function SwitchSwitch:InitMinimapIcon()
    if(AlreadyRegistered == false) then
        mmIcon:Register("SwitchSwitch", LDBSwitchSwitch, self.dbpc.char)
        AlreadyRegistered = true
    end
end