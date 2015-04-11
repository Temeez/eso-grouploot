local ADDON_NAME = "GroupLoot"

local LAM2 = LibStub("LibAddonMenu-2.0")
if not LAM2 then return end

GroupLootSettings = ZO_Object:Subclass()

local settings = nil

function GroupLootSettings:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function GroupLootSettings:Initialize()
    GroupLootDefaults = {
        displayGold         = true,
        displayTrash        = false, -- Grey
        displayNormal       = true, -- White
        displayMagic        = true, -- Green
        displayArcane       = true, -- Blue
        displayArtifact     = true, -- Purple
        displayLegendary    = true, -- Yellow
        displayOnWindow     = true,
        displayOnChat       = true,
        displayOwnLoot      = true,
        displayGroupLoot    = true,
        positionLeft        = nil,
        positionTop         = nil,
    }

    --
    settings = ZO_SavedVars:New(ADDON_NAME .. "_db", 2, nil, GroupLootDefaults)
    -- 
    if not settings.displayOnWindow then GroupLootWindow:SetHidden(not settings.displayOnWindow) end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_LAYER_POPPED, GroupLootSettings.ShowInterface)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_LAYER_PUSHED, GroupLootSettings.HideInterface)
    --

    if settings.displayOnWindow then
        self:SetWindowValues()
    end

    local panelData = {
        type = "panel",
        name = ADDON_NAME,
        displayName = "Group Loot",
        author = "Temeez",
        version = ADDON_VERSION,
        slashCommand = "/grouploot",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = "Display and Count",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Own loot",
            tooltip = "Show or hide loot the loot you get.",
            getFunc = function() return settings.displayOwnLoot end,
            setFunc = function(value) self:ToggleOwnLoot(value) end,
            width = "full",
            default = settings.displayOwnLoot,
        },
        {
            type = "checkbox",
            name = "Group loot",
            tooltip = "Show or hide the loot group members get.",
            getFunc = function() return settings.displayGroupLoot end,
            setFunc = function(value) self:ToggleGroupLoot(value) end,
            width = "full",
            default = settings.displayGroupLoot,
        },
        {
            type = "checkbox",
            name = "Trash",
            tooltip = "Show or hide trash (grey) items on loot.",
            getFunc = function() return settings.displayTrash end,
            setFunc = function(value) self:ToggleTrash(value) end,
            width = "full",
            default = settings.displayTrash
        },
        {
            type = "checkbox",
            name = "Normal",
            tooltip = "Show or hide normal (white) items on loot.",
            getFunc = function() return settings.displayNormal end,
            setFunc = function(value) self:ToggleNormal(value) end,
            width = "full",
            default = settings.displayNormal
        },
        {
            type = "checkbox",
            name = "Magic",
            tooltip = "Show or hide magic (green) items on loot.",
            getFunc = function() return settings.displayMagic end,
            setFunc = function(value) self:ToggleMagic(value) end,
            width = "full",
            default = settings.displayMagic
        },
        {
            type = "checkbox",
            name = "Arcane",
            tooltip = "Show or hide arcane (blue) items on loot.",
            getFunc = function() return settings.displayArcane end,
            setFunc = function(value) self:ToggleArcane(value) end,
            width = "full",
            default = settings.displayArcane
        },
        {
            type = "checkbox",
            name = "Artifact",
            tooltip = "Show or hide artifact (purple) items on loot.",
            getFunc = function() return settings.displayArtifact end,
            setFunc = function(value) self:ToggleArtifact(value) end,
            width = "full",
            default = settings.displayArtifact
        },
        {
            type = "checkbox",
            name = "Legendary",
            tooltip = "Show or hide legendary (yellow) items on loot.",
            getFunc = function() return settings.displayLegendary end,
            setFunc = function(value) self:ToggleLegendary(value) end,
            width = "full",
            default = settings.displayLegendary
        },

        {
            type = "header",
            name = "Display Settings",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display on chat",
            tooltip = "Show or hide loot on chat.",
            getFunc = function() return settings.displayOnChat end,
            setFunc = function(value) self:ToggleOnChat(value) end,
            width = "full",
            default = settings.displayOnChat
        },
        {
            type = "checkbox",
            name = "Display on window",
            tooltip = "Show or hide loot on the window.",
            getFunc = function() return settings.displayOnWindow end,
            setFunc = function(value) self:ToggleOnWindow(value) end,
            width = "full",
            default = settings.displayOnWindow,
        },
    }

    LAM2:RegisterOptionControls(ADDON_NAME .. "Panel", optionsTable)
end

function GroupLootSettings:GetSettings()
    return settings
end

function GroupLootSettings:DisplayInChat()
    return settings.displayOnChat
end

function GroupLootSettings:DisplayOwnLoot()
    return settings.displayOwnLoot
end

function GroupLootSettings:DisplayGroupLoot()
    return settings.displayGroupLoot
end

--[[
    UI functions

    piste -> : ? tesm
]]--
function GroupLootSettings.HideInterface(event, layerIndex, activeLayerIndex)
    if (activeLayerIndex == 3) then
        GroupLootWindow:SetHidden(true)
    end
end

function GroupLootSettings.ShowInterface(...)
    if settings.displayOnWindow then
        GroupLootSettings:SetWindowValues()
    end
end

function GroupLootSettings:MoveStart()
    GroupLootWindowBG:SetAlpha(0.5)
end

function GroupLootSettings:MoveStop()
    GroupLootWindowBG:SetAlpha(0)
    settings.positionLeft = math.floor(GroupLootWindow:GetLeft())
    settings.positionTop = math.floor(GroupLootWindow:GetTop())
end

function GroupLootSettings:SetWindowValues()
    local left  = settings.positionLeft
    local top   = settings.positionTop

    GroupLootWindow:ClearAnchors()
    GroupLootWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    GroupLootWindow:SetAlpha(0.5)
    GroupLootWindowBG:SetAlpha(0)
    GroupLootWindow:SetHidden(false)

    GroupLootWindowBuffer:ClearAnchors()
    GroupLootWindowBuffer:SetAnchor(TOP, GroupLootWindow, TOP, 0, 0)
    GroupLootWindowBuffer:SetWidth(400)
    GroupLootWindowBuffer:SetHeight(80)
end

--[[
    Addon menu functions
]]--
function GroupLootSettings:ToggleTrash(value)
    settings.displayTrash = value
end

function GroupLootSettings:ToggleNormal(value)
    settings.displayNormal = value
end

function GroupLootSettings:ToggleMagic(value)
    settings.displayMagic = value
end

function GroupLootSettings:ToggleArcane(value)
    settings.displayArcane = value
end

function GroupLootSettings:ToggleArtifact(value)
    settings.displayArtifact = value
end

function GroupLootSettings:ToggleLegendary(value)
    settings.displayLegendary = value
end

function GroupLootSettings:ToggleOnChat(value)
    settings.displayOnChat = value
end

function GroupLootSettings:ToggleOnWindow(value)
    settings.displayOnWindow = value
    if value then self:SetWindowValues() end
end

function GroupLootSettings:ToggleOwnLoot(value)
    settings.displayOwnLoot = value
end

function GroupLootSettings:ToggleGroupLoot(value)
    settings.displayGroupLoot = value
end