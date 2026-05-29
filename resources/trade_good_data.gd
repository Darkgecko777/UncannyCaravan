# resources/trade_good_data.gd
# Static definition for a trade good. Instances live as .tres in data/goods/
# Used by EconomySystem for base prices and by UI for icons/names.

class_name TradeGoodData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var base_price: int = 50
@export var unit_weight: int = 1          # Used for caravan capacity calculations
@export_multiline var flavor_text: String = ""
@export var category: String = "general"  # e.g. "luxury", "bulk", "strategic", "raw"
