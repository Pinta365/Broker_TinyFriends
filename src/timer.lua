-- Timer management for mouseover system

local addonName, AddonTable = ...

local hideTimer

local function cancelHideTimer()
    if hideTimer then
        hideTimer:Cancel()
        hideTimer = nil
    end
end

local function scheduleHide()
    cancelHideTimer()
    hideTimer = C_Timer.NewTimer(0.2, function()
        if AddonTable.friendsFrame and AddonTable.friendsFrame:IsShown() then
            local isOverFrame = AddonTable.friendsFrame:IsMouseOver()
            
            if not isOverFrame then
                AddonTable.friendsFrame:Hide()
            end
        end
        hideTimer = nil
    end)
end

-- Export functions to AddonTable
AddonTable.cancelHideTimer = cancelHideTimer
AddonTable.scheduleHide = scheduleHide

