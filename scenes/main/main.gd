# scenes/main/main.gd
# Thin root controller. Wires live UI, handles tools, and keeps the mood clean.
# Debug tools are present but secondary — this is no longer a pure debug harness.

extends Node

@onready var cash_label: Label = %CashLabel
@onready var inventory_label: RichTextLabel = %InventoryLabel
@onready var caravan_list: VBoxContainer = %CaravanList
@onready var event_log: RichTextLabel = %EventLog
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	# Live updates
	SignalBus.cash_changed.connect(_on_cash_changed)
	SignalBus.inventory_changed.connect(_on_inventory_changed)
	SignalBus.caravan_dispatched.connect(_on_caravan_dispatched)
	SignalBus.caravan_resolved.connect(_on_caravan_resolved)
	SignalBus.active_caravans_changed.connect(_refresh_caravan_list)
	SignalBus.offline_progress_applied.connect(_on_offline_progress)
	SignalBus.game_loaded.connect(_refresh_all_ui)
	SignalBus.game_saved.connect(func(): _log("State sealed."))

	_refresh_all_ui()
	SaveSystem.load_game()
	SaveSystem.force_save()

	_log("Caravan house online. The dust waits.")
	_set_status("Ready")


func _refresh_all_ui() -> void:
	_on_cash_changed(GameState.cash)
	_refresh_inventory()
	_refresh_caravan_list()


func _on_cash_changed(new_amount: int) -> void:
	cash_label.text = "%d  Ceramic Bits" % new_amount


func _on_inventory_changed(_good_id: String, _new_amount: int, _delta: int) -> void:
	_refresh_inventory()


func _refresh_inventory() -> void:
	var lines: PackedStringArray = ["[b]HOLDINGS[/b]"]
	var has_goods := false
	for good_id_variant in GameState.inventory:
		var good_id: String = good_id_variant as String
		var qty: int = GameState.get_inventory(good_id)
		if qty > 0:
			has_goods = true
			var name: String = good_id.capitalize()
			if DataRegistry and DataRegistry.is_loaded():
				var gd: TradeGoodData = DataRegistry.get_good(good_id)
				if gd:
					name = gd.display_name
			lines.append("%s  ·  %d" % [name, qty])
	if not has_goods:
		lines.append("[color=#888888]Empty wagon beds[/color]")
	inventory_label.text = "\n".join(lines)


func _refresh_caravan_list() -> void:
	for child in caravan_list.get_children():
		child.queue_free()

	var caravans: Array[Dictionary] = GameState.get_active_caravans()
	if caravans.is_empty():
		var empty := Label.new()
		empty.text = "No caravans on the road"
		empty.modulate = Color(0.55, 0.55, 0.55)
		caravan_list.add_child(empty)
		return

	for c_variant in caravans:
		var c: Dictionary = c_variant
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var label := Label.new()
		var eta: float = c.get("eta_unix", 0.0) as float
		var remaining: float = max(0.0, eta - Time.get_unix_time_from_system())
		label.text = "%s  ·  %.0fs remaining" % [c.get("route_id", "?"), remaining]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var resolve_btn := Button.new()
		resolve_btn.text = "Resolve"
		var captured_id: String = c.get("id", "")
		resolve_btn.pressed.connect(func(): CaravanSystem.resolve_caravan(captured_id, true))
		row.add_child(resolve_btn)

		caravan_list.add_child(row)


func _on_caravan_dispatched(id: String, route: String, cargo: Dictionary) -> void:
	_log("Dispatched %s on %s with %s" % [id, route, cargo])
	_set_status("Caravan on the road")
	_refresh_caravan_list()


func _on_caravan_resolved(id: String, profit: int, events: Array, _value: int) -> void:
	_log("Returned: %s  ·  Profit %d bits" % [id, profit])
	if events.size() > 0:
		_log("  — %s" % str(events[0]))
	_set_status("Caravan resolved")
	_refresh_all_ui()


func _on_offline_progress(seconds: float, summary: Dictionary) -> void:
	var mins := seconds / 60.0
	_log("You were away %.0f minutes." % mins)
	_log("Offline: %s" % str(summary))
	_refresh_all_ui()


# === Tools (intentionally secondary) ===

func _on_give_cash_pressed() -> void:
	GameState.add_cash(500)
	_log("+500 Ceramic Bits")


func _on_give_goods_pressed() -> void:
	GameState.add_goods("sunsteel", 2)
	GameState.add_goods("bloodglass", 25)
	GameState.add_goods("veil_figs", 12)
	_log("Added test goods to holdings")


func _on_market_tick_pressed() -> void:
	EconomySystem.force_market_tick()
	_log("Market pressure adjusted")


func _on_send_test_caravan_pressed() -> void:
	var cargo := {"sunsteel": 1, "bloodglass": 8}
	CaravanSystem.dispatch_caravan("tyr_urik", cargo, 1)
	_log("Test caravan left the gates")


func _on_save_pressed() -> void:
	SaveSystem.force_save()
	_log("Forced save")


func _on_force_offline_pressed() -> void:
	var fake_seconds := 4.0 * 3600.0
	var summary := CaravanSystem.advance_offline(fake_seconds)
	SignalBus.offline_progress_applied.emit(fake_seconds, summary)
	_log("Simulated four hours of dust")


func _log(message: String) -> void:
	var stamp := Time.get_time_string_from_system()
	event_log.append_text("[color=#7a7a7a]%s[/color]  %s\n" % [stamp, message])
	event_log.scroll_to_line(event_log.get_line_count() - 1)


func _set_status(text: String) -> void:
	status_label.text = text
