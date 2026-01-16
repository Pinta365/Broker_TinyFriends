local addonName, AddonTable = ...

-- Initialize shared variables
AddonTable.friendsFrame = nil
AddonTable.classLookup = {}
AddonTable.tempFontString = nil

local function initTinyFriends()
    -- Initialize saved variables
    AddonTable.initSettings()
    
    --Build a lookup table to so I can get the localization independent class name.
    AddonTable.classLookup = {}
    for i = 1, GetNumClasses() do
        local localizedName, classLocalizationIndependent, _ = GetClassInfo(i)
        AddonTable.classLookup[localizedName] = classLocalizationIndependent
    end
    AddonTable.wowFriendsSort = {
        order = "name",
        ascending = true
    }
    AddonTable.otherFriendsSort = {
        order = "name",
        ascending = true
    }
    AddonTable.wowFriends = {}
    AddonTable.otherFriends = {}
    AddonTable.tempFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    C_FriendList.ShowFriends()
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        initTinyFriends()
        AddonTable.initBroker()
        AddonTable.initOptionsPanel()
    elseif event == "PLAYER_ENTERING_WORLD" then
        AddonTable.updateBrokerText()
    elseif event == "FRIENDLIST_UPDATE" or
        event == "BN_FRIEND_ACCOUNT_ONLINE" or
        event == "BN_FRIEND_ACCOUNT_OFFLINE" or
        event == "BN_FRIEND_INFO_CHANGED" then
        AddonTable.updateBrokerText()
    end
end

local f = CreateFrame("Frame", "BrokerTinyFriends")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("FRIENDLIST_UPDATE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
f:RegisterEvent("BN_FRIEND_INFO_CHANGED")

f:SetScript("OnEvent", onEvent)
