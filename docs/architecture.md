# Architecture Notes — Uncanny Caravan

## High-Level Shape

```
SignalBus          ← central event bus (loose coupling)
GameState          ← pure mutable player state + signals
DataRegistry       ← loads all static .tres data
EconomySystem      ← prices, market pressure, ticks
CaravanSystem      ← dispatch, travel, resolution, loss tracking
SaveSystem         ← JSON persistence + offline hand-off
```

UI listens to SignalBus and reads from GameState / systems.  
Systems never reach into UI nodes.

## Locked Economic & Agency Model (August 2026)

### Settlements
- Fixed economic roles. No growth or new resource unlocking.
- All goods exist from the start.
- Output and conditions fluctuate via event/pressure layer.
- Settlements are the stable board; they are not active optimizers.

### Merchant Houses
- Primary dynamic agents (player + rivals).
- Same fundamental constraints: caravans, risk, incomplete information.
- Structural advantage only through merchant means (reputation, intel coverage, soft leverage).

### Pricing
- Base prices grounded in map facts (distance from source, route danger, standing friction).
- Short-term movement from actual scarcity/glut and discrete events.
- Long-term production ≈ consumption so the region tends to wash out.

### Information
- Detailed city/village stock is not free.
- Reliable knowledge generally requires an agent in or near the location.
- Agent quality and placement affect report accuracy and freshness.
- Espionage is a primary generator of the specialized knowledge the core fantasy needs.

### Lost Goods & Salvage
- Caravans tracked through discrete zones.
- Lost cargo enters a temporary held state (bandits/scavengers).
- Passive re-introduction returns goods to the local economy over time.
- Intelligence can enable active recovery before full recirculation.

### Agents
- Roles + traits + textual personality are sufficient.
- Unique portraits are not required; generic icons differentiated by role/house are acceptable.
- Rival houses also run agents; the information war is mutual.

## Scene Philosophy

- `scenes/main/main.tscn` is a thin shell: header, content slots, tools, log.
- Real gameplay panels will live under `scenes/ui/panels/` as the game grows.
- Debug / tools remain available but visually secondary.

## Resolution

960×540 logical with integer scaling.  
Design every panel and margin as if it will be viewed at 2× (1920×1080).  
This keeps pixel art crisp while forcing density discipline.

## Next Natural Steps

1. Replace placeholder panels with proper Inventory / Market / Caravan / Intel views.
2. Introduce a simple 9-slice frame and limited palette theming.
3. Lock the first vertical slice (4–5 cities, ~8 goods, core routes, basic agent actions).
4. Move from stub caravan resolution to actual risk, loss tracking, and salvage hooks.
5. Give rival houses minimal but noticeable decision loops.

The systems layer is already more solid than the early presentation layer.  
Design decisions above keep complexity concentrated on merchant-house agency and information edges.
