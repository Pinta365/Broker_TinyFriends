-- Data management functions

local addonName, AddonTable = ...

local function addTimerunningIcon(name)
    if name and name ~= "" then
        return "|TInterface\\AddOns\\Broker_TinyFriends\\Textures\\timerunning-glues-icon-small.png:9:9|t" .. name
    end
    return name
end

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
                        classLocalizationIndependent = AddonTable.classLookup[gameInfo.className],
                        characterLevel = gameInfo.characterLevel,
                        realmName = gameInfo.realmName,
                        richPresence = gameInfo.richPresence,
                        isBNetFriend = true,
                        timerunningSeasonID = gameInfo.timerunningSeasonID,
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
                        clientName = AddonTable.clientList[gameInfo.clientProgram] or nil,
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
                    classLocalizationIndependent = AddonTable.classLookup and AddonTable.classLookup[friendInfo.className] or nil,
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
    local nameMaxWidth = 50
    local levelMaxWidth = 20
    local presenceMaxWidth = 35
    local noteMaxWidth = 50
    local nameMaxWidthOther = 50
    local clientMaxWidthOther = 20
    local presenceMaxWidthOther = 35

    for _, wowFriend in ipairs(wowFriends) do
        table.insert(AddonTable.wowFriends, wowFriend)

        if wowFriend.name and wowFriend.characterName then
            AddonTable.tempFontString:SetText(wowFriend.name .. " ("..wowFriend.characterName..")")
            nameMaxWidth = max(nameMaxWidth, AddonTable.tempFontString:GetStringWidth())
        end
        if wowFriend.characterLevel then
            AddonTable.tempFontString:SetText(tostring(wowFriend.characterLevel))
            levelMaxWidth = max(levelMaxWidth, AddonTable.tempFontString:GetStringWidth())
        end
        if wowFriend.richPresence then
            AddonTable.tempFontString:SetText(wowFriend.richPresence)
            presenceMaxWidth = max(presenceMaxWidth, AddonTable.tempFontString:GetStringWidth())
        end
        if wowFriend.note then
            AddonTable.tempFontString:SetText(wowFriend.note)
            noteMaxWidth = max(noteMaxWidth, AddonTable.tempFontString:GetStringWidth())
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
            AddonTable.tempFontString:SetText(otherFriend.name)
            nameMaxWidthOther = max(nameMaxWidthOther, AddonTable.tempFontString:GetStringWidth())
        end
        if otherFriend.richPresence then
            AddonTable.tempFontString:SetText(otherFriend.richPresence)
            presenceMaxWidthOther = max(presenceMaxWidthOther, AddonTable.tempFontString:GetStringWidth())
        end

    end

    -- Add a padding.
    nameMaxWidth = nameMaxWidth + 15
    levelMaxWidth = levelMaxWidth + 15
    presenceMaxWidth = presenceMaxWidth + 15
    nameMaxWidthOther = nameMaxWidthOther + 15
    clientMaxWidthOther = clientMaxWidthOther + 15
    presenceMaxWidthOther = presenceMaxWidthOther + 15

    -- Store widths in AddonTable
    AddonTable.nameMaxWidth = nameMaxWidth
    AddonTable.levelMaxWidth = levelMaxWidth
    AddonTable.presenceMaxWidth = presenceMaxWidth
    AddonTable.noteMaxWidth = noteMaxWidth
    AddonTable.nameMaxWidthOther = nameMaxWidthOther
    AddonTable.clientMaxWidthOther = clientMaxWidthOther
    AddonTable.presenceMaxWidthOther = presenceMaxWidthOther

    return #wowFriends, #otherFriends
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

-- Export functions to AddonTable
AddonTable.addTimerunningIcon = addTimerunningIcon
AddonTable.updateFriendsList = updateFriendsList
AddonTable.sortFriends = sortFriends

