# autoloads/caravan_system.gd
# Phase 0/2 stub. Full dispatch, travel, events, and offline advancement in Phase 2+.
# Provides just enough for SaveSystem and basic UI testing.

extends Node

var _next_id := 0


func _ready() -> void:
	print("[CaravanSystem] Stub ready (Phase 0). Full logic in Phase 2.")


func dispatch_caravan(route_id: String, cargo: Dictionary, guard_level: int) -> String:
	# Very minimal stub — deducts goods immediately (proper behavior for Phase 1+)
	var id := "c_" + str(Time.get_unix_time_from_system() as int) + "_" + str(_next_id)
	_next_id += 1

	# Actually remove the cargo from inventory now (fixes previous leak)
	for good_id_variant in cargo:
		var good_id: String = good_id_variant as String
		var qty: int = cargo[good_id]
		GameState.remove_goods(good_id, qty)

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
	get_tree().create_timer(3.0).timeout.connect(func(): resolve_caravan(id, true))

	return id


# Public API — used by UI and internal timer. is_debug = true keeps fake profit/events for now.
func resolve_caravan(caravan_id: String, is_debug: bool = false) -> void:
	if not has_active_caravan(caravan_id):
		return

	var caravan := get_caravan(caravan_id)
	var profit := 180 + randi_range(-40, 90)  # Fake for stub
	var events := ["Sandstorm slowed the caravan slightly."]

	if not is_debug:
		# Real profit calculation will go here in Phase 2
		pass

	# Sell the cargo at destination (stub uses "urik" prices)
	for good_id_variant in caravan.get("cargo", {}):
		var good_id: String = good_id_variant as String
		var qty: int = caravan.cargo[good_id]
		var sell_price: int = EconomySystem.get_sell_price("urik", good_id)
		GameState.add_cash(sell_price * qty)

	GameState.remove_active_caravan(caravan_id)
	SignalBus.caravan_resolved.emit(caravan_id, profit, events, profit)
	print("[CaravanSystem] Caravan resolved: ", caravan_id, " (debug=", is_debug, ")")


func has_active_caravan(caravan_id: String) -> bool:
	for c_variant in GameState.get_active_caravans():
		var c: Dictionary = c_variant
		if c.get("id") == caravan_id:
			return true
	return false


func get_caravan(caravan_id: String) -> Dictionary:
	for c_variant in GameState.get_active_caravans():
		var c: Dictionary = c_variant
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
