# autoloads/economy_system.gd
# Phase 0/1 stub. Full supply/demand + price fluctuation logic coming in Phase 1.
# Currently provides basic price lookup + a manual tick for testing.

extends Node

var _prices: Dictionary = {}  # city_id -> { good_id: price }
var _initialized := false


func _ready() -> void:
	_initialize_stub_prices()
	_initialized = true
	print("[EconomySystem] Stub prices initialized (Phase 0).")


func _initialize_stub_prices() -> void:
	# Hardcoded reasonable starting prices for MVP testing
	var cities := ["tyr", "urik", "balic", "gulg", "nibenay"]
	var goods := ["bloodglass", "sunsteel", "agafari", "ambergrain", "veil_figs",
				  "brine", "sting_nectar", "duneweave", "mekillot", "ghostroot"]

	var base := {
		"bloodglass": 45,
		"sunsteel": 320,
		"agafari": 95,
		"ambergrain": 22,
		"veil_figs": 55,
		"brine": 28,
		"sting_nectar": 70,
		"duneweave": 35,
		"mekillot": 62,
		"ghostroot": 95,
	}

	for city in cities:
		_prices[city] = {}
		for good in goods:
			var variation := randf_range(0.85, 1.25)
			_prices[city][good] = int(base[good] * variation)


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
