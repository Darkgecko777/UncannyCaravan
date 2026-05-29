# autoloads/economy_system.gd
# Real (simple) supply/demand driven price model for Athas markets.
# Prices are derived from TradeGoodData.base_price + city signature/scarce modifiers
# + runtime virtual_supply pressure (player trades + random shocks + slow regeneration).

extends Node

var _prices: Dictionary = {}           # city_id -> { good_id: current_price }
var _virtual_supply: Dictionary = {}   # city_id -> { good_id: pressure }  (higher = more supply = lower future prices)
var _initialized := false

const SUPPLY_SENSITIVITY := 0.018      # how strongly player sales move prices
const REGEN_PER_TICK := 0.8            # slow natural regeneration of supply pressure per market tick


func _ready() -> void:
	_load_or_initialize_prices()
	_initialized = true
	print("[EconomySystem] Real economy model active with %d cities." % _prices.size())


func _load_or_initialize_prices() -> void:
	# Prefer persisted current prices
	if GameState.economy_prices and not GameState.economy_prices.is_empty():
		_prices = GameState.economy_prices.duplicate(true)
		# Also restore virtual supply if we ever persist it (future-proof)
		print("[EconomySystem] Loaded persisted prices from save.")
	else:
		_initialize_from_data_registry()

	# Always initialize virtual supply (lightweight runtime state)
	_initialize_virtual_supply()


func _initialize_from_data_registry() -> void:
	if not DataRegistry.is_loaded():
		# Fallback if registry not ready yet (shouldn't happen with autoload order)
		_initialize_minimal_fallback()
		return

	var city_ids: Array[String] = DataRegistry.get_all_city_ids()
	var good_ids: Array[String] = DataRegistry.get_all_good_ids()

	for city_id: String in city_ids:
		_prices[city_id] = {}
		for good_id: String in good_ids:
			var good: TradeGoodData = DataRegistry.get_good(good_id)
			var city: CityData = DataRegistry.get_city(city_id)
			var price := float(good.base_price)

			# Lore-driven city modifiers (signature goods cheaper, scarce goods more expensive)
			if city and good_id in city.signature_goods:
				price *= 0.82
			elif city and good_id in city.scarce_goods:
				price *= 1.28

			_prices[city_id][good_id] = int(max(3, price))

	_persist_prices()
	print("[EconomySystem] Initialized prices from DataRegistry + CityData modifiers.")


func _initialize_minimal_fallback() -> void:
	# Last-resort deterministic values (should rarely be reached)
	var cities: Array[String] = ["tyr", "urik", "balic", "gulg", "nibenay"]
	var goods: Array[String] = DataRegistry.get_all_good_ids()
	if goods.is_empty():
		goods = ["bloodglass", "sunsteel", "agafari", "ambergrain", "veil_figs",
				"brine", "sting_nectar", "duneweave", "mekillot", "ghostroot"] as Array[String]

	for city: String in cities:
		_prices[city] = {}
		for g: String in goods:
			_prices[city][g] = 50

	_persist_prices()


func _initialize_virtual_supply() -> void:
	_virtual_supply.clear()
	for city_id in _prices:
		_virtual_supply[city_id] = {}
		for good_id in _prices[city_id]:
			_virtual_supply[city_id][good_id] = 0.0  # neutral starting pressure


func get_sell_price(city_id: String, good_id: String) -> int:
	if not _prices.has(city_id) or not _prices[city_id].has(good_id):
		return 10

	var base: float = float(_prices[city_id][good_id])
	var supply_pressure: float = _virtual_supply.get(city_id, {}).get(good_id, 0.0) as float

	# Simple but effective supply/demand model
	# High virtual_supply (lots of recent sales into this market) → lower prices
	var adjusted: float = base * (1.0 - supply_pressure * SUPPLY_SENSITIVITY)
	return int(max(3.0, adjusted))


func get_buy_price(city_id: String, good_id: String) -> int:
	return int(get_sell_price(city_id, good_id) * 0.92)


func force_market_tick() -> void:
	# Apply slow natural regeneration + light noise (feels alive without wild swings)
	for city_id in _prices:
		for good_id in _prices[city_id]:
			# Regeneration toward equilibrium
			var sp: float = _virtual_supply[city_id].get(good_id, 0.0) as float
			sp = sp * (1.0 - REGEN_PER_TICK * 0.05) + randf_range(-0.6, 0.6)
			_virtual_supply[city_id][good_id] = clamp(sp, -8.0, 18.0)

			# Tiny random walk on displayed price (sentiment)
			var p := float(_prices[city_id][good_id])
			p *= 1.0 + randf_range(-0.03, 0.03)
			_prices[city_id][good_id] = int(max(3, p))

		SignalBus.prices_updated.emit(city_id)

	_persist_prices()
	print("[EconomySystem] Market tick + supply regeneration applied.")


func get_all_prices_for_city(city_id: String) -> Dictionary:
	return _prices.get(city_id, {}).duplicate()


# Called when a caravan sells goods into a city (increases local supply → future prices drop)
func apply_trade_impact(city_id: String, good_id: String, qty: int, is_sell: bool) -> void:
	if not _prices.has(city_id) or not _prices[city_id].has(good_id):
		return

	var pressure_delta: float = qty * (0.035 if is_sell else -0.022)
	_virtual_supply[city_id][good_id] = _virtual_supply[city_id].get(good_id, 0.0) + pressure_delta

	# Immediate small price reaction for feedback
	var current: float = float(_prices[city_id][good_id])
	var immediate: float = 0.008 if is_sell else -0.006
	_prices[city_id][good_id] = int(max(3.0, current * (1.0 + immediate * qty)))

	SignalBus.prices_updated.emit(city_id)
	_persist_prices()


func _persist_prices() -> void:
	GameState.economy_prices = _prices.duplicate(true)


# Helper for future UI / debug
func get_virtual_supply(city_id: String, good_id: String) -> float:
	return _virtual_supply.get(city_id, {}).get(good_id, 0.0)
