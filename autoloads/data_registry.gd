# autoloads/data_registry.gd
# Central loader for all static game data (.tres files).
# Call DataRegistry.get_good("bloodglass") etc. from anywhere after _ready.
# This replaces all the duplicated hardcoded lists that were in Phase 0.

extends Node

var goods: Dictionary[String, TradeGoodData] = {}     # id -> TradeGoodData
var cities: Dictionary[String, CityData] = {}         # id -> CityData
var routes: Dictionary[String, TradeRouteData] = {}   # id -> TradeRouteData (Phase 2)

var _loaded := false


func _ready() -> void:
	_load_all_data()
	_loaded = true
	print("[DataRegistry] Loaded %d goods, %d cities." % [goods.size(), cities.size()])


func _load_all_data() -> void:
	# Goods — scan data/goods/
	var goods_dir := "res://data/goods/"
	var goods_files := DirAccess.get_files_at(goods_dir)
	for f in goods_files:
		if f.ends_with(".tres") or f.ends_with(".res"):
			var res: TradeGoodData = load(goods_dir + f) as TradeGoodData
			if res and res.id != "":
				goods[res.id] = res

	# Cities
	var cities_dir := "res://data/cities/"
	var city_files := DirAccess.get_files_at(cities_dir)
	for f in city_files:
		if f.ends_with(".tres") or f.ends_with(".res"):
			var res: CityData = load(cities_dir + f) as CityData
			if res and res.id != "":
				cities[res.id] = res

	# Routes will be added in Phase 2


func get_good(id: String) -> TradeGoodData:
	return goods.get(id)


func get_city(id: String) -> CityData:
	return cities.get(id)


func get_all_good_ids() -> Array[String]:
	return goods.keys()


func get_all_city_ids() -> Array[String]:
	return cities.keys()


func is_loaded() -> bool:
	return _loaded
