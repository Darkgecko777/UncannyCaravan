# scenes/main/main.gd
# Root controller for the game. Wires debug UI, handles save notifications,
# and will later manage panel swapping.

extends Node

@onready var cash_label: Label = %CashLabel
@onready var inventory_label: RichTextLabel = %InventoryLabel
@onready var debug_log: RichTextLabel = %DebugLog
@onready var caravan_list: VBoxContainer = %CaravanList


func _ready() -> void:
	# Connect to the signals we care about for live UI
	SignalBus.cash_changed.connect(_on_cash_changed)
	SignalBus.inventory_changed.connect(_on_inventory_changed)
	SignalBus.caravan_dispatched.connect(_on_caravan_dispatched)
	SignalBus.caravan_resolved.connect(_on_caravan_resolved)
	SignalBus.active_caravans_changed.connect(_refresh_caravan_list)
	SignalBus.offline_progress_applied.connect(_on_offline_progress)

	# Initial UI sync
	_refresh_all_ui()

	# Load game (this triggers offline processing)
	SaveSystem.load_game()

	# Force an initial save so timestamp is fresh
	SaveSystem.force_save()

	_log("Uncanny Caravan Phase 0 skeleton ready. Use debug buttons to test core loop.")
	_log("Send a test caravan (stub) or add goods and watch the numbers.")


func _refresh_all_ui() -> void:
	_on_cash_changed(GameState.cash)
	_refresh_inventory()
	_refresh_caravan_list()


func _on_cash_changed(new_amount: int) -> void:
	cash_label.text = "Ceramic Bits: %d" % new_amount


func _on_inventory_changed(_good_id: String, _new_amount: int, _delta: int) -> void:
	_refresh_inventory()


func _refresh_inventory() -> void:
	var text := "[b]Inventory[/b]\n"
	for good in GameState.inventory:
		var qty := GameState.get_inventory(good)
		if qty > 0 or good in ["bloodglass", "ambergrain"]:  # Always show key goods
			text += "• %s: %d\n" % [good.capitalize(), qty]
	inventory_label.text = text


func _refresh_caravan_list() -> void:
	# Clear existing
	for child in caravan_list.get_children():
		child.queue_free()

	var caravans := GameState.get_active_caravans()
	if caravans.is_empty():
		var l := Label.new()
		l.text = "No active caravans"
		l.modulate = Color(0.7, 0.7, 0.7)
		caravan_list.add_child(l)
		return

	for c in caravans:
		var row := HBoxContainer.new()
		var label := Label.new()
		var eta := c.get("eta_unix", 0.0)
		var remaining := max(0.0, eta - Time.get_unix_time_from_system())
		label.text = "%s → %s (%.0fs)  Cargo: %s" % [
			c.get("route_id", "?"),
			"DEST",
			remaining,
			c.get("cargo", {}).keys()
		]
		row.add_child(label)

		var resolve_btn := Button.new()
		resolve_btn.text = "Resolve Now (stub)"
		var captured_id: String = c.get("id", "")
		resolve_btn.pressed.connect(func(): CaravanSystem.resolve_caravan(captured_id, true))
		row.add_child(resolve_btn)

		caravan_list.add_child(row)


func _on_caravan_dispatched(id: String, route: String, cargo: Dictionary) -> void:
	_log("Dispatched caravan %s on %s with %s" % [id, route, cargo])
	_refresh_caravan_list()


func _on_caravan_resolved(id: String, profit: int, events: Array, _value: int) -> void:
	_log("Caravan %s returned! Profit: %d bits. Events: %s" % [id, profit, events])
	_refresh_all_ui()


func _on_offline_progress(seconds: float, summary: Dictionary) -> void:
	var msg := "Welcome back! You were away for %.0f minutes." % (seconds / 60.0)
	_log(msg)
	_log("Offline summary: %s" % str(summary))
	_refresh_all_ui()


# === DEBUG BUTTONS (wired in scene) ===

func _on_give_cash_pressed() -> void:
	GameState.add_cash(500)
	_log("Debug: +500 bits")


func _on_give_goods_pressed() -> void:
	GameState.add_goods("sunsteel", 2)
	GameState.add_goods("bloodglass", 25)
	GameState.add_goods("veil_figs", 12)
	_log("Debug: Added sunsteel x2, bloodglass x25, veil_figs x12")


func _on_market_tick_pressed() -> void:
	EconomySystem.force_market_tick()
	_log("Debug: Forced market tick")


func _on_send_test_caravan_pressed() -> void:
	var cargo := {"sunsteel": 1, "bloodglass": 8}
	CaravanSystem.dispatch_caravan("tyr_urik", cargo, 1)
	_log("Debug: Sent test caravan (stub logic)")


func _on_save_pressed() -> void:
	SaveSystem.force_save()
	_log("Debug: Forced save")


func _on_force_offline_pressed() -> void:
	# Cheat: pretend 4 hours passed
	var fake_seconds := 4.0 * 3600.0
	var summary := CaravanSystem.advance_offline(fake_seconds)
	SignalBus.offline_progress_applied.emit(fake_seconds, summary)
	_log("Debug: Simulated 4 hours offline")


func _log(message: String) -> void:
	debug_log.append_text("[%s] %s\n" % [Time.get_time_string_from_system(), message])
	debug_log.scroll_to_line(debug_log.get_line_count() - 1)
	print(message)
