# resources/city_data.gd
# Static definition for a city / market hub on Athas.
# All instances live as .tres in data/cities/

class_name CityData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var flavor_text: String = ""
@export var signature_goods: Array[String] = []  # goods that are abundant here (price pressure downward)
@export var scarce_goods: Array[String] = []     # goods that are scarce (price pressure upward)
@export var base_risk_modifier: float = 0.0      # future: affects caravan events on routes to/from here
