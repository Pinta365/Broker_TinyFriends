local addonName, AddonTable = ...

-- Initialize shared variables
AddonTable.friendsFrame = nil
AddonTable.classLookup = {}
AddonTable.tempFontString = nil

local function initTinyFriends()
    --Build a lookup table to so I can get the localization independent class name.
    -- Note: on Classic clients GetNumClasses() returns the count of available classes (e.g. 9),
    -- but class IDs are sparse (Druid is 11), so iterating 1..GetNumClasses() misses classes.
    AddonTable.classLookup = {}
    local function addNames(tbl)
        if not tbl then return end
        for classFile, localizedName in pairs(tbl) do
            AddonTable.classLookup[localizedName] = classFile
        end
    end
    addNames(LOCALIZED_CLASS_NAMES_MALE)
    addNames(LOCALIZED_CLASS_NAMES_FEMALE)
    for i = 1, math.max(GetNumClasses() or 0, 20) do
        local localizedName, classLocalizationIndependent = GetClassInfo(i)
        if localizedName and classLocalizationIndependent then
            AddonTable.classLookup[localizedName] = classLocalizationIndependent
        end
    end
    -- Load persisted sort settings
    AddonTable.wowFriendsSort = {
        order = BrokerTinyFriendsDB.wowSortOrder or "name",
        ascending = BrokerTinyFriendsDB.wowSortAscending
    }
    if AddonTable.wowFriendsSort.ascending == nil then AddonTable.wowFriendsSort.ascending = true end
    AddonTable.otherFriendsSort = {
        order = BrokerTinyFriendsDB.otherSortOrder or "name",
        ascending = BrokerTinyFriendsDB.otherSortAscending
    }
    if AddonTable.otherFriendsSort.ascending == nil then AddonTable.otherFriendsSort.ascending = true end
    AddonTable.wowFriends = {}
    AddonTable.otherFriends = {}
    AddonTable.tempFontString = BrokerTinyFriends:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    C_FriendList.ShowFriends()
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        AddonTable.initSettings()
        AddonTable.initBroker()
        initTinyFriends()
        AddonTable.initOptionsPanel()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local scaleMult = BrokerTinyFriendsDB and BrokerTinyFriendsDB.scale or 1
        self:SetScale(UIParent:GetScale() * scaleMult)
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
