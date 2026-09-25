local _, ns = ...

local compat = ns.compat

if not compat.hasConfirmDialog or not compat.canRequestAccept then return end

-- One re-request already clears the countdown; the second only covers a re-raise the
-- client chose to drop. The cap is what terminates the sequence, because every accept
-- raises a fresh confirmation that lands straight back in this handler.
local MAX_REQUESTS = 2

-- A confirmation arriving after this much silence cannot have been caused by us, so it
-- belongs to a new Trade press and the budget starts over. Nothing else re-arms, which
-- is why the sequence cannot sustain itself: once the cap is hit we stop sending, no
-- further confirmation arrives, and the addon goes idle until the player acts again.
local REQUEST_WINDOW = 1.0

local requestsMade = 0
local lastRequest = 0
local tradeOpen = false

-- The countdown lives on SecureTransferDialog, declared inside
-- <ScopedModifier forbidden="true">, so an addon can never reach its Accept button.
-- It can only be cleared sideways: SecureTransferDialog_Show ends in Button1:Enable()
-- followed by a Show() that is a no-op while the dialog is already up, so OnShow never
-- fires and SecureTransferDialog_TimerOnAccept never starts a second three second ticker.
local function sendAccept()
    if not tradeOpen then return end

    AcceptTrade()
end

local function requestConfirmAgain()
    local now = GetTime()
    if now - lastRequest > REQUEST_WINDOW then
        requestsMade = 0
    end

    if requestsMade >= MAX_REQUESTS then return end

    requestsMade = requestsMade + 1
    lastRequest = now

    -- Deferred one frame so Blizzard's own handler has shown the dialog first. Calling
    -- inside the synchronous event would make the outcome depend on which frame the
    -- client happens to dispatch to first.
    C_Timer.After(0, sendAccept)
end

local function onEvent(_, event, playerAccepted)
    if event == compat.confirmEvent then
        requestConfirmAgain()
    elseif event == "TRADE_ACCEPT_UPDATE" then
        -- The accept is committed, so a further request would only reopen a dialog for
        -- a trade that is already through
        if playerAccepted == 1 then
            requestsMade = MAX_REQUESTS
        end
    elseif event == compat.cancelEvent then
        requestsMade = MAX_REQUESTS
    elseif event == "TRADE_SHOW" then
        tradeOpen = true
        requestsMade = 0
    elseif event == "TRADE_CLOSED" then
        tradeOpen = false
    end
end

local listener = CreateFrame("Frame")
listener:RegisterEvent("TRADE_SHOW")
listener:RegisterEvent("TRADE_CLOSED")
listener:RegisterEvent("TRADE_ACCEPT_UPDATE")

-- Catching the confirmation rather than the Trade button covers macro and keybind
-- accepts too, and keeps TradeFrameTradeButton out of the addon entirely; that frame is
-- the one part of the trade UI Blizzard builds from a different file per flavor.
listener:RegisterEvent(compat.confirmEvent)

if compat.hasCancelEvent then
    listener:RegisterEvent(compat.cancelEvent)
end

listener:SetScript("OnEvent", onEvent)
