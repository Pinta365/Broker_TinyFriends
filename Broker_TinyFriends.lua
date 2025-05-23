local addonName, AddonTable = ...
local friendsFrame
local classLookup
local tempFontString

local nameMaxWidth
local levelMaxWidth
local presenceMaxWidth
local noteMaxWidth
local nameMaxWidthOther
local clientMaxWidthOther
local presenceMaxWidthOther

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

local function updateFriendsList()
    local wowFriends = {}
    local otherFriends = {}
    local addedWowFriendNames = {}
    
    -- Battle.net Friends
    local numBNetTotal = BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        local gameInfo = accountInfo and accountInfo.gameAccountInfo
        if accountInfo and gameInfo then

            local battleTag = accountInfo.battleTag
            local findHashtag = battleTag and string.find(battleTag, "#")
            local name
            if findHashtag then
                name = string.sub(battleTag, 1, findHashtag - 1)
            end

            if gameInfo.isOnline then
                if gameInfo.clientProgram == "WoW" then
                    local friend = {
                        name = name,
                        accountName = accountInfo.accountName,
                        note = accountInfo.note,
                        isAFK = accountInfo.isAFK or gameInfo.isGameAFK,
                        isDND = accountInfo.isDND or gameInfo.isGameBusy,
                        gameAccountID = gameInfo.gameAccountID,
                        playerGuid = gameInfo.playerGuid,
                        wowProjectID = gameInfo.wowProjectID,
                        factionName = gameInfo.factionName,
                        clientProgram = gameInfo.clientProgram,
                        characterName = gameInfo.characterName,
                        className = gameInfo.className,
                        classLocalizationIndependent = classLookup[gameInfo.className],
                        characterLevel = gameInfo.characterLevel,
                        realmName = gameInfo.realmName,
                        richPresence = gameInfo.richPresence,
                        isBNetFriend = true,
                    }
                    table.insert(wowFriends, friend)
                    if gameInfo.characterName then
                        addedWowFriendNames[gameInfo.characterName] = true
                    end

                else
                    local friend = {
                        name = name,
                        accountName = accountInfo.accountName,
                        isAFK = accountInfo.isAFK or gameInfo.isGameAFK,
                        isDND = accountInfo.isDND or gameInfo.isGameBusy,
                        clientProgram = gameInfo.clientProgram,
                        clientName = clientList[gameInfo.clientProgram] or nil,
                        richPresence = gameInfo.richPresence,
                        isBNetFriend = true,
                    }
                    table.insert(otherFriends, friend)
                end
            end
        end
    end

    -- Regular wow in-game friends
    local numRegularFriends = C_FriendList.GetNumFriends()
    for i = 1, numRegularFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.connected then
            local friendName = friendInfo.name
            local findDash = friendName and string.find(friendName, "-")
            if findDash then
                friendName = string.sub(friendName, 1, findDash - 1)
            end

            --Adding if we don't already have the player on Bnet friend
            if not addedWowFriendNames[friendName] then
                local friend = {
                    name = friendInfo.name,
                    accountName = nil,
                    note = friendInfo.notes,
                    isAFK = friendInfo.afk,
                    isDND = friendInfo.dnd,
                    gameAccountID = nil, 
                    playerGuid = friendInfo.guid,
                    wowProjectID = nil,
                    factionName = nil,
                    clientProgram = "WoW",
                    characterName = friendName,
                    className = friendInfo.className,
                    classLocalizationIndependent = classLookup and classLookup[friendInfo.className] or nil,
                    characterLevel = friendInfo.level,
                    realmName = nil,
                    richPresence = friendInfo.area,
                    isBNetFriend = false
                }
                table.insert(wowFriends, friend)
            end
        end
    end
  
    if AddonTable.wowFriends then
        wipe(AddonTable.wowFriends)
    end

    if AddonTable.otherFriends then
        wipe(AddonTable.otherFriends)
    end

    --Default column widths
    nameMaxWidth = 50
    levelMaxWidth = 20
    presenceMaxWidth = 35
    noteMaxWidth = 50
    nameMaxWidthOther = 50
    clientMaxWidthOther = 20
    presenceMaxWidthOther = 35

    for _, wowFriend in ipairs(wowFriends) do
        table.insert(AddonTable.wowFriends, wowFriend)

        if wowFriend.name and wowFriend.characterName then
            tempFontString:SetText(wowFriend.name .. " ("..wowFriend.characterName..")")
            nameMaxWidth = max(nameMaxWidth, tempFontString:GetStringWidth())
        end
        if wowFriend.characterLevel then
            tempFontString:SetText(tostring(wowFriend.characterLevel))
            levelMaxWidth = max(levelMaxWidth, tempFontString:GetStringWidth())
        end
        if wowFriend.richPresence then
            tempFontString:SetText(wowFriend.richPresence)
            presenceMaxWidth = max(presenceMaxWidth, tempFontString:GetStringWidth())
        end
        if wowFriend.note then
            tempFontString:SetText(wowFriend.note)
            noteMaxWidth = max(noteMaxWidth, tempFontString:GetStringWidth())
        end

        if wowFriend.factionName == "Alliance" then
            wowFriend.factionIcon = "Interface\\FriendsFrame\\PlusManz-Alliance.blp"
        elseif wowFriend.factionName == "Horde" then
            wowFriend.factionIcon = "Interface\\FriendsFrame\\PlusManz-Horde.blp"
        else
            wowFriend.factionIcon = nil
        end

    end

    for _, otherFriend in ipairs(otherFriends) do
        table.insert(AddonTable.otherFriends, otherFriend)
        if otherFriend.name then
            tempFontString:SetText(otherFriend.name)
            nameMaxWidthOther = max(nameMaxWidthOther, tempFontString:GetStringWidth())
        end
        if otherFriend.richPresence then
            tempFontString:SetText(otherFriend.richPresence)
            presenceMaxWidthOther = max(presenceMaxWidthOther, tempFontString:GetStringWidth())
        end

    end

    -- Add a padding.
    nameMaxWidth = nameMaxWidth + 15
    levelMaxWidth = levelMaxWidth + 15
    presenceMaxWidth = presenceMaxWidth + 15
    nameMaxWidthOther = nameMaxWidthOther + 15
    clientMaxWidthOther = clientMaxWidthOther + 15
    presenceMaxWidthOther = presenceMaxWidthOther + 15

    return #wowFriends, #otherFriends
