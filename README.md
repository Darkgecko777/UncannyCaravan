# Uncanny Caravan

A focused desert trading + intrigue game.

Buy on knowledge. Risk the journey. Convert an information edge into profit before rival houses, bandits, or the desert itself close the gap.

## Current State (Phase 0)

This is a cleaned foundation after the initial prototype pass.

- Core systems exist (state, economy stubs, caravan stubs, save/load).
- UI is intentionally simple and hierarchical so the mood can breathe.
- Debug tools are present but no longer dominate the main view.
- Resolution is 960×540 with integer scaling (clean 2× to 1920×1080).

## Running

Open in Godot 4.6+ and press F5.

Use the Tools panel (right side) to exercise the loop:
- Add goods / cash
- Force a market tick
- Dispatch a test caravan
- Force save or simulate offline time

Close the window to auto-save.

## Design Intent

- UI-driven core loop with a supporting map layer later.
- Scarcity, risk, and information as the real currency.
- Mirrored fantasy setting (not a direct adaptation).
- Finishable scope: single region, limited cities and goods, real tension in every dispatch.

See `docs/` for style and architecture notes.
