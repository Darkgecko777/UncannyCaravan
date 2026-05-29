# autoloads/game_state.gd
# Single source of truth for all mutable player state.
# Persisted through SaveSystem. UI and systems read/write via methods + signals.

extends Node

const STARTING_CASH := 850
const STARTING_INVENTORY := {
	"bloodglass": 35,
	"ambergrain": 120,
	"veil_figs": 18,
}

var cash: int = STARTING_CASH
var inventory: Dictionary = STARTING_INVENTORY.duplicate()  # good_id -> int quantity
var upgrades: Dictionary = {
	"caravan_slots": 1,
	"base_capacity": 1,
	"guard_quality": 0,
}
var reputation: Dictionary = {}  # faction_id -> level (0-5)
var discovered_cities: Array[String] = ["tyr", "urik"]

var active_caravans: Array[Dictionary] = []  # Populated by CaravanSystem

var last_save_unix: float = 0.0


func _ready() -> void:
	# Ensure all known goods have an entry (prevents null checks everywhere)
	_initialize_inventory_keys()


func _initialize_inventory_keys() -> void:
	# Will be expanded when full goods list is loaded from EconomySystem
	var known_goods := ["bloodglass", "sunsteel", "agafari", "ambergrain", "veil_figs",
						"brine", "sting_nectar", "duneweave", "mekillot", "ghostroot"]
	for g in known_goods:
		if not inventory.has(g):
			inventory[g] = 0


func get_cash() -> int:
	return cash


func add_cash(amount: int) -> void:
	if amount == 0:
		return
	cash += amount
	SignalBus.cash_changed.emit(cash)


func spend_cash(amount: int) -> bool:
	if cash < amount:
		return false
	cash -= amount
	SignalBus.cash_changed.emit(cash)
	return true


func can_afford(amount: int) -> bool:
	return cash >= amount


func get_inventory(good_id: String) -> int:
	return inventory.get(good_id, 0)


func add_goods(good_id: String, amount: int) -> void:
	if amount <= 0:
		return
	inventory[good_id] = inventory.get(good_id, 0) + amount
	SignalBus.inventory_changed.emit(good_id, inventory[good_id], amount)


func remove_goods(good_id: String, amount: int) -> bool:
	var current := inventory.get(good_id, 0)
	if current < amount:
		return false
	inventory[good_id] = current - amount
	SignalBus.inventory_changed.emit(good_id, inventory[good_id], -amount)
	return true


func get_active_caravans() -> Array[Dictionary]:
	return active_caravans


func add_active_caravan(caravan: Dictionary) -> void:
	active_caravans.append(caravan)
	SignalBus.active_caravans_changed.emit()


func remove_active_caravan(caravan_id: String) -> void:
	for i in range(active_caravans.size() - 1, -1, -1):
		if active_caravans[i].get("id") == caravan_id:
			active_caravans.remove_at(i)
			break
	SignalBus.active_caravans_changed.emit()


func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)


func set_upgrade_level(upgrade_id: String, level: int) -> void:
	upgrades[upgrade_id] = level
	SignalBus.upgrade_purchased.emit(upgrade_id, level)


func get_reputation(faction_id: String) -> int:
	return reputation.get(faction_id, 0)


func set_reputation(faction_id: String, level: int) -> void:
	reputation[faction_id] = clamp(level, 0, 5)
	SignalBus.reputation_changed.emit(faction_id, reputation[faction_id])


func get_max_caravans() -> int:
	return 1 + get_upgrade_level("caravan_slots")


func get_base_capacity() -> int:
	return 80 + (get_upgrade_level("base_capacity") * 25)


func get_guard_bonus() -> float:
	return get_upgrade_level("guard_quality") * 0.12  # 12% risk reduction per level


# For save/load
func to_dict() -> Dictionary:
	return {
		"cash": cash,
		"inventory": inventory.duplicate(),
		"upgrades": upgrades.duplicate(),
		"reputation": reputation.duplicate(),
		"discovered_cities": discovered_cities.duplicate(),
		"active_caravans": active_caravans.duplicate(true),
		"last_save_unix": last_save_unix,
	}


func from_dict(data: Dictionary) -> void:
	cash = data.get("cash", STARTING_CASH)
	inventory = data.get("inventory", STARTING_INVENTORY.duplicate())
	upgrades = data.get("upgrades", upgrades)
	reputation = data.get("reputation", {})
	discovered_cities = data.get("discovered_cities", ["tyr", "urik"])
	active_caravans = data.get("active_caravans", [])
	last_save_unix = data.get("last_save_unix", 0.0)
	_initialize_inventory_keys()
	SignalBus.cash_changed.emit(cash)
