# TradeCountdownRemover — Memory

Updated 2026-09-25 after the dual-client port (decision: every addon in the folder supports both clients). Verified against Gethe `forever` @ `bd2470a` (1.60.1.70009), Gethe `classic_era` @ `33e177d` (1.15.9.69722) and the matching Ketho dumps. Nothing has run in a client.

## Current state

Skips the three-second countdown on the trade confirmation dialog. No UI, no saved variables.

| Item | State |
|---|---|
| Working tree | 1.2.0, both clients from one toc, `## Interface: 11509, 16001`, `## Author: miyanko`. `_Vanilla.toc` is removed, because one toc now serves both |
| Git | Committed and pushed on 2026-09-25: `main` = `origin/main`. GitHub's README restructure was merged with the local README and toc kept. The previous release is 1.0.0 at `b547903`, a flat file that replays the Trade click |

How it works:

- `SecureTransferDialog` is forbidden to addons.
- On `SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT`, the addon calls `AcceptTrade()` once more on the next frame. The re-raised `SecureTransferDialog_Show` re-enables Button1, and the frame is already visible, so no second timer starts.
- It sends at most 2 re-requests per press. `TRADE_ACCEPT_UPDATE(1)` and `SECURE_TRANSFER_CANCEL` stop it.

There are no client branches:

- `Blizzard_SecureTransferUI.lua` and `.xml` are byte-identical on both clients.
- The events and `AcceptTrade` exist on both.
- `Core/Compat.lua` does feature tests only.

## Blockers, issues, challenges

1. The mechanism is unproven on any client: does a second `AcceptTrade()` raise the confirmation again? If it doesn't, the addon quietly does nothing.
2. `AcceptTrade` has no restriction annotation, so calling it from a `C_Timer` callback without a hardware event is convention, not proof. By contrast, `C_SecureTransfer.AcceptTrade` is `HasRestrictions = true`.
3. The multi-value `## Interface: 11509, 16001` line is proven only by third-party addons (Auctionator, QuestieDB), not by the UI source.
4. There's no `_classic_era_` install. The installed beta is 69913, the source is 70009. A test needs a second character.
5. Known Blizzard behaviour: the old ticker keeps rewriting the label (`2`, `1`, `ACCEPT`), but the button stays clickable. Mail's stranger countdown is left alone on purpose.

## Next steps

1. Run `/console scriptErrors 1` first on both clients.

Both clients:

- [ ] The addon list shows 1.2.0 and not out of date. This proves the dual Interface line.
- [ ] `/dump C_EventUtils.IsEventValid("SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT"), type(AcceptTrade)` prints `true function`.
- [ ] Open a trade, add an item and press **Trade** once: **Accept** is clickable at once. This settles issue 1.
- [ ] Log the events with a temporary frame. Two or more confirm events per press mean the mechanism works.
- [ ] No `ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` for the addon. This settles issue 2.
- [ ] Accept via `/run AcceptTrade()` and via a keybind: same result.
- [ ] Cancel the dialog and press Trade again: skipped again. When the partner changes the offer, no dialog reopens.
- [ ] Mail gold to a stranger: the full countdown stays.
