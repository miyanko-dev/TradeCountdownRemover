# TradeCountdownRemover — Memory

Updated 2026-09-30 after the Forever-only audit. The owner's decision now is WoW Forever 1.60.x only: `main` drops everything that exists only for Classic, and a `1.15.x-backup` branch keeps the Classic version. This supersedes the 2026-09-25 decision that every addon supports both clients. The audit verified against Gethe `forever` @ `966519cf` (1.60.1.70124) and Ketho `forever` @ `4149af64` (1.60.1.70009). The installed client is 1.60.1.70009. Nothing has run in a client yet.

## Current state

Skips the three-second countdown on the trade confirmation dialog. No UI, no saved variables.

| Item | State |
|---|---|
| Working tree | 2.0.0, Forever only: `## Interface: 16001`, `## Category: Social`, one file `Core/Unlock.lua` |
| Git | `main` holds 2.0.0 (committed 2026-09-30, not pushed). `1.15.x-backup` = `d7f8c50` (dual-client 1.2.0, the last commit that supports 1.15.x) is on GitHub. Older Classic builds sit in its history: 1.0.0 at `b547903` replays the Trade click |

How it works:

- `SecureTransferDialog` is forbidden to addons (`<ScopedModifier forbidden="true">` in `Blizzard_SecureTransferUI.xml`).
- On `SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT`, the addon calls `AcceptTrade()` once more on the next frame. The re-raised `SecureTransferDialog_Show` ends in `Button1:Enable()` and a `Show()` that doesn't fire OnShow on a visible frame, so no second timer starts. Verified on Forever: `Blizzard_SecureTransferUI.lua`, with `CONFIRM_TRADE.onShow = SecureTransferDialog_TimerOnAccept`.
- It sends at most 2 re-requests per press. `TRADE_ACCEPT_UPDATE(1)` and `SECURE_TRANSFER_CANCEL` stop it.

Verified on Forever: all five events are in `Events.lua`, `AcceptTrade` is in `GlobalAPI.lua`, and `TRADE_ACCEPT_UPDATE.playerAccepted` is a `number` (`TradeInfoDocumentation.lua`), so the `== 1` test is correct.

## Forever-only rework (done 2026-09-30)

- TCR-1: `## Interface: 16001` only, version 2.0.0, `## Category: Social`.
- TCR-2: `Core/Compat.lua` is deleted. `Unlock.lua` registers both events directly; they and `AcceptTrade` always exist on Forever.
- TCR-3: the README is Forever only.
- TCR-4: `1.15.x-backup` was created at `d7f8c50` and pushed.

Nothing else was needed: the event gating, the re-request cap and window, and the deferred send are unchanged. The addon has no UI panel.

## Blockers, issues, challenges

1. The mechanism is unproven in a client: does a second `AcceptTrade()` raise the confirmation again? If it doesn't, the addon quietly does nothing.
2. `AcceptTrade` has no restriction annotation, so calling it from a `C_Timer` callback without a hardware event is convention, not proof. By contrast, `C_SecureTransfer.AcceptTrade` is `HasRestrictions = true` (`SecureTransferDocumentation.lua`).
3. Known Blizzard behaviour: the old ticker keeps rewriting the label (`2`, `1`, `ACCEPT`), but the button stays clickable. Mail's stranger countdown is left alone on purpose.

## Next steps

1. Review and push `main` (2.0.0).
2. Run `/console scriptErrors 1` first in game.

Forever checks:

- [ ] The addon list shows it, not out of date.
- [ ] Open a trade, add an item and press **Trade** once: **Accept** is clickable at once. This settles issue 1.
- [ ] Log the events with a temporary frame. Two or more confirm events per press mean the mechanism works.
- [ ] No `ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` for the addon. This settles issue 2.
- [ ] Accept via `/run AcceptTrade()` and via a keybind: same result.
- [ ] Cancel the dialog and press Trade again: skipped again. When the partner changes the offer, no dialog reopens.
- [ ] Mail gold to a stranger: the full countdown stays.
