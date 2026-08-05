# Architecture Notes — Uncanny Caravan

## High-Level Shape

```
SignalBus          ← central event bus (loose coupling)
GameState          ← pure mutable player state + signals
DataRegistry       ← loads all static .tres data
EconomySystem      ← prices, market pressure, ticks
CaravanSystem      ← dispatch, travel, resolution (stub → real)
SaveSystem         ← JSON persistence + offline hand-off
```

UI listens to SignalBus and reads from GameState / systems.  
Systems never reach into UI nodes.

## Scene Philosophy

- `scenes/main/main.tscn` is a thin shell: header, content slots, tools, log.
- Real gameplay panels will live under `scenes/ui/panels/` as the game grows.
- Debug / tools are kept visible for now but visually secondary so the mood of the main view stays intact.

## Resolution

960×540 logical with integer scaling.  
Design every panel and margin as if it will be viewed at 2× (1920×1080).  
This keeps pixel art crisp while forcing density discipline.

## Next Natural Steps

1. Replace placeholder panels with proper Inventory / Market / Caravan views.
2. Introduce a simple 9-slice frame and limited palette theming.
3. Lock the first vertical slice (4–5 cities, ~8 goods, 1–2 real routes).
4. Move from stub caravan resolution to actual risk + profit calculation.

The systems layer is already more solid than the presentation layer was.  
This cleanup prioritizes clarity and mood so the next features land on a stable surface.
