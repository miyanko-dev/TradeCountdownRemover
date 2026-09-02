local CLICKS = 3
local STEP = 0.15

local function replay(btn)
    if btn.tcrReplay then return end
    btn.tcrReplay = true
    for i = 1, CLICKS do
        C_Timer.After(STEP * i, function() btn:Click() end)
    end
    -- Release the guard after the last replay click has fired
    C_Timer.After(STEP * CLICKS + 0.25, function() btn.tcrReplay = nil end)
end

local function hook()
    local btn = TradeFrameTradeButton
    if not btn or btn.tcrHooked then return end
    btn.tcrHooked = true
    btn:HookScript("OnClick", replay)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("TRADE_SHOW")
f:SetScript("OnEvent", hook)