end

local function anchorFriendsFrame(ldbObject)
    local isTop = select(2, ldbObject:GetCenter()) > UIParent:GetHeight() / 2
    friendsFrame:ClearAllPoints()
    friendsFrame:SetPoint(isTop and "TOP" or "BOTTOM", ldbObject, isTop and "BOTTOM" or "TOP", 0, 0)
end

local function sortFriends(friends, friendList)
    local sortData = friendList == "wow" and AddonTable.wowFriendsSort or AddonTable.otherFriendsSort
    if sortData.order then
        local sortKey = sortData.order
        if sortKey == "level" then
            sortKey = "characterLevel"
        elseif sortKey == "presence" then
            sortKey = "richPresence"
        elseif sortKey == "note" then 
            sortKey = "note"
        elseif sortKey == "client" then
            sortKey = friendList == "wow" and "wowProjectID" or "clientName"
        elseif sortKey == "faction" then
            sortKey = "factionName"
        else
            sortKey = "name"
        end

        table.sort(friends, function(a, b)
            if sortData.ascending then
                return string.lower(a[sortKey] or "") < string.lower(b[sortKey] or "")
            else
                return string.lower(a[sortKey] or "") > string.lower(b[sortKey] or "")
            end
        end)
    end
end
local function showFriendsList(ldbObject)
    if friendsFrame then
        friendsFrame:Hide()
        friendsFrame:SetParent(nil)
        friendsFrame = nil
    end

    local function sortByHeader(self, button, friendList)
        if friendList == "wow" then 
            if AddonTable.wowFriendsSort.order == self.sortType then
                AddonTable.wowFriendsSort.ascending = not AddonTable.wowFriendsSort.ascending
            else
                AddonTable.wowFriendsSort.order = self.sortType
                AddonTable.wowFriendsSort.ascending = true
            end
            sortFriends(AddonTable.wowFriends, "wow")
        else -- "other"
            if AddonTable.otherFriendsSort.order == self.sortType then
                AddonTable.otherFriendsSort.ascending = not AddonTable.otherFriendsSort.ascending
            else
                AddonTable.otherFriendsSort.order = self.sortType
                AddonTable.otherFriendsSort.ascending = true
            end
            sortFriends(AddonTable.otherFriends, "other")
        end
        
        showFriendsList(ldbObject)
    end
    
    local function createHeader(parentFrame, horizontalPosition, text, sortType, friendList)
        local header = CreateFrame("Button", nil, parentFrame)
        local headerText = header:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", horizontalPosition, -10)
        header:RegisterForClicks("LeftButtonUp")
        headerText:SetPoint("LEFT", 0, 0)
        headerText:SetText(text)
        header:SetSize(headerText:GetStringWidth() + 10, 15)
        header.sortType = sortType
        header:SetScript("OnClick", function(self, button)
            sortByHeader(self, button, friendList)
        end)
        return header
    end

    local headerPadding = 10
    local nameHorizontalPosition = 10
    local factionHorizontalPosition = nameMaxWidth
    local levelHorizontalPosition = factionHorizontalPosition + 40 + 10
    local clientHorizontalPosition = levelHorizontalPosition + levelMaxWidth + 10
    local presenceHorizontalPosition = clientHorizontalPosition + 30 + 10
    local noteHorizontalPosition = presenceHorizontalPosition + 10 + presenceMaxWidth

    local nameHorizontalPositionOther = 10
    local clientHorizontalPositionOther = nameMaxWidthOther
    local presenceHorizontalPositionOther = clientHorizontalPositionOther + clientMaxWidthOther + 10

    local verticalOffset = 25
    local verticalIncrement = 15
    local horizontalOffset = 15

    local wowFriendsHeight = #AddonTable.wowFriends * verticalIncrement + 20
    local otherFriendsHeight = (#AddonTable.otherFriends / 2) * verticalIncrement + 20

    local panelWidthWow = noteHorizontalPosition + noteMaxWidth + 30
    local panelWidthOther = (presenceHorizontalPositionOther + presenceMaxWidthOther) + 30

    local totalHeight = wowFriendsHeight + otherFriendsHeight + verticalOffset + verticalIncrement + 60
    local totalWidth = max(panelWidthOther * 2, panelWidthWow)
    friendsFrame = CreateFrame("Frame", nil, UIParent, "TooltipBorderedFrameTemplate")
    friendsFrame:SetFrameStrata("HIGH")
    friendsFrame:SetSize(totalWidth + headerPadding, totalHeight)

    -- WoW Friends Frame
    local wowFriendsFrame = CreateFrame("Frame", nil, friendsFrame)
    wowFriendsFrame:SetPoint("TOPLEFT", 0, -(verticalOffset))
    wowFriendsFrame:SetSize(panelWidthWow + headerPadding, wowFriendsHeight)

    -- Headers for WoW friends
    createHeader(wowFriendsFrame, nameHorizontalPosition + headerPadding, "Name", "name", "wow")
    createHeader(wowFriendsFrame, factionHorizontalPosition + headerPadding, "Faction", "faction", "wow")
    createHeader(wowFriendsFrame, levelHorizontalPosition + headerPadding, "Level", "level", "wow")
    createHeader(wowFriendsFrame, clientHorizontalPosition + headerPadding, "Client", "client", "wow")
    createHeader(wowFriendsFrame, presenceHorizontalPosition + headerPadding, "Presence", "presence", "wow")
    createHeader(wowFriendsFrame, noteHorizontalPosition + headerPadding, "Note", "note", "wow")

    -- Other Friends Frame
    local otherFriendsFrame = CreateFrame("Frame", nil, friendsFrame)
    otherFriendsFrame:SetPoint("TOPLEFT", 0, -((verticalOffset*2)+wowFriendsHeight))
    otherFriendsFrame:SetSize(panelWidthOther * 2 + headerPadding + 10, otherFriendsHeight)

    -- Headers for Other friends (adjust positions as needed)
    createHeader(otherFriendsFrame, nameHorizontalPositionOther + headerPadding, "Name", "name", "other")
    createHeader(otherFriendsFrame, clientHorizontalPositionOther + headerPadding, "Client", "client", "other")
    createHeader(otherFriendsFrame, presenceHorizontalPositionOther + headerPadding, "Presence", "presence", "other") 

    -- Add a delimiter between the friend sections
    local horizontalDelimiter = wowFriendsFrame:CreateTexture(nil, "ARTWORK")
    horizontalDelimiter:SetTexture("Interface\\Buttons\\WHITE8X8")
    horizontalDelimiter:SetVertexColor(0.5, 0.5, 0.5, 1)
    horizontalDelimiter:SetPoint("TOPLEFT", 10, -(verticalOffset+wowFriendsHeight))
    horizontalDelimiter:SetSize(totalWidth-10, 1)

    -- Add a delimiter between the other friends columns
    local verticalDelimiter = otherFriendsFrame:CreateTexture(nil, "ARTWORK")
    verticalDelimiter:SetTexture("Interface\\Buttons\\WHITE8X8")
    verticalDelimiter:SetVertexColor(0.5, 0.5, 0.5, 1)
    verticalDelimiter:SetPoint("TOPLEFT", panelWidthOther + horizontalOffset, -10)
    verticalDelimiter:SetSize(1, otherFriendsHeight)

    -- Duplicate headers on the right column
    createHeader(otherFriendsFrame, panelWidthOther + 20 + nameHorizontalPositionOther + headerPadding, "Name", "name", "other")
    createHeader(otherFriendsFrame, panelWidthOther + 20 + clientHorizontalPositionOther + headerPadding, "Client", "client", "other")
    createHeader(otherFriendsFrame, panelWidthOther + 20 + presenceHorizontalPositionOther + headerPadding, "Presence", "presence", "other") 

    -- 1. Online WoW Friends
    local wowVerticalOffset = 25
    for i, friend in ipairs(AddonTable.wowFriends) do

        local friendFrame = CreateFrame("Button", nil, wowFriendsFrame)
        friendFrame:SetPoint("TOPLEFT", horizontalOffset, -wowVerticalOffset)
        local rowWidth = friendsFrame:GetWidth() - (2 * horizontalOffset)
        friendFrame:SetSize(rowWidth, 15)
        friendFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        if friend.isAFK or friend.isBusy then
            local statusIcon = friendFrame:CreateTexture(nil, "ARTWORK")
            statusIcon:SetPoint("LEFT", nameHorizontalPosition - 15, 0)
            statusIcon:SetSize(15, 15)
            if friend.isAFK then
                statusIcon:SetTexture(FRIENDS_TEXTURE_AFK)
            else
                statusIcon:SetTexture(FRIENDS_TEXTURE_DND)
            end
        end

        local nameText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        nameText:SetPoint("LEFT", nameHorizontalPosition, 0)
        friendFrame.nameText = nameText

        local factionIcon = friendFrame:CreateTexture(nil, "ARTWORK")
        factionIcon:SetPoint("LEFT", factionHorizontalPosition, 0)
        factionIcon:SetSize(15, 15)
        if friend.factionIcon then
            factionIcon:SetTexture(friend.factionIcon)
        end

        local levelText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        levelText:SetPoint("LEFT", levelHorizontalPosition, 0)
        friendFrame.levelText = levelText

        local clientIcon = friendFrame:CreateTexture(nil, "ARTWORK")
        clientIcon:SetPoint("LEFT", clientHorizontalPosition, 0)
        clientIcon:SetSize(15, 15)
        C_Texture.SetTitleIconTexture(clientIcon, friend.clientProgram, Enum.TitleIconVersion.Small);

        local fadeIcon = (friend.clientProgram == BNET_CLIENT_WOW) and (friend.wowProjectID ~= WOW_PROJECT_ID);
        if fadeIcon then
            clientIcon:SetAlpha(0.4);
        else
            clientIcon:SetAlpha(1);
        end

        local presenceText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        presenceText:SetPoint("LEFT", presenceHorizontalPosition, 0)
        friendFrame.presenceText = presenceText

        local noteText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        noteText:SetPoint("LEFT", noteHorizontalPosition, 0)
        friendFrame.noteText = noteText

        if friend.classLocalizationIndependent then
            local classColor = RAID_CLASS_COLORS[friend.classLocalizationIndependent]
            if classColor then
                nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
            end
        end

        if i % 2 == 0 then
            local bgTexture = friendFrame:CreateTexture(nil, "BACKGROUND")
            bgTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
            bgTexture:SetVertexColor(0, 0, 0, 0.2)
            bgTexture:SetAllPoints(friendFrame)
        end

        local friendName = friend.name

        if UnitInParty(friendName) or UnitInRaid(friendName) then
            friendName = "*" .. friendName
        end

        if #friend.characterName > 0 and friend.isBNetFriend then
            nameText:SetText(friendName .. " (" .. friend.characterName .. ")")
        else
            nameText:SetText(friendName)
        end
        levelText:SetText(friend.characterLevel)
        presenceText:SetText(friend.richPresence)
        noteText:SetText(friend.note)

        local highlight = friendFrame:CreateTexture(nil, "BACKGROUND")
        highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        highlight:SetVertexColor(0.2, 0.2, 0.2, 1)
        highlight:SetAllPoints(friendFrame)
        highlight:Hide()
        friendFrame.highlight = highlight

        friendFrame:SetScript("OnEnter", function(self)
            self.highlight:Show()
        end)

        friendFrame:SetScript("OnLeave", function(self)
            self.highlight:Hide()
        end)

        friendFrame:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                if friend.isBNetFriend then
                    ChatFrame_SendBNetTell(friend.accountName)
                else
                    ChatFrame_SendTell(friend.name)
                end
            elseif button == "RightButton" then
                FriendsFrame_InviteOrRequestToJoin(friend.playerGuid, friend.gameAccountID);
            end
        end)

        wowVerticalOffset = wowVerticalOffset + verticalIncrement
    end

    -- 2. Online Other Friends
    local otherVerticalOffset = 25
    local currentColumn = 1

    local totalOtherFriends = #AddonTable.otherFriends
    local halfOtherFriends = math.ceil(totalOtherFriends / 2)

    for i = 1, totalOtherFriends do
        local friend = AddonTable.otherFriends[i] 
        local friendFrame = CreateFrame("Button", nil, otherFriendsFrame)

        local column1HorizontalPosition = horizontalOffset  
        local column2HorizontalPosition = horizontalOffset + panelWidthOther + 20

        local horizontalPosition = currentColumn == 1 and column1HorizontalPosition or column2HorizontalPosition

        friendFrame:SetPoint("TOPLEFT", horizontalPosition, -otherVerticalOffset)
        friendFrame:SetSize(panelWidthOther, 15)
        friendFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        if friend.isAFK or friend.isDND then
            local statusIcon = friendFrame:CreateTexture(nil, "ARTWORK")
            statusIcon:SetPoint("LEFT", nameHorizontalPosition - 15, 0)
            statusIcon:SetSize(15, 15)
            if friend.isAFK then
                statusIcon:SetTexture(FRIENDS_TEXTURE_AFK)
            else
                statusIcon:SetTexture(FRIENDS_TEXTURE_DND)
            end
        end

        local nameText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        nameText:SetPoint("LEFT", nameHorizontalPosition, 0)
        friendFrame.nameText = nameText

        local clientIcon = friendFrame:CreateTexture(nil, "ARTWORK")
        clientIcon:SetPoint("LEFT", nameMaxWidthOther, 0)
        clientIcon:SetSize(15, 15)
        C_Texture.SetTitleIconTexture(clientIcon, friend.clientProgram, Enum.TitleIconVersion.Small);

        -- Add tooltip to client icon
        clientIcon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(friend.clientName or friend.clientProgram)
            GameTooltip:Show()
        end)

        clientIcon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        local presenceText = friendFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        presenceText:SetPoint("LEFT", presenceHorizontalPositionOther, 0)
        friendFrame.presenceText = presenceText

        nameText:SetText(WrapTextInColorCode(friend.name, "FF00FFF6"))
        if (friend.richPresence == "" or friend.richPresence == nil) and friend.clientProgram == "BSAp" then
            friend.richPresence = "In Mobile App"
        end
        presenceText:SetText(friend.richPresence)

        local highlight = friendFrame:CreateTexture(nil, "BACKGROUND")
        highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        highlight:SetVertexColor(0.2, 0.2, 0.2, 1)
        highlight:SetAllPoints(friendFrame)
        highlight:Hide()
        friendFrame.highlight = highlight

        friendFrame:SetScript("OnEnter", function(self)
            self.highlight:Show()
        end)

        friendFrame:SetScript("OnLeave", function(self)
            self.highlight:Hide()
        end)

        friendFrame:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                ChatFrame_SendBNetTell(friend.accountName)
            end
        end)

        if i == halfOtherFriends then 
            currentColumn = 2
            otherVerticalOffset = 25 -verticalIncrement
        end

        otherVerticalOffset = otherVerticalOffset + verticalIncrement
    end

    local footerText = friendsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    footerText:SetPoint("BOTTOMRIGHT", friendsFrame, "BOTTOMRIGHT", -10, 10)
    footerText:SetText("|cFFAAAAAALeft-Click to whisper | Right-Click to invite|r")
    footerText:SetJustifyH("RIGHT")
    friendsFrame.footerText = footerText

    friendsFrame:Show()
    friendsFrame:SetClampedToScreen(true)

    anchorFriendsFrame(ldbObject)

    friendsFrame:HookScript("OnEnter", function()
        GameTooltip:Show()
    end)

    friendsFrame:HookScript("OnLeave", function()
        if not friendsFrame:IsMouseOver() and not GameTooltip:IsMouseOver() then
            C_Timer.After(0.1, function()
                if not friendsFrame:IsMouseOver() and
                    not GameTooltip:IsMouseOver() then
                    friendsFrame:Hide()
                end
            end)
        end
    end)
