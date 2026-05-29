# autoloads/signal_bus.gd
# Central event bus for loose coupling between systems and UI.
# All important game events should emit here so UI and other systems can react without direct references.

extends Node

# Economy & Inventory
signal cash_changed(new_amount: int)
signal inventory_changed(good_id: String, new_amount: int, delta: int)
signal prices_updated(city_id: String)

# Caravans
signal caravan_dispatched(caravan_id: String, route_id: String, cargo: Dictionary)
signal caravan_resolved(caravan_id: String, profit: int, events: Array, final_cargo_value: int)
signal active_caravans_changed()

# Progression
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal reputation_changed(faction_id: String, new_level: int)

# Save / Session
signal game_loaded()
signal game_saved()
signal offline_progress_applied(seconds_offline: float, summary: Dictionary)

# Debug / Dev
signal debug_action_triggered(action: String)
