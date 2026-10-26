local frame = CreateFrame("Frame")
GigaChadDrinksDB = GigaChadDrinksDB or {}
GigaChadDrinksDB.sessions = GigaChadDrinksDB.sessions or {}
local activeSession = nil

local function SaveCharacterSnapshot()
    local name, realm = UnitFullName("player")
    local _, class = UnitClass("player")
    local level = UnitLevel("player")

    local specIndex = GetSpecialization()
    local specName = "Unknown"

    if specIndex then
        local _, nameOfSpec = GetSpecializationInfo(specIndex)
        specName = nameOfSpec
    end

    local averageItemLevel, equippedItemLevel = GetAverageItemLevel()

    GigaChadDrinksDB.character = {
        name = name,
        realm = realm,
        class = class,
        spec = specName,
        level = level,
        averageItemLevel = averageItemLevel,
        equippedItemLevel = equippedItemLevel,
        timestamp = time()
    }
end
local function SaveGearSnapshot()
    local gear = {}

    for slot = 1, 19 do
        local itemLink = GetInventoryItemLink("player", slot)

        if itemLink then
            local itemID = GetInventoryItemID("player", slot)

gear[slot] = {
    itemID = itemID,
    itemLink = itemLink
}
        end
    end

    GigaChadDrinksDB.gear = {
        timestamp = time(),
        items = gear
    }
end
local function GetGroupSnapshot()
    local group = {}

    local playerName, playerRealm = UnitFullName("player")

    table.insert(group, {
        name = playerName,
        realm = playerRealm
    })

    if IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            local unit = "party" .. i

            if UnitExists(unit) then
                local name, realm = UnitFullName(unit)

                table.insert(group, {
                    name = name,
                    realm = realm
                })
            end
        end
    end

    return group
end
local function StartCombatLog()
    local success = LoggingCombat(true)

    if success then
        print("|cff00ff00Giga Chad Drinks:|r Combatlog gestartet.")
    else
        print("|cffff0000Giga Chad Drinks:|r Combatlog konnte nicht gestartet werden.")
    end
end
local function StopCombatLog()
    LoggingCombat(false)
    print("|cff00ff00Giga Chad Drinks:|r Combatlog beendet.")
end
local function SaveSession()
    GigaChadDrinksDB.sessions = GigaChadDrinksDB.sessions or {}
    local instanceName, instanceType, difficultyID, difficultyName = GetInstanceInfo()
    local session = {
    timestamp = time(),
    zone = GetZoneText(),
    subZone = GetSubZoneText(),
    instanceName = instanceName,
    instanceType = instanceType,
    difficultyID = difficultyID,
    difficultyName = difficultyName,
    group = GetGroupSnapshot(),
    character = GigaChadDrinksDB.character,
    gear = GigaChadDrinksDB.gear
}

    table.insert(GigaChadDrinksDB.sessions, session)
return session
end
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function()
    SaveCharacterSnapshot()
    SaveGearSnapshot()
    StartCombatLog()

    print("|cff00ff00Giga Chad Drinks:|r Die Bar ist geöffnet.")
end)



    

 
SLASH_GIGACHADDRINKS1 = "/chad"

local chadWindow = CreateFrame("Frame", "GigaChadDrinksWindow", UIParent, "BasicFrameTemplateWithInset")
chadWindow:SetSize(420, 250)
chadWindow:SetPoint("CENTER")
chadWindow:Hide()

chadWindow.title = chadWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chadWindow.title:SetPoint("LEFT", chadWindow.TitleBg, "LEFT", 5, 0)
chadWindow.title:SetText("Giga Chad Drinks")

chadWindow.text = chadWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
chadWindow.text:SetPoint("CENTER", 0, 10)
chadWindow.text:SetText("Die Bar ist geöffnet.")


  local startSessionButton = CreateFrame("Button", nil, chadWindow, "UIPanelButtonTemplate")
startSessionButton:SetSize(160, 30)
startSessionButton:SetPoint("CENTER", 0, -40)
startSessionButton:SetText("SESSION STARTEN")

startSessionButton:SetScript("OnClick", function()
    if activeSession then
        activeSession.endTimestamp = time()
        StopCombatLog()

        print("|cff00ff00Giga Chad Drinks:|r Session beendet.")

        activeSession = nil
        startSessionButton:SetText("SESSION STARTEN")
    else
        SaveCharacterSnapshot()
        SaveGearSnapshot()
        StartCombatLog()

        activeSession = SaveSession()

        startSessionButton:SetText("SESSION BEENDEN")

        print("|cff00ff00Giga Chad Drinks:|r Session gestartet.")
    end
end)
SlashCmdList["GIGACHADDRINKS"] = function()
    if chadWindow:IsShown() then
        chadWindow:Hide()
    else
        chadWindow:Show()
    end
end