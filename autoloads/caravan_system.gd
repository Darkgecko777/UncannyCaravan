# autoloads/caravan_system.gd
# Phase 0/2 stub. Full dispatch, travel, events, and offline advancement in Phase 2+.
# Provides just enough for SaveSystem and basic UI testing.

extends Node

var _next_id := 0


func _ready() -> void:
	print("[CaravanSystem] Stub ready (Phase 0). Full logic in Phase 2.")


func dispatch_caravan(route_id: String, cargo: Dictionary, guard_level: int) -> String:
	# Very minimal stub — just creates an "instant" caravan for testing
	var id := "c_" + str(Time.get_unix_time_from_system() as int) + "_" + str(_next_id)
	_next_id += 1

	var caravan := {
		"id": id,
		"route_id": route_id,
		"departure_unix": Time.get_unix_time_from_system(),
		"eta_unix": Time.get_unix_time_from_system() + 45.0,  # 45s for quick testing
		"cargo": cargo.duplicate(),
		"guard_level": guard_level,
		"progress": 0.0,
	}

	GameState.add_active_caravan(caravan)
	SignalBus.caravan_dispatched.emit(id, route_id, cargo)

	# Auto-resolve after short delay for Phase 0 testing (remove in Phase 2)
	get_tree().create_timer(3.0).timeout.connect(func(): _auto_resolve_stub(id))

	return id


func _auto_resolve_stub(caravan_id: String) -> void:
	if not has_active_caravan(caravan_id):
		return

	var caravan := get_caravan(caravan_id)
	var profit := 180 + randi_range(-40, 90)  # Fake profit
	var events := ["Sandstorm slowed the caravan slightly."]

	# Fake sell the cargo for testing
	for good_id in caravan.get("cargo", {}):
		var qty: int = caravan.cargo[good_id]
		GameState.add_cash(EconomySystem.get_sell_price("urik", good_id) * qty)
		GameState.remove_goods(good_id, qty)  # already removed at dispatch normally

	GameState.remove_active_caravan(caravan_id)
	SignalBus.caravan_resolved.emit(caravan_id, profit, events, profit)
	print("[CaravanSystem] Stub caravan resolved: ", caravan_id)


func has_active_caravan(caravan_id: String) -> bool:
	for c in GameState.get_active_caravans():
		if c.get("id") == caravan_id:
			return true
	return false


func get_caravan(caravan_id: String) -> Dictionary:
	for c in GameState.get_active_caravans():
		if c.get("id") == caravan_id:
			return c
	return {}


func advance_offline(seconds: float) -> Dictionary:
	# Phase 0: Do nothing complex. In Phase 3 this will advance all active caravans,
	# resolve those that arrived during absence, roll events, etc.
	print("[CaravanSystem] Offline advance stub: %.0f seconds (no caravan sim yet)" % seconds)
	return {
		"caravans_resolved": 0,
		"total_profit": 0,
		"notes": "Full offline simulation coming in Phase 3"
	}


func get_all_active() -> Array[Dictionary]:
	return GameState.get_active_caravans().duplicate(true)
