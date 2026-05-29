# resources/trade_route_data.gd
# Static definition for a trade route between cities.
# All instances live as .tres in data/routes/ (to be added in Phase 2).

class_name TradeRouteData
extends Resource

@export var id: String = ""
@export var from_city: String = ""
@export var to_city: String = ""
@export var travel_time_seconds: int = 300
@export var base_risk: float = 0.2
@export_multiline var flavor_text: String = ""
