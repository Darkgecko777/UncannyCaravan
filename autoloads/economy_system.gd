# autoloads/economy_system.gd
# Phase 0/1 stub. Full supply/demand + price fluctuation logic coming in Phase 1.
# Currently provides basic price lookup + a manual tick for testing.

extends Node

var _prices: Dictionary = {}  # city_id -> { good_id: price }
var _initialized := false


func _ready() -> void:
	_load_or_initialize_prices()
	_initialized = true
	print("[EconomySystem] Prices ready (persisted where possible).")


func _load_or_initialize_prices() -> void:
	# Prefer persisted state from GameState (survives quit/relaunch)
	if GameState.economy_prices and not GameState.economy_prices.is_empty():
		_prices = GameState.economy_prices.duplicate(true)
		print("[EconomySystem] Loaded persisted prices from save.")
		return

	# First run or corrupted — seed from data (will be replaced by DataRegistry + TradeGoodData in Phase 1)
	_initialize_from_hardcoded_bases()


func _initialize_from_hardcoded_bases() -> void:
	var cities := ["tyr", "urik", "balic", "gulg", "nibenay"]
	var goods := ["bloodglass", "sunsteel", "agafari", "ambergrain", "veil_figs",
				  "brine", "sting_nectar", "duneweave", "mekillot", "ghostroot"]

	var base := {
		"bloodglass": 45, "sunsteel": 320, "agafari": 95, "ambergrain": 22,
		"veil_figs": 55, "brine": 28, "sting_nectar": 70, "duneweave": 35,
		"mekillot": 62, "ghostroot": 95,
	}

	for city in cities:
		_prices[city] = {}
		for good in goods:
			_prices[city][good] = base[good]  # deterministic starting point

	# Persist immediately
	GameState.economy_prices = _prices.duplicate(true)


func get_sell_price(city_id: String, good_id: String) -> int:
	if not _prices.has(city_id) or not _prices[city_id].has(good_id):
		return 10
	return _prices[city_id][good_id]


func get_buy_price(city_id: String, good_id: String) -> int:
	# Simple 8% spread for MVP
	return int(get_sell_price(city_id, good_id) * 0.92)


func force_market_tick() -> void:
	# Phase 0: tiny random walk for testing
	for city in _prices:
		for good in _prices[city]:
			var change := randf_range(-0.08, 0.08)
			_prices[city][good] = max(5, int(_prices[city][good] * (1.0 + change)))
		SignalBus.prices_updated.emit(city)

	_persist_prices()
	print("[EconomySystem] Market tick applied (stub).")


func get_all_prices_for_city(city_id: String) -> Dictionary:
	return _prices.get(city_id, {}).duplicate()


# Placeholder for full system — will be replaced in Phase 1
func apply_trade_impact(city_id: String, good_id: String, qty: int, is_sell: bool) -> void:
	# For now, just a small price nudge
	if not _prices.has(city_id) or not _prices[city_id].has(good_id):
		return
	var nudge := 0.015 if is_sell else -0.012
	_prices[city_id][good_id] = max(3, int(_prices[city_id][good_id] * (1.0 + nudge * sign(qty))))
	SignalBus.prices_updated.emit(city_id)
	_persist_prices()


func _persist_prices() -> void:
	GameState.economy_prices = _prices.duplicate(true)
