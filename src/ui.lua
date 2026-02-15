-- UI and frame creation

local addonName, AddonTable = ...

local function openWhisper(targetName)
    if not targetName or targetName == "" then return end
    if ChatFrameUtil and ChatFrameUtil.SendTell then
        ChatFrameUtil.SendTell(targetName)
    else
        ChatFrame_OpenChat("/w " .. targetName .. " ")
    end
end

local function openBNetWhisper(friend)
    if ChatFrameUtil and ChatFrameUtil.SendBNetTell then
        ChatFrameUtil.SendBNetTell(friend.accountName)
    elseif ChatFrame_SendBNetTell then
        ChatFrame_SendBNetTell(friend.accountName)
    else
        openWhisper(friend.characterName or friend.name or friend.accountName or "")
    end
end

local function anchorFriendsFrame(ldbObject)
    local isTop = select(2, ldbObject:GetCenter()) > UIParent:GetHeight() / 2
    AddonTable.friendsFrame:ClearAllPoints()
    AddonTable.friendsFrame:SetPoint(isTop and "TOP" or "BOTTOM", ldbObject, isTop and "BOTTOM" or "TOP", 0, 0)
end

local function showFriendsList(ldbObject)
    -- Store LDB object reference for refreshing
    AddonTable.currentLDBObject = ldbObject

    if AddonTable.friendsFrame then
        AddonTable.friendsFrame:Hide()
        AddonTable.friendsFrame:SetParent(nil)
        AddonTable.friendsFrame = nil
    end

    local function sortByHeader(self, button, friendList)
        if friendList == "wow" then
            if AddonTable.wowFriendsSort.order == self.sortType then
                AddonTable.wowFriendsSort.ascending = not AddonTable.wowFriendsSort.ascending
            else
                AddonTable.wowFriendsSort.order = self.sortType
                AddonTable.wowFriendsSort.ascending = true
            end
            AddonTable.sortFriends(AddonTable.wowFriends, "wow")
        else -- "other"
            if AddonTable.otherFriendsSort.order == self.sortType then
                AddonTable.otherFriendsSort.ascending = not AddonTable.otherFriendsSort.ascending
            else
                AddonTable.otherFriendsSort.order = self.sortType
                AddonTable.otherFriendsSort.ascending = true
            end
            AddonTable.sortFriends(AddonTable.otherFriends, "other")
        end

        showFriendsList(ldbObject)
    end

    AddonTable.sortFriends(AddonTable.wowFriends, "wow")
    AddonTable.sortFriends(AddonTable.otherFriends, "other")

    local function createHeader(parentFrame, horizontalPosition, text, sortType, friendList)
        local sortData = friendList == "wow" and AddonTable.wowFriendsSort or AddonTable.otherFriendsSort
        local header = CreateFrame("Button", nil, parentFrame)
        local headerText = header:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", horizontalPosition, -10)
        header:RegisterForClicks("LeftButtonUp")
        headerText:SetPoint("LEFT", 0, 0)
        headerText:SetText(text)
        header.sortType = sortType
        header:SetScript("OnClick", function(self, button)
            sortByHeader(self, button, friendList)
        end)

        local arrow = header:CreateTexture(nil, "ARTWORK")
        arrow:SetAtlas("auctionhouse-ui-sortarrow")
        arrow:SetSize(9, 9)
        arrow:SetPoint("LEFT", headerText, "RIGHT", 3, 0)

        if sortData.order == sortType then
            arrow:Show()
            if sortData.ascending then
                arrow:SetTexCoord(0, 1, 1, 0)
            else
                arrow:SetTexCoord(0, 1, 0, 1)
            end
        else
            arrow:Hide()
        end

        header:SetSize(headerText:GetStringWidth() + 20, 15)
        return header
    end

    local headerPadding = 10
    local nameHorizontalPosition = 10
    local factionHorizontalPosition = AddonTable.nameMaxWidth
    local levelHorizontalPosition = factionHorizontalPosition + 40 + 10
    local clientHorizontalPosition = levelHorizontalPosition + AddonTable.levelMaxWidth + 10
    local presenceHorizontalPosition = clientHorizontalPosition + 30 + 10
    local noteHorizontalPosition = presenceHorizontalPosition + 10 + AddonTable.presenceMaxWidth

    local nameHorizontalPositionOther = 10
    local clientHorizontalPositionOther = AddonTable.nameMaxWidthOther
    local presenceHorizontalPositionOther = clientHorizontalPositionOther + AddonTable.clientMaxWidthOther + 10

    local verticalOffset = 25
    local verticalIncrement = 15
    local horizontalOffset = 15

    local wowFriendsHeight = #AddonTable.wowFriends * verticalIncrement + 40
    local otherFriendsHeight = math.ceil(#AddonTable.otherFriends / 2) * verticalIncrement + 30

    local panelWidthWow = noteHorizontalPosition + AddonTable.noteMaxWidth + 30
    local panelWidthOther = (presenceHorizontalPositionOther + AddonTable.presenceMaxWidthOther) + 30

    local totalWidth = max(panelWidthOther * 2, panelWidthWow)

    local headerAreaHeight = 10
    local footerHeight = 30
    local contentHeight = wowFriendsHeight + 10 + otherFriendsHeight
    local scrollbarWidth = 16
    local maxScrollArea = (UIParent:GetHeight() * 0.6) - headerAreaHeight - footerHeight
    local needsScroll = contentHeight > maxScrollArea
    local scrollAreaHeight = needsScroll and maxScrollArea or contentHeight

    if needsScroll then
        totalWidth = totalWidth + scrollbarWidth
    end

    local totalHeight = headerAreaHeight + scrollAreaHeight + footerHeight

    AddonTable.friendsFrame = CreateFrame("Frame", nil, BrokerTinyFriends, "TooltipBorderedFrameTemplate")
    AddonTable.friendsFrame:SetFrameStrata("HIGH")
    AddonTable.friendsFrame:SetSize(totalWidth + headerPadding, totalHeight)

    local opacity = (BrokerTinyFriendsDB and BrokerTinyFriendsDB.backgroundOpacity) or 0.8
    AddonTable.friendsFrame:SetBackdropColor(0, 0, 0, opacity)

    local scrollFrame = CreateFrame("ScrollFrame", nil, AddonTable.friendsFrame)
    scrollFrame:SetPoint("TOPLEFT", 0, -headerAreaHeight)
    scrollFrame:SetPoint("TOPRIGHT", needsScroll and -scrollbarWidth or 0, -headerAreaHeight)
    scrollFrame:SetHeight(scrollAreaHeight)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(totalWidth - (needsScroll and scrollbarWidth or 0))
    scrollChild:SetHeight(contentHeight)
    scrollFrame:SetScrollChild(scrollChild)

    if needsScroll then
        local scrollbar = CreateFrame("Slider", nil, AddonTable.friendsFrame)
        scrollbar:SetPoint("TOPRIGHT", -4, -headerAreaHeight)
        scrollbar:SetPoint("BOTTOMRIGHT", -4, footerHeight)
        scrollbar:SetWidth(scrollbarWidth)
        scrollbar:SetMinMaxValues(0, contentHeight - scrollAreaHeight)
        scrollbar:SetValueStep(verticalIncrement)
        scrollbar:SetObeyStepOnDrag(true)
        scrollbar:SetValue(0)

        local thumbTexture = scrollbar:CreateTexture(nil, "ARTWORK")
        thumbTexture:SetColorTexture(0.5, 0.5, 0.5, 0.7)
        thumbTexture:SetSize(scrollbarWidth - 4, 40)
        scrollbar:SetThumbTexture(thumbTexture)

        scrollbar:SetScript("OnValueChanged", function(self, value)
            scrollFrame:SetVerticalScroll(value)
        end)

        scrollFrame:EnableMouseWheel(true)
        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local current = scrollbar:GetValue()
            local step = verticalIncrement * 3
            scrollbar:SetValue(current - (delta * step))
        end)
    end

    -- WoW Friends Frame
    local wowFriendsFrame = CreateFrame("Frame", nil, scrollChild)
    wowFriendsFrame:SetPoint("TOPLEFT", 0, 0)
    wowFriendsFrame:SetSize(panelWidthWow + headerPadding, wowFriendsHeight)

    -- Headers for WoW friends
    createHeader(wowFriendsFrame, nameHorizontalPosition + headerPadding, "Name", "name", "wow")
    createHeader(wowFriendsFrame, factionHorizontalPosition + headerPadding, "Faction", "faction", "wow")
    createHeader(wowFriendsFrame, levelHorizontalPosition + headerPadding, "Level", "level", "wow")
    createHeader(wowFriendsFrame, clientHorizontalPosition + headerPadding, "Client", "client", "wow")
    createHeader(wowFriendsFrame, presenceHorizontalPosition + headerPadding, "Presence", "presence", "wow")
    createHeader(wowFriendsFrame, noteHorizontalPosition + headerPadding, "Note", "note", "wow")

    -- Other Friends Frame
    local otherFriendsFrame = CreateFrame("Frame", nil, scrollChild)
    otherFriendsFrame:SetPoint("TOPLEFT", 0, -(wowFriendsHeight + 10))
    otherFriendsFrame:SetSize(panelWidthOther * 2 + headerPadding + 10, otherFriendsHeight)

    -- Headers for Other friends
    createHeader(otherFriendsFrame, nameHorizontalPositionOther + headerPadding, "Name", "name", "other")
    createHeader(otherFriendsFrame, clientHorizontalPositionOther + headerPadding, "Client", "client", "other")
    createHeader(otherFriendsFrame, presenceHorizontalPositionOther + headerPadding, "Presence", "presence", "other")

    -- Add a delimiter between the friend sections
    local horizontalDelimiter = scrollChild:CreateTexture(nil, "ARTWORK")
    horizontalDelimiter:SetTexture("Interface\\Buttons\\WHITE8X8")
    horizontalDelimiter:SetVertexColor(0.5, 0.5, 0.5, 1)
    horizontalDelimiter:SetPoint("TOPLEFT", 10, -wowFriendsHeight)
    horizontalDelimiter:SetSize(totalWidth - 10, 1)

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
        local rowWidth = scrollChild:GetWidth() - (2 * horizontalOffset)
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
        if friend.timerunningSeasonID then
            friendName = AddonTable.addTimerunningIcon(friendName)
        end
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
                    openBNetWhisper(friend)
                else
                    openWhisper(friend.name)
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
        clientIcon:SetPoint("LEFT", AddonTable.nameMaxWidthOther, 0)
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
                openBNetWhisper(friend)
            end
        end)

        if i == halfOtherFriends then
            currentColumn = 2
            otherVerticalOffset = 25 -verticalIncrement
        end

        otherVerticalOffset = otherVerticalOffset + verticalIncrement
    end

    local footer = CreateFrame("Frame", nil, AddonTable.friendsFrame)
    footer:SetPoint("BOTTOMLEFT", AddonTable.friendsFrame, "BOTTOMLEFT", 10, 10)
    footer:SetPoint("BOTTOMRIGHT", AddonTable.friendsFrame, "BOTTOMRIGHT", -10, 10)
    footer:SetHeight(20)

    local footerHint = footer:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    footerHint:SetPoint("LEFT")
    footerHint:SetText("|cFFAAAAAALeft-Click to whisper | Right-Click to invite|r")

    local optionsButton = CreateFrame("Button", nil, footer)
    optionsButton:SetPoint("RIGHT")
    optionsButton:SetSize(60, 20)

    local optionsText = optionsButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    optionsText:SetPoint("CENTER")
    optionsText:SetText("Options")
    optionsText:SetJustifyH("RIGHT")

    -- Add mouseover handlers
    optionsButton:SetScript("OnEnter", function()
        AddonTable.cancelHideTimer()
    end)

    optionsButton:SetScript("OnLeave", function()
        AddonTable.scheduleHide()
    end)

    -- Open Settings panel on click
    -- Works with both Modern Settings API and Legacy Interface Options
    optionsButton:SetScript("OnClick", function(self, button)
        if Settings and AddonTable.settingsCategory then
            Settings.OpenToCategory(AddonTable.settingsCategory.ID)
        elseif AddonTable.optionsPanel then
            InterfaceOptionsFrame_OpenToCategory(AddonTable.optionsPanel)
        elseif InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory("TinyFriends")
        end
    end)

    AddonTable.cancelHideTimer()
    AddonTable.friendsFrame:Show()
    AddonTable.friendsFrame:SetClampedToScreen(true)

    anchorFriendsFrame(ldbObject)

    AddonTable.friendsFrame:HookScript("OnEnter", function()
        AddonTable.cancelHideTimer()
        GameTooltip:Show()
    end)

    AddonTable.friendsFrame:HookScript("OnLeave", function()
        AddonTable.scheduleHide()
    end)

    AddonTable.friendsFrame:HookScript("OnHide", function()
        AddonTable.cancelHideTimer()
    end)
end

-- Export functions to AddonTable
AddonTable.anchorFriendsFrame = anchorFriendsFrame
AddonTable.showFriendsList = showFriendsList
