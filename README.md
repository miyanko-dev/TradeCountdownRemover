# TradeCountdownRemover

Skips the trade countdown. When you press **Trade**, the addon presses it again three times
in quick succession, so the trade goes through without the wait.

## Features

- Hooks the native Trade button, no extra UI and no configuration
- Replays the click 3 times at 0.15s steps after your own click
- Guarded so the replayed clicks never trigger another replay round
- Works on Classic Era, Anniversary, Wrath, Cata and Mists from one `.toc`

## Installation

1. Copy the `TradeCountdownRemover/` folder into:
   `World of Warcraft/_classic_era_/Interface/AddOns/`
2. Restart the game or `/reload`.
3. Enable **Trade Countdown Remover** in the AddOns list.

## Usage

Open a trade and press **Trade** once. Nothing else to do.

## Notes

Replaces the `TRADE_SHOW` WeakAura that did the same thing. Disable that aura when you install
this addon, otherwise both fire and the button gets clicked six times.
