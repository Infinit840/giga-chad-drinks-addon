local frame = CreateFrame("Frame")
GigaChadDrinksDB = GigaChadDrinksDB or {}
GigaChadDrinksDB.sessions = GigaChadDrinksDB.sessions or {}
local activeSession = nil
local combatLogActive = false
local activeSession = nil
local activeEncounter = nil
local combatLogActive = false

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
local function StartCombatLog()
    local success = LoggingCombat(true)

    if success then
        combatLogActive = true
        print("|cff00ff00Giga Chad Drinks:|r Combatlog gestartet.")
    else
        combatLogActive = false
        print("|cffff0000Giga Chad Drinks:|r Combatlog konnte nicht gestartet werden.")
    end
end
local function StopCombatLog()
    LoggingCombat(false)
    print("|cff00ff00Giga Chad Drinks:|r Combatlog beendet.")
end
local function StopCombatLog()
    LoggingCombat(false)
    combatLogActive = false
    print("|cff00ff00Giga Chad Drinks:|r Combatlog beendet.")
end
local function CloseAbandonedSessions()
    for _, session in ipairs(GigaChadDrinksDB.sessions) do
        if not session.endTimestamp then
            session.abandoned = true
        end
    end
end
local function SaveSession()
    GigaChadDrinksDB.sessions = GigaChadDrinksDB.sessions or {}
    local instanceName, instanceType, difficultyID, difficultyName = GetInstanceInfo()
    local session = {
    timestamp = time(),
    encounters = {},
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
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        CloseAbandonedSessions()
        SaveCharacterSnapshot()
        SaveGearSnapshot()
        StartCombatLog()

        print("|cff00ff00Giga Chad Drinks:|r Die Bar ist geöffnet.")

    elseif event == "ENCOUNTER_START" then
    local encounterID, encounterName, difficultyID, groupSize = ...

    if activeSession then
        activeSession.encounters = activeSession.encounters or {}

        activeEncounter = {
            encounterID = encounterID,
            name = encounterName,
            difficultyID = difficultyID,
            groupSize = groupSize,
            startTimestamp = time()
        }

        table.insert(activeSession.encounters, activeEncounter)
    end

    print(
        "|cff00ff00Giga Chad Drinks:|r Encounter gestartet: " ..
        tostring(encounterName) ..
        " | ID: " .. tostring(encounterID) ..
        " | Spieler: " .. tostring(groupSize)
    )

    elseif event == "ENCOUNTER_END" then
    local encounterID, encounterName, difficultyID, groupSize, success = ...

    local result = "WIPE"

    if success == 1 then
        result = "KILL"
    end

    if activeEncounter and activeEncounter.encounterID == encounterID then
        activeEncounter.endTimestamp = time()
        activeEncounter.success = success == 1
        activeEncounter.result = result
        activeEncounter = nil
    end

    print(
        "|cff00ff00Giga Chad Drinks:|r Encounter beendet: " ..
        tostring(encounterName) ..
        " | " .. result
    )
end
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
chadWindow:SetResizeBounds(420, 300, 800, 600)

-- Gespeicherte Größe laden
if GigaChadDrinksDB.windowSize then
    local width = math.max(GigaChadDrinksDB.windowSize.width, 420)
    local height = math.max(GigaChadDrinksDB.windowSize.height, 300)

    chadWindow:SetSize(width, height)
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
local UpdateGroupPanel
local UpdateLogsPanel
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

    if selectedTab == 2 and UpdateGroupPanel then
        UpdateGroupPanel()
    end

    if selectedTab == 3 and UpdateCharacterPanel then
        UpdateCharacterPanel()
    end

    if selectedTab == 4 and UpdateLogsPanel then
        UpdateLogsPanel()
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
-- Gruppen-Tab

local groupText = panels[2]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
groupText:SetPoint("TOPLEFT", panels[2], "TOPLEFT", 20, -20)
groupText:SetJustifyH("LEFT")

UpdateGroupPanel = function()
    local lines = {
        "GRUPPE",
        ""
    }

    local function AddUnit(unit)
        if not UnitExists(unit) then
            return
        end

        local name, realm = UnitFullName(unit)
        local level = UnitLevel(unit)
        local className, class = UnitClass(unit)
        local role = UnitGroupRolesAssigned(unit)

        if not name then
            return
        end

        local displayName = name

        if realm and realm ~= "" then
            displayName = displayName .. " - " .. realm
        end

        -- Name in Klassenfarbe
        local color = RAID_CLASS_COLORS[class]

        if color then
            displayName = color:WrapTextInColorCode(displayName)
        end

        -- Rollen schöner darstellen
        local roleNames = {
            TANK = "Tank",
            HEALER = "Heiler",
            DAMAGER = "DPS",
            NONE = "Keine Rolle"
        }

        role = roleNames[role] or "Keine Rolle"

        table.insert(
            lines,
            displayName ..
            " | " ..
            (className or "Unknown") ..
            " | " ..
            role ..
            " | Level " ..
            tostring(level or "?")
        )
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            AddUnit("raid" .. i)
        end

    elseif IsInGroup() then
        AddUnit("player")

        for i = 1, GetNumSubgroupMembers() do
            AddUnit("party" .. i)
        end

    else
        AddUnit("player")

        table.insert(lines, "")
        table.insert(lines, "Du bist aktuell in keiner Gruppe.")
    end

    groupText:SetText(table.concat(lines, "\n"))
end
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
-- Logs-Tab
local logsText = panels[4]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
logsText:SetPoint("TOPLEFT", panels[4], "TOPLEFT", 20, -20)
logsText:SetJustifyH("LEFT")

UpdateLogsPanel = function()
    local sessionCount = #GigaChadDrinksDB.sessions

    local combatLogStatus
    if combatLogActive then
        combatLogStatus = "|cff00ff00AKTIV|r"
    else
        combatLogStatus = "|cffff0000INAKTIV|r"
    end

    local sessionStatus
    if activeSession then
        sessionStatus = "|cff00ff00AKTIV|r"
    else
        sessionStatus = "|cffff0000INAKTIV|r"
    end

    local lines = {
        "LOGS",
        "",
        "Combatlog: " .. combatLogStatus,
        "Session: " .. sessionStatus,
        "",
        "Gespeicherte Sessions: " .. tostring(sessionCount)
    }

    if activeSession then
        local duration = time() - activeSession.timestamp
        local hours = math.floor(duration / 3600)
        local minutes = math.floor((duration % 3600) / 60)
        local seconds = duration % 60

        local durationText = string.format(
            "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )

        local groupSize = 1

        if activeSession.group then
            groupSize = #activeSession.group
        end

        local encounterCount = 0

        if activeSession.encounters then
            encounterCount = #activeSession.encounters
        end

        table.insert(lines, "")
        table.insert(lines, "AKTUELLE SESSION")
        table.insert(lines, "")
        table.insert(lines, "Zone: " .. (activeSession.zone or "Unbekannt"))
        table.insert(lines, "Instanz: " .. (activeSession.instanceName or "Keine"))
        table.insert(lines, "Gruppe: " .. tostring(groupSize) .. " Spieler")
        table.insert(lines, "Laufzeit: " .. durationText)
        table.insert(lines, "Encounters: " .. tostring(encounterCount))

        if encounterCount > 0 then
            table.insert(lines, "")
            table.insert(lines, "LETZTE ENCOUNTERS")
            table.insert(lines, "")

            local firstEncounter = math.max(1, encounterCount - 4)

            for i = encounterCount, firstEncounter, -1 do
                local encounter = activeSession.encounters[i]

                local encounterDurationText = "Läuft..."

                if encounter.endTimestamp then
                    local encounterDuration =
                        encounter.endTimestamp - encounter.startTimestamp

                    local encounterMinutes =
                        math.floor(encounterDuration / 60)

                    local encounterSeconds =
                        encounterDuration % 60

                    encounterDurationText = string.format(
                        "%02d:%02d",
                        encounterMinutes,
                        encounterSeconds
                    )
                end

                local result = encounter.result or "AKTIV"

                table.insert(
                    lines,
                    (encounter.name or "Unbekannter Boss") ..
                    " | " ..
                    result ..
                    " | " ..
                    encounterDurationText
                )
            end
        end
    end

    if sessionCount > 0 then
        table.insert(lines, "")
        table.insert(lines, "LETZTE SESSIONS")
        table.insert(lines, "")

        local firstSession = math.max(1, sessionCount - 4)

        for i = sessionCount, firstSession, -1 do
            local session = GigaChadDrinksDB.sessions[i]

            local sessionTime = date("%d.%m. %H:%M", session.timestamp)
            local zone = session.zone or "Unbekannt"

            local durationText = "Abgebrochen"

            if session.endTimestamp then
                local duration =
                    session.endTimestamp - session.timestamp

                local hours = math.floor(duration / 3600)
                local minutes = math.floor((duration % 3600) / 60)
                local seconds = duration % 60

                durationText = string.format(
                    "%02d:%02d:%02d",
                    hours,
                    minutes,
                    seconds
                )
            end

            table.insert(
                lines,
                sessionTime ..
                " | " ..
                zone ..
                " | " ..
                durationText
            )
        end
    end

    logsText:SetText(table.concat(lines, "\n"))
end
local logsUpdateTimer = 0

panels[4]:SetScript("OnUpdate", function(self, elapsed)
    logsUpdateTimer = logsUpdateTimer + elapsed

    if logsUpdateTimer >= 1 then
        logsUpdateTimer = 0

        if self:IsShown() and UpdateLogsPanel then
            UpdateLogsPanel()
        end
    end
end)
SlashCmdList["GIGACHADDRINKS"] = function()
    if chadWindow:IsShown() then
        chadWindow:Hide()
    else
        chadWindow:Show()
    end
end