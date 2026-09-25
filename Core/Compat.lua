local _, ns = ...

local CONFIRM_EVENT = "SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT"
local CANCEL_EVENT = "SECURE_TRANSFER_CANCEL"

-- Feature tests, never interface numbers: a new flavor ships without a code change as
-- long as it raises the same events, and a flavor that drops them disables the addon
local function isEventValid(event)
    if not C_EventUtils or not C_EventUtils.IsEventValid then return false end

    return C_EventUtils.IsEventValid(event) and true or false
end

-- The single place in the addon that asks the client anything. Core/Unlock.lua is
-- written against these flags alone, so supporting another version is one edit here.
ns.compat = {
    confirmEvent = CONFIRM_EVENT,
    cancelEvent = CANCEL_EVENT,

    -- Both 1.15.9 and 1.60.1 ship a byte-identical Blizzard_SecureTransferUI, so the
    -- countdown and the way to clear it are the same on either client
    hasConfirmDialog = isEventValid(CONFIRM_EVENT),
    hasCancelEvent = isEventValid(CANCEL_EVENT),

    -- AcceptTrade is an undocumented FrameXML global with no entry in the generated
    -- API docs, so its presence is tested rather than assumed
    canRequestAccept = type(AcceptTrade) == "function",
}
