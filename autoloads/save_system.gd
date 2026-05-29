# autoloads/save_system.gd
# Handles JSON save/load with versioning and timestamp for offline progress.
# File: user://uncanny_caravan_save_v1.json

extends Node

const SAVE_PATH := "user://uncanny_caravan_save_v1.json"
const SAVE_VERSION := 1
const MAX_OFFLINE_SECONDS := 86400.0 * 1.5  # 36 hours cap for MVP (upgradeable later)


func save_game() -> bool:
	var data := _gather_save_data()
	var json_string := JSON.stringify(data, "\t", false)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: ", FileAccess.get_open_error())
		return false

	file.store_string(json_string)
	file.close()

	GameState.last_save_unix = Time.get_unix_time_from_system()
	SignalBus.game_saved.emit()
	print("[SaveSystem] Game saved successfully.")
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] No save file found. Starting new game.")
		_initialize_new_game()
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading.")
		_initialize_new_game()
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("Save file corrupted (JSON parse failed). Starting fresh.")
		_initialize_new_game()
		return false

	var data: Dictionary = json.data
	if data.get("version", 0) != SAVE_VERSION:
		print("[SaveSystem] Save version mismatch (got ", data.get("version"), "). Migration not implemented — starting fresh for MVP.")
		_initialize_new_game()
		return false

	GameState.from_dict(data)

	# Critical: Process offline progress immediately after loading state
	_process_offline_progress(data.get("last_save_unix", 0.0))

	SignalBus.game_loaded.emit()
	print("[SaveSystem] Game loaded. Cash: ", GameState.cash)
	return true


func _gather_save_data() -> Dictionary:
	var data := GameState.to_dict()
	data["version"] = SAVE_VERSION
	data["last_save_unix"] = Time.get_unix_time_from_system()
	return data


func _initialize_new_game() -> void:
	GameState.cash = GameState.STARTING_CASH
	GameState.inventory = GameState.STARTING_INVENTORY.duplicate()
	GameState.last_save_unix = Time.get_unix_time_from_system()
	# Emit initial state so UI can react
	SignalBus.cash_changed.emit(GameState.cash)


func _process_offline_progress(last_save: float) -> void:
	var now := Time.get_unix_time_from_system()
	var seconds_offline := now - last_save

	if seconds_offline < 30.0:  # Ignore tiny absences
		return

	seconds_offline = min(seconds_offline, MAX_OFFLINE_SECONDS)

	# Delegate actual simulation to the caravan system (most important for events)
	if has_node("/root/CaravanSystem"):
		var summary := CaravanSystem.advance_offline(seconds_offline)
		SignalBus.offline_progress_applied.emit(seconds_offline, summary)
	else:
		# Fallback if CaravanSystem not ready yet
		print("[SaveSystem] Offline time: %.0f seconds (CaravanSystem not available for full sim)" % seconds_offline)

	GameState.last_save_unix = now


func force_save() -> void:
	save_game()


# Called by OS notification in main scene
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
