extends Node
## Global quest-tracking singleton (autoload).
##
## QuestManager loads every QuestConfig from data/quests/, tracks each
## quest's progress by listening to EventBus, resets daily/weekly
## quests when their period rolls over, and grants rewards through
## GameManager when a quest is explicitly claimed via
## [method complete_quest]. Reaching a quest's target does not auto-
## grant the reward — the caller (UI) must claim it.
##
## REACH_PRODUCTION_RATE quests need the true total production rate
## across every FarmPlot, which EventBus.on_resource_produced cannot
## provide by itself (it only reports one plot's rate at a time). To
## get an accurate total, QuestManager is given a ResourceManager
## reference via [method setup]; on_resource_produced is used only as
## a trigger to re-check that total.

const QUESTS_DIRECTORY_PATH: String = "res://data/quests/"
const SAVE_FILE_PATH: String = "user://quest_save.json"
const DAY_SECONDS: int = 86400
const WEEK_SECONDS: int = 604800

var _quests: Dictionary = {}
var _progress: Dictionary = {}
var _claimed_quest_ids: Array[String] = []

var _last_daily_period_index: int = -1
var _last_weekly_period_index: int = -1

var _last_known_coin_balance: int = 0
var _resource_manager: ResourceManager


func _ready() -> void:
	_load_quest_configs()
	load_quests()
	_check_and_reset_expired_quests()
	_last_known_coin_balance = GameManager.coins

	EventBus.on_coins_changed.connect(_on_coins_changed)
	EventBus.on_chest_opened.connect(_on_chest_opened)
	EventBus.on_plot_upgraded.connect(_on_plot_upgraded)
	EventBus.on_resource_produced.connect(_on_resource_produced)
	EventBus.on_game_saved.connect(_on_game_saved)


## Injects the ResourceManager used to evaluate REACH_PRODUCTION_RATE
## quests. Must be called once the scene's ResourceManager exists.
func setup(resource_manager: ResourceManager) -> void:
	_resource_manager = resource_manager


## Returns every loaded quest of [param quest_type], for building a
## quest list UI.
func get_quests(quest_type: QuestConfig.QuestType) -> Array[QuestConfig]:
	var result: Array[QuestConfig] = []
	for quest_id: String in _quests.keys():
		var config: QuestConfig = _quests[quest_id] as QuestConfig
		if config.quest_type == quest_type:
			result.append(config)
	return result


## Returns the current progress amount for [param quest_id], or 0.0 if
## it has no recorded progress yet.
func get_quest_progress(quest_id: String) -> float:
	return _progress.get(quest_id, 0.0)


## Returns true if [param quest_id]'s reward has already been claimed
## this period.
func is_quest_claimed(quest_id: String) -> bool:
	return quest_id in _claimed_quest_ids


## Claims the reward for [param quest_id] if its progress has reached
## its target and it hasn't already been claimed this period. Grants
## the reward through GameManager and reports completion via
## EventBus. Returns true if the quest was successfully claimed.
func complete_quest(quest_id: String) -> bool:
	if not _quests.has(quest_id):
		push_error("QuestManager: unknown quest id %s" % quest_id)
		return false

	if quest_id in _claimed_quest_ids:
		return false

	var config: QuestConfig = _quests[quest_id] as QuestConfig
	var current_progress: float = _progress.get(quest_id, 0.0)
	if current_progress < config.target_amount:
		return false

	_grant_reward(config)
	_claimed_quest_ids.append(quest_id)

	var reward_type_name: String = QuestConfig.RewardType.keys()[config.reward_type]
	EventBus.on_quest_completed.emit(quest_id, reward_type_name, config.reward_amount)
	return true


func _grant_reward(config: QuestConfig) -> void:
	match config.reward_type:
		QuestConfig.RewardType.COINS:
			GameManager.add_coins(config.reward_amount)
		QuestConfig.RewardType.GEMS:
			GameManager.add_gems(config.reward_amount)


