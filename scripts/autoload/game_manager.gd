extends Node
## Global game state manager (autoload singleton).
##
## GameManager owns the authoritative runtime state of the game
## (currencies, play time) and is the single entry point for mutating
## that state. It loads GameConfig on startup and owns persistence of
## player data to disk.
##
## All state mutations go through this singleton's public API so that
## EventBus signals stay in sync with the actual state — do not mutate
## [member coins] / [member gems] directly from outside this script.

## Path to the JSON save file on disk.
const SAVE_FILE_PATH := "user://save_game.json"

## The active game configuration, loaded once on [method _ready].
var config: GameConfig

## Current soft currency balance.
var coins: int = 0

## Current premium currency balance.
var gems: int = 0

## Total accumulated play time, in seconds, across all sessions.
var play_time: float = 0.0

## Unix timestamp (seconds) of the last successful save. Used by
## ResourceManager to compute how much offline progress to grant on
## the next load.
var last_save_timestamp: int = 0

## Items the player has collected from chests.
var owned_items: Array[ItemConfig] = []


func _ready() -> void:
	_load_config()
	load_game()


func _process(delta: float) -> void:
	play_time += delta


## Instantiates [GameConfig] and applies its starting values to the
## current session state.
func _load_config() -> void:
	config = GameConfig.new()
	coins = config.starting_coins
	gems = config.starting_gems


## Adds [param amount] coins and notifies listeners via EventBus.
## Amounts less than or equal to zero are ignored.
func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	EventBus.on_coins_changed.emit(coins)


## Attempts to spend [param amount] coins.
## Returns [code]true[/code] on success, [code]false[/code] if the
## amount is invalid or the balance is insufficient.
func spend_coins(amount: int) -> bool:
	if amount <= 0 or amount > coins:
		return false
	coins -= amount
	EventBus.on_coins_changed.emit(coins)
	return true


## Adds [param amount] gems and notifies listeners via EventBus.
## Amounts less than or equal to zero are ignored.
func add_gems(amount: int) -> void:
	if amount <= 0:
		return
	gems += amount
	EventBus.on_gems_changed.emit(gems)


## Attempts to spend [param amount] gems.
## Returns [code]true[/code] on success, [code]false[/code] if the
## amount is invalid or the balance is insufficient.
func spend_gems(amount: int) -> bool:
	if amount <= 0 or amount > gems:
		return false
	gems -= amount
	EventBus.on_gems_changed.emit(gems)
	return true


## Adds [param item] to the player's owned items inventory.
func add_item(item: ItemConfig) -> void:
	if item == null:
		return
	owned_items.append(item)


## Serializes the current game state to disk as JSON.
## Returns [code]true[/code] on success, [code]false[/code] if the save
## file could not be written.
func save_game() -> bool:
	last_save_timestamp = int(Time.get_unix_time_from_system())
	var save_data := _build_save_data()
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("GameManager: failed to open save file for writing (error %d)" % FileAccess.get_open_error())
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	EventBus.on_game_saved.emit()
	return true


## Loads game state from disk.
## Returns [code]true[/code] on success. A missing save file is not
## treated as an error — the game simply keeps its freshly-initialized
## state, which is the expected first-launch case.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return false

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("GameManager: failed to open save file for reading (error %d)" % FileAccess.get_open_error())
		return false

	var raw_text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		push_error("GameManager: save file is corrupted or contains invalid JSON")
		return false

	_apply_save_data(parsed)
	EventBus.on_game_loaded.emit()
	return true


## Builds the plain [Dictionary] that gets serialized to the save file.
func _build_save_data() -> Dictionary:
	return {
		"coins": coins,
		"gems": gems,
		"play_time": play_time,
		"last_save_timestamp": last_save_timestamp,
		"owned_items": _serialize_owned_items(),
		"game_version": config.game_version,
	}


## Converts [member owned_items] into a plain array of resource paths,
## since ItemConfig resources cannot be serialized to JSON directly.
func _serialize_owned_items() -> Array[String]:
	var paths: Array[String] = []
	for item: ItemConfig in owned_items:
		paths.append(item.resource_path)
	return paths


## Applies a parsed save [Dictionary] to the current state. Missing or
## malformed fields fall back to safe defaults instead of failing the
## whole load.
func _apply_save_data(data: Dictionary) -> void:
	coins = data.get("coins", config.starting_coins)
	gems = data.get("gems", config.starting_gems)
	play_time = data.get("play_time", 0.0)
	last_save_timestamp = data.get("last_save_timestamp", 0)
	owned_items = _deserialize_owned_items(data.get("owned_items", []))


## Reloads each owned item from its saved resource path. Paths that
## are malformed or no longer resolve to an ItemConfig are skipped
## rather than failing the whole load.
func _deserialize_owned_items(paths: Array) -> Array[ItemConfig]:
	var items: Array[ItemConfig] = []
	for path: Variant in paths:
		if typeof(path) != TYPE_STRING:
			continue
		var item: ItemConfig = load(path) as ItemConfig
		if item != null:
			items.append(item)
	return items
