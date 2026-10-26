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
chadWindow:SetMovable(true)
chadWindow:EnableMouse(true)
chadWindow:RegisterForDrag("LeftButton")
chadWindow:Hide()

chadWindow:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

chadWindow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    GigaChadDrinksDB.windowPosition = {
        point = point,
        relativePoint = relativePoint,
        x = xOfs,
        y = yOfs
    }
end)
if GigaChadDrinksDB.windowPosition then
    local pos = GigaChadDrinksDB.windowPosition

    chadWindow:ClearAllPoints()
    chadWindow:SetPoint(
        pos.point,
        UIParent,
        pos.relativePoint,
        pos.x,
        pos.y
    )
end
-- Fenstergröße veränderbar machen
chadWindow:SetResizable(true)
chadWindow:SetResizeBounds(320, 180, 800, 600)

-- Gespeicherte Größe laden
if GigaChadDrinksDB.windowSize then
    chadWindow:SetSize(
        GigaChadDrinksDB.windowSize.width,
        GigaChadDrinksDB.windowSize.height
    )
end

-- Resize-Griff unten rechts
local resizeHandle = CreateFrame("Button", nil, chadWindow)
resizeHandle:SetSize(20, 20)
resizeHandle:SetPoint("BOTTOMRIGHT", -4, 4)
resizeHandle:EnableMouse(true)

resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeHandle:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        chadWindow:StartSizing("BOTTOMRIGHT")
    end
end)

resizeHandle:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        chadWindow:StopMovingOrSizing()

        GigaChadDrinksDB.windowSize = {
            width = chadWindow:GetWidth(),
            height = chadWindow:GetHeight()
        }
    end
end)
chadWindow.title = chadWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chadWindow.title:SetPoint("LEFT", chadWindow.TitleBg, "LEFT", 5, 0)
chadWindow.title:SetText("Giga Chad Drinks")
local tabs = {}
local panels = {}
local UpdateCharacterPanel
local tabNames = {
    "Session",
    "Gruppe",
    "Charakter",
    "Logs"
}

local function SelectTab(selectedTab)
    for i, tab in ipairs(tabs) do
        if i == selectedTab then
            tab:LockHighlight()
        else
            tab:UnlockHighlight()
        end
    end

    for i, panel in ipairs(panels) do
        if i == selectedTab then
            panel:Show()
        else
            panel:Hide()
        end
    end

    if selectedTab == 3 and UpdateCharacterPanel then
        UpdateCharacterPanel()
    end
end

for i, name in ipairs(tabNames) do
    local tab = CreateFrame("Button", nil, chadWindow, "UIPanelButtonTemplate")

    tab:SetSize(95, 25)
    tab:SetText(name)

    if i == 1 then
        tab:SetPoint("TOPLEFT", chadWindow, "BOTTOMLEFT", 10, 2)
    else
        tab:SetPoint("LEFT", tabs[i - 1], "RIGHT", 5, 0)
    end

    tab:SetScript("OnClick", function()
        SelectTab(i)
    end)

    tabs[i] = tab
end


for i = 1, #tabNames do
    local panel = CreateFrame("Frame", nil, chadWindow)

    panel:SetPoint("TOPLEFT", chadWindow, "TOPLEFT", 10, -60)
    panel:SetPoint("BOTTOMRIGHT", chadWindow, "BOTTOMRIGHT", -10, 10)

    panels[i] = panel
end

SelectTab(1)

local sessionText = panels[1]:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
sessionText:SetPoint("CENTER", 0, 20)
sessionText:SetText("Die Bar ist geöffnet.")


local startSessionButton = CreateFrame("Button", nil, panels[1], "UIPanelButtonTemplate")
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

-- Charakter-Tab
local characterText = panels[3]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
characterText:SetPoint("TOPLEFT", panels[3], "TOPLEFT", 20, -20)
characterText:SetJustifyH("LEFT")

UpdateCharacterPanel = function()
    SaveCharacterSnapshot()

    local character = GigaChadDrinksDB.character

    if not character then
        characterText:SetText("Keine Charakterdaten verfügbar.")
        return
    end

    local displayName = character.name or "Unknown"
    if character.realm and character.realm ~= "" then
        displayName = displayName .. " - " .. character.realm
    end

    characterText:SetText(
        "CHARAKTER\n\n" ..
        displayName .. "\n" ..
        (character.spec or "Unknown") .. " " .. (character.class or "Unknown") .. "\n" ..
        "Level: " .. tostring(character.level or "?") .. "\n\n" ..
        "ITEMLEVEL\n" ..
        "Ausgerüstet: " .. string.format("%.1f", character.equippedItemLevel or 0) .. "\n" ..
        "Durchschnitt: " .. string.format("%.1f", character.averageItemLevel or 0)
    )
end
SlashCmdList["GIGACHADDRINKS"] = function()
    if chadWindow:IsShown() then
        chadWindow:Hide()
    else
        chadWindow:Show()
    end
end