func _load_quest_configs() -> void:
	var dir: DirAccess = DirAccess.open(QUESTS_DIRECTORY_PATH)
	if dir == null:
		push_error("QuestManager: failed to open quests directory at %s" % QUESTS_DIRECTORY_PATH)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			_load_quest_config_file(QUESTS_DIRECTORY_PATH + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


func _load_quest_config_file(path: String) -> void:
	var config: QuestConfig = load(path) as QuestConfig
	if config == null:
		push_error("QuestManager: failed to load quest config at %s" % path)
		return

	if config.quest_id.is_empty():
		push_error("QuestManager: quest config at %s has no quest_id" % path)
		return

	_quests[config.quest_id] = config


func _check_and_reset_expired_quests() -> void:
	var now: int = int(Time.get_unix_time_from_system())

	var current_daily_index: int = _get_period_index(now, DAY_SECONDS)
	if _last_daily_period_index != current_daily_index:
		_reset_quests_of_type(QuestConfig.QuestType.DAILY)
		_last_daily_period_index = current_daily_index

	var current_weekly_index: int = _get_period_index(now, WEEK_SECONDS)
	if _last_weekly_period_index != current_weekly_index:
		_reset_quests_of_type(QuestConfig.QuestType.WEEKLY)
		_last_weekly_period_index = current_weekly_index


func _get_period_index(unix_timestamp: int, period_seconds: int) -> int:
	return int(floor(float(unix_timestamp) / float(period_seconds)))


func _reset_quests_of_type(quest_type: QuestConfig.QuestType) -> void:
	for quest_id: String in _quests.keys():
		var config: QuestConfig = _quests[quest_id] as QuestConfig
		if config.quest_type != quest_type:
			continue
		_progress[quest_id] = 0.0
		_claimed_quest_ids.erase(quest_id)


func _on_coins_changed(new_amount: int) -> void:
	var delta: int = new_amount - _last_known_coin_balance
	_last_known_coin_balance = new_amount
	if delta > 0:
		_add_progress(QuestConfig.ObjectiveType.COLLECT_COINS, float(delta))


func _on_chest_opened(_chest_type: String, _items: Array) -> void:
	_add_progress(QuestConfig.ObjectiveType.OPEN_CHEST, 1.0)


func _on_plot_upgraded(_new_level: int) -> void:
	_add_progress(QuestConfig.ObjectiveType.UPGRADE_PLOT, 1.0)


func _on_resource_produced(_resource_type: String, _amount: float) -> void:
	if _resource_manager == null:
		return
	var total_rate: float = _resource_manager.get_total_production_rate()
	_set_progress_if_higher(QuestConfig.ObjectiveType.REACH_PRODUCTION_RATE, total_rate)


func _on_game_saved() -> void:
	save_quests()


## Adds [param delta_amount] to every unclaimed quest whose objective
## matches [param objective_type]. Used for cumulative objectives
## (coins collected, chests opened, plots upgraded).
func _add_progress(objective_type: QuestConfig.ObjectiveType, delta_amount: float) -> void:
	for quest_id: String in _quests.keys():
		if quest_id in _claimed_quest_ids:
			continue

		var config: QuestConfig = _quests[quest_id] as QuestConfig
		if config.objective_type != objective_type:
			continue

		var new_progress: float = min(config.target_amount, _progress.get(quest_id, 0.0) + delta_amount)
		_progress[quest_id] = new_progress
		EventBus.on_quest_progress_updated.emit(quest_id, new_progress, config.target_amount)


## Raises progress on every unclaimed quest whose objective matches
## [param objective_type] up to [param observed_amount], if that is
## higher than the quest's current progress. Used for "reach X"
## threshold objectives rather than cumulative ones.
func _set_progress_if_higher(objective_type: QuestConfig.ObjectiveType, observed_amount: float) -> void:
	for quest_id: String in _quests.keys():
		if quest_id in _claimed_quest_ids:
			continue

		var config: QuestConfig = _quests[quest_id] as QuestConfig
		if config.objective_type != objective_type:
			continue

		var current_progress: float = _progress.get(quest_id, 0.0)
		if observed_amount <= current_progress:
			continue

		var new_progress: float = min(config.target_amount, observed_amount)
		_progress[quest_id] = new_progress
		EventBus.on_quest_progress_updated.emit(quest_id, new_progress, config.target_amount)


## Serializes quest progress, claimed status, and reset period indices
## to disk as JSON. Returns true on success.
func save_quests() -> bool:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("QuestManager: failed to open quest save file for writing (error %d)" % FileAccess.get_open_error())
		return false

	file.store_string(JSON.stringify(_build_save_data(), "\t"))
	file.close()
	return true


## Loads quest progress, claimed status, and reset period indices from
## disk. A missing save file is not an error — it's the expected
## first-launch case.
func load_quests() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return false

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("QuestManager: failed to open quest save file for reading (error %d)" % FileAccess.get_open_error())
		return false

	var raw_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		push_error("QuestManager: quest save file is corrupted or contains invalid JSON")
		return false

	_apply_save_data(parsed)
	return true


func _build_save_data() -> Dictionary:
	return {
		"progress": _progress,
		"claimed_quest_ids": _claimed_quest_ids,
		"last_daily_period_index": _last_daily_period_index,
		"last_weekly_period_index": _last_weekly_period_index,
	}


func _apply_save_data(data: Dictionary) -> void:
	var saved_progress: Variant = data.get("progress", {})
	if saved_progress is Dictionary:
		_progress = saved_progress
	else:
		_progress = {}

	_claimed_quest_ids = []
	var saved_claimed: Variant = data.get("claimed_quest_ids", [])
	if saved_claimed is Array:
		for id: Variant in (saved_claimed as Array):
			if id is String:
				_claimed_quest_ids.append(id)

	_last_daily_period_index = data.get("last_daily_period_index", -1)
	_last_weekly_period_index = data.get("last_weekly_period_index", -1)
