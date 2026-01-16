-- Configuration and constants

local addonName, AddonTable = ...

local clientList = {
    WoW = "World of Warcraft",
    WTCG = "Hearthstone",
    Hero = "Heroes of the Storm",
    Pro = "Overwatch",
    OSI = "Diablo 2: Resurrected",
    D3 = "Diablo 3",
    Fen = "Diablo 4",
    ANBS = "Diablo Immortal",
    S1 = "Starcraft",
    S2 = "Starcraft 2",
    W3 = "Warcraft 3: Reforged",
    RTRO = "Arcade Collection",
    WLBY = "Crash Bandicoot 4",
    VIPR = "COD: Black Ops 4",
    ODIN = "COD: Warzone",
    AUKS = "COD: Warzone 2",
    LAZR = "COD: Modern Warfare 2",
    ZEUS = "COD: Cold War",
    FORE = "COD: Vanguard",
    GRY = "Warcraft Rumble",
    App = "Desktop App",
    BSAp = "Mobile App"
}

-- Default settings
AddonTable.defaultSettings = {
    debug = false,
    backgroundOpacity = 0.8  -- Default tooltip transparency (0.0 = transparent, 1.0 = opaque)
}

-- Initialize saved variables
function AddonTable.initSettings()
    BrokerTinyFriendsDB = BrokerTinyFriendsDB or {}
    
    -- Merge defaults with existing settings
    for key, value in pairs(AddonTable.defaultSettings) do
        if BrokerTinyFriendsDB[key] == nil then
            BrokerTinyFriendsDB[key] = value
        end
    end
end

-- Export to AddonTable for use in other modules
AddonTable.clientList = clientList

