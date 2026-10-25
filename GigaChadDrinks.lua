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
local function SaveSession()
    GigaChadDrinksDB.sessions = GigaChadDrinksDB.sessions or {}
    local session = {
        timestamp = time(),
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

SlashCmdList["GIGACHADDRINKS"] = function()
  local startSessionButton = CreateFrame("Button", nil, chadWindow, "UIPanelButtonTemplate")
startSessionButton:SetSize(160, 30)
startSessionButton:SetPoint("CENTER", 0, -40)
startSessionButton:SetText("SESSION STARTEN")

startSessionButton:SetScript("OnClick", function()
    if activeSession then
        activeSession.endTimestamp = time()

        print("|cff00ff00Giga Chad Drinks:|r Session beendet.")

        activeSession = nil
        startSessionButton:SetText("SESSION STARTEN")
    else
        SaveCharacterSnapshot()
        SaveGearSnapshot()

        activeSession = SaveSession()

        startSessionButton:SetText("SESSION BEENDEN")

        print("|cff00ff00Giga Chad Drinks:|r Session gestartet.")
    end
end)
    if chadWindow:IsShown() then
        chadWindow:Hide()
    else
        chadWindow:Show()
    end
end