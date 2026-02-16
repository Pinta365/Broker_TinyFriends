-- Broker initialization and text updates

local addonName, AddonTable = ...

local function initBroker()
    local LDB = LibStub("LibDataBroker-1.1")
    AddonTable.BrokerTinyFriends = LDB:NewDataObject("Broker_TinyFriends", {
        type = "data source",
        text = "TinyFriends Loading",
        icon = "Interface\\AddOns\\KeystoneRoulette\\Textures\\pinta",

        OnClick = function(self, button)
            ToggleFriendsFrame()
        end,

        OnEnter = function(self)
            AddonTable.cancelHideTimer()
            if #AddonTable.wowFriends > 0 or #AddonTable.otherFriends > 0 then                
                AddonTable.showFriendsList(self)
            end
        end,

        OnLeave = function(self)
            AddonTable.scheduleHide()
        end,
    })
end

local function updateBrokerText()
    --delayed throttling so we always got the latest data but after short delay to prevent spamming and resource hogging.
    if not AddonTable.friendsListUpdateTimer then
        AddonTable.friendsListUpdateTimer = C_Timer.NewTimer(4, function()
            local numWowFriends, _ = AddonTable.updateFriendsList()
            AddonTable.BrokerTinyFriends.text = string.format(WrapTextInColorCode("%s:", "FF00FFF6") .. " %d Online", "Friends", numWowFriends)
            AddonTable.friendsListUpdateTimer = nil
        end)
    end
end

-- Export functions to AddonTable
AddonTable.initBroker = initBroker
AddonTable.updateBrokerText = updateBrokerText

