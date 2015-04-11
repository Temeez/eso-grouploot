local ADDON_NAME    = "GroupLoot"

local GLSettings = nil -- turha?

GroupLoot = {}

function GroupLoot:Initialize()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, function(...) self:OnItemLooted(...) end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNIT_DEATH_STATE_CHANGED, function(...) self:OnDeath(...) end)
end

-- EVENT_ADD_ON_LOADED
function GroupLoot:OnAddOnLoaded(event, addonName)
    if(addonName ~= ADDON_NAME) then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    GLSettings  = GroupLootSettings:New()
    GLHighscore = GroupLootHighscore:New()

    self:Initialize()
end

-- EVENT_LOOT_RECEIVED
function GroupLoot:OnItemLooted(event, lootedBy, itemLink, quantity, itemSound, lootType, player)
    local lootMessage   = nil
    local itemQuality   = GetItemLinkQuality(itemLink)
    local name          = lootedBy:gsub("%^%a+","")
    local itemLink      = itemLink:gsub("%^%a+","")
    local totalValue    = GetItemLinkValue(itemLink, true) * quantity

    -- Return if own (player) loot is off
    if player and not GLSettings:DisplayOwnLoot() then return end
    -- Return if group loot is off
    if not player and not GLSettings:DisplayGroupLoot() then return end

    -- Check if the loot receiver is already added into the members table, add if not.
    if not GLHighscore:MemberExists(name) then GLHighscore:NewMember(name) end

    -- Trash items (grey)
    if itemQuality == ITEM_QUALITY_TRASH then
        if not GroupLootSettings:GetSettings().displayTrash then return else GLHighscore:UpdateTrash(name, quantity) end
    end
    -- Normal items (white)
    if itemQuality == ITEM_QUALITY_NORMAL then
        if not GroupLootSettings:GetSettings().displayNormal then return else GLHighscore:UpdateNormal(name, quantity) end
    end
    -- Magic items (green)
    if itemQuality == ITEM_QUALITY_MAGIC then
        if not GroupLootSettings:GetSettings().displayMagic then return else GLHighscore:UpdateMagic(name, quantity) end
    end
    -- Arcane items (blue)
    if itemQuality == ITEM_QUALITY_ARCANE then
        if not GroupLootSettings:GetSettings().displayArcane then return else GLHighscore:UpdateArcane(name, quantity) end
    end
    -- Artifact items (purple)
    if itemQuality == ITEM_QUALITY_ARTIFACT then
        if not GroupLootSettings:GetSettings().displayArtifact then return else GLHighscore:UpdateArtifact(name, quantity) end
    end
    -- Legendary items (yellow)
    if itemQuality == ITEM_QUALITY_LEGENDARY then
        if not GroupLootSettings:GetSettings().displayLegendary then return else GLHighscore:UpdateLegendary(name, quantity) end
    end

    -- Update total loot value
    GLHighscore:UpdateTotalValue(name, totalValue)

    -- Update best loot
    if GLHighscore:IsBestLoot(name, totalValue) then
        GLHighscore:UpdateBestLoot(name, itemLink)
    end

    -- Player or group member
    if not player then
        lootMessage = name .. " received " .. itemLink .. " x" .. quantity .. " worth " .. totalValue .. "g"
        if GLSettings:DisplayInChat() then d(lootMessage) end
        GroupLootWindowBuffer:AddMessage(lootMessage, 255, 255, 0, 1)
    else
        lootMessage = "Received " .. itemLink .. " x" .. quantity .. " worth " .. totalValue .. "g"
        if GLSettings:DisplayInChat() then d(lootMessage) end
        GroupLootWindowBuffer:AddMessage(lootMessage, 255, 255, 0, 1)
     end
end

-- EVENT_UNIT_DEATH_STATE_CHANGED
function GroupLoot:OnDeath(event, unit, isDead)
    -- Dead group members only
    if string.match(unit, "group") and isDead then
        local name = GetUnitName(unit)
        -- Check if the dead group member is already added into the members table (should be), add if not.
        if not GLHighscore:MemberExists(name) then GLHighscore:NewMember(name) end
        GLHighscore:UpdateDeath(name, 1)
    end
end

-- Load the addon with this
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(...) GroupLoot:OnAddOnLoaded(...) end)