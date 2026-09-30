# TradeCountdownRemover

Skips the three second countdown on the trade confirmation dialog. Press **Trade** once and the Accept button is immediately clickable.

## Features

- Press Trade once, nothing else to do
- Covers macro and keybind accepts as well as the Trade button
- No UI, no configuration, no saved variables
- Leaves the mail confirmation alone, so gold sent to a stranger keeps its warning

## Installation

1. Copy the `TradeCountdownRemover/` folder into the `Interface/AddOns/` folder of your WoW Forever install.
2. Restart the game or `/reload`.
3. Enable **Trade Countdown Remover** in the AddOns list.

## Requirements

WoW Forever 1.60.x (`## Interface: 16001`). Not yet tested in game.

The Classic Era 1.15.x version lives on the `1.15.x-backup` branch.

## Restrictions

If you used the `TRADE_SHOW` WeakAura that did the same thing, disable it. Otherwise both fire against the same dialog.