end

local function initBroker()
    local LDB = LibStub("LibDataBroker-1.1")
    AddonTable.BrokerTinyFriends = LDB:NewDataObject("Broker_TinyFriends", {
        type = "data source",
        text = "TinyFriends Loading",
        icon = "Interface\\AddOns\\KeystoneRoulette\\Textures\\pinta",

        OnClick = function(self, button)
            ToggleFriendsFrame(1)
        end,

        OnEnter = function(self)
            if #AddonTable.wowFriends > 0 or #AddonTable.otherFriends > 0 then                
                showFriendsList(self)
            end
        end,

        OnLeave = function(self)
            if friendsFrame and not friendsFrame:IsMouseOver() then
                friendsFrame:Hide()
            end
        end,
    })
end

local function updateBrokerText()
    --delayed throttling so we always got the latest data but after short delay to prevent spamming and resource hogging.
    if not AddonTable.friendsListUpdateTimer then
        AddonTable.friendsListUpdateTimer = C_Timer.NewTimer(4, function()
            local numWowFriends, _ = updateFriendsList()
            AddonTable.BrokerTinyFriends.text = string.format(WrapTextInColorCode("%s:", "FF00FFF6") .. " %d Online", "Friends", numWowFriends)
            AddonTable.friendsListUpdateTimer = nil
        end)
    end
end

local function initTinyFriends()
    --Build a lookup table to so I can get the localization independent class name.
    classLookup = {}
    for i = 1, GetNumClasses() do
        local localizedName, classLocalizationIndependent, _ = GetClassInfo(i)
        classLookup[localizedName] = classLocalizationIndependent
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
    tempFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    C_FriendList.ShowFriends()
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        initTinyFriends()
        initBroker()
    elseif event == "PLAYER_ENTERING_WORLD" then
        updateBrokerText()
    elseif event == "FRIENDLIST_UPDATE" or
        event == "BN_FRIEND_ACCOUNT_ONLINE" or
        event == "BN_FRIEND_ACCOUNT_OFFLINE" or
        event == "BN_FRIEND_INFO_CHANGED" then
        updateBrokerText()
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