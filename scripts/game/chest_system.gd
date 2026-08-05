class_name ChestSystem
extends RefCounted
## Rolls item drops from chests and charges the player in gems.
##
## ChestSystem knows how to price a chest (via ChestConfig), how to
## weight-roll items by rarity (via ItemConfig), and how to pay for a
## chest through GameManager. It does not know how items are rendered
## or how they are stored once owned — GameManager owns that. The
## item pool is scanned from data/items/ once and cached for the
## session, since it does not change at runtime.

const ITEMS_DIRECTORY_PATH: String = "res://data/items/"

const CHEST_CONFIG_PATHS: Dictionary = {
	ChestConfig.ChestType.STANDARD: "res://data/chests/chest_standard.tres",
	ChestConfig.ChestType.GOLD: "res://data/chests/chest_gold.tres",
	ChestConfig.ChestType.PLATINUM: "res://data/chests/chest_platinum.tres",
}

static var _common_items: Array[ItemConfig] = []
static var _rare_items: Array[ItemConfig] = []
static var _legendary_items: Array[ItemConfig] = []
static var _item_pool_loaded: bool = false


## Attempts to open a chest of [param chest_type].
## Spends gems through GameManager and, on success, rolls its item
## drops, adds each to GameManager, and reports them via
## EventBus.on_chest_opened. Returns the dropped items, or an empty
## array if the chest config is missing or gems are insufficient.
static func open_chest(chest_type: ChestConfig.ChestType) -> Array[ItemConfig]:
	var config: ChestConfig = _load_chest_config(chest_type)
	if config == null:
		return []

	if not GameManager.spend_gems(config.gem_cost):
		return []

	var dropped_items: Array[ItemConfig] = _roll_items(config)
	for item: ItemConfig in dropped_items:
		GameManager.add_item(item)

	var chest_type_name: String = ChestConfig.ChestType.keys()[chest_type]
	EventBus.on_chest_opened.emit(chest_type_name, dropped_items)
	return dropped_items


static func _load_chest_config(chest_type: ChestConfig.ChestType) -> ChestConfig:
	if not CHEST_CONFIG_PATHS.has(chest_type):
		push_error("ChestSystem: no config path registered for chest type %d" % chest_type)
		return null

	var config_path: String = CHEST_CONFIG_PATHS[chest_type]
	var config: ChestConfig = load(config_path) as ChestConfig
	if config == null:
		push_error("ChestSystem: failed to load chest config at %s" % config_path)
	return config


static func _roll_items(config: ChestConfig) -> Array[ItemConfig]:
	var drop_count: int = randi_range(config.min_item_drops, config.max_item_drops)
	var results: Array[ItemConfig] = []

	for i: int in range(drop_count):
		var item: ItemConfig = _roll_single_item(config.rarity_weights)
		if item != null:
			results.append(item)

	return results


static func _roll_single_item(rarity_weights: Array[float]) -> ItemConfig:
	_ensure_item_pool_loaded()

	var rarity: int = _roll_rarity(rarity_weights)
	var pool: Array[ItemConfig] = _get_item_pool_for_rarity(rarity)
	if pool.is_empty():
		push_warning("ChestSystem: no items available for rarity %d" % rarity)
		return null

	var random_index: int = randi() % pool.size()
	return pool[random_index]


## Picks a rarity index by weighted random roll over
## [param rarity_weights], ordered [Common, Rare, Legendary] to match
## ItemConfig.Rarity.
static func _roll_rarity(rarity_weights: Array[float]) -> int:
	var total_weight: float = 0.0
	for weight: float in rarity_weights:
		total_weight += weight

	var roll: float = randf() * total_weight
	var cumulative: float = 0.0

	for rarity_index: int in range(rarity_weights.size()):
		cumulative += rarity_weights[rarity_index]
		if roll < cumulative:
			return rarity_index

	return rarity_weights.size() - 1


static func _get_item_pool_for_rarity(rarity: int) -> Array[ItemConfig]:
	match rarity:
		ItemConfig.Rarity.COMMON:
			return _common_items
		ItemConfig.Rarity.RARE:
			return _rare_items
		ItemConfig.Rarity.LEGENDARY:
			return _legendary_items
		_:
			return []


static func _ensure_item_pool_loaded() -> void:
	if _item_pool_loaded:
		return

	var dir: DirAccess = DirAccess.open(ITEMS_DIRECTORY_PATH)
	if dir == null:
		push_error("ChestSystem: failed to open items directory at %s" % ITEMS_DIRECTORY_PATH)
		_item_pool_loaded = true
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			_load_item_into_pool(ITEMS_DIRECTORY_PATH + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	_item_pool_loaded = true


static func _load_item_into_pool(item_path: String) -> void:
	var item: ItemConfig = load(item_path) as ItemConfig
	if item == null:
		push_error("ChestSystem: failed to load item at %s" % item_path)
		return

	match item.rarity:
		ItemConfig.Rarity.COMMON:
			_common_items.append(item)
		ItemConfig.Rarity.RARE:
			_rare_items.append(item)
		ItemConfig.Rarity.LEGENDARY:
			_legendary_items.append(item)
