# TradeCountdownRemover

## Target

- WoW Forever 1.60.x only, `## Interface: 16001`. No client branches, no `WOW_PROJECT_*`, no compat layer.
- `main` holds the Forever version. `1.15.x-backup` stays untouched.
- Verify every API against Gethe `wow-ui-source` and Ketho `BlizzardInterfaceResources`, branch `forever`.

## Rules

- `SecureTransferDialog` is forbidden to addons (`<ScopedModifier forbidden="true">` in `Blizzard_SecureTransferUI.xml`), so its Accept button stays out of reach.
- The countdown is skipped sideways. On `SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT` the addon calls `AcceptTrade()` once more on the next frame. The re-raised `SecureTransferDialog_Show` ends in `Button1:Enable()` and a `Show()` that fires no OnShow on a visible frame, so the `CONFIRM_TRADE.onShow` handler `SecureTransferDialog_TimerOnAccept` starts no second timer.
- At most 2 re-requests per press, and a confirmation after 1 s of quiet counts as a new press. The cap ends the loop, since every accept raises a fresh confirmation. `TRADE_ACCEPT_UPDATE` with `playerAccepted == 1` and `SECURE_TRANSFER_CANCEL` stop it early.
- `TRADE_ACCEPT_UPDATE` passes `playerAccepted` as a number (`TradeInfoDocumentation.lua`), so test `== 1`, never truthiness.
- Call the global `AcceptTrade`. `C_SecureTransfer.AcceptTrade` is `HasRestrictions = true` (`SecureTransferDocumentation.lua`).

## Checks

- Run `luac -p` on every Lua file after a change. The repo has no test harness.
- Turn on `/console scriptErrors 1` before testing in game.
