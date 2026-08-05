class_name ChestShop
extends PanelContainer
## Chest shop UI: lets the player spend gems to open standard, gold,
## or platinum chests, and shows the items from the most recent open.
##
## ChestShop is purely a view: it forwards button presses to
## ChestSystem.open_chest() and reacts to EventBus.on_chest_opened and
## on_gems_changed to keep its display and button states current.

@onready var _standard_chest_button: Button = $Content/ChestButtons/StandardChestButton
@onready var _gold_chest_button: Button = $Content/ChestButtons/GoldChestButton
@onready var _platinum_chest_button: Button = $Content/ChestButtons/PlatinumChestButton
@onready var _last_drop_label: Label = $Content/LastDropLabel


func _ready() -> void:
	_standard_chest_button.pressed.connect(_on_standard_chest_button_pressed)
	_gold_chest_button.pressed.connect(_on_gold_chest_button_pressed)
	_platinum_chest_button.pressed.connect(_on_platinum_chest_button_pressed)

	EventBus.on_chest_opened.connect(_on_chest_opened)
	EventBus.on_gems_changed.connect(_on_gems_changed)

	_update_button_availability(GameManager.gems)


func _on_standard_chest_button_pressed() -> void:
	ChestSystem.open_chest(ChestConfig.ChestType.STANDARD)


func _on_gold_chest_button_pressed() -> void:
	ChestSystem.open_chest(ChestConfig.ChestType.GOLD)


func _on_platinum_chest_button_pressed() -> void:
	ChestSystem.open_chest(ChestConfig.ChestType.PLATINUM)


func _on_chest_opened(_chest_type: String, items: Array) -> void:
	_last_drop_label.text = _format_dropped_items(items)


func _on_gems_changed(new_amount: int) -> void:
	_update_button_availability(new_amount)


func _format_dropped_items(items: Array) -> String:
	if items.is_empty():
		return "No items dropped."

	var lines: Array[String] = []
	for item: Variant in items:
		if item is ItemConfig:
			var rarity_name: String = ItemConfig.Rarity.keys()[item.rarity]
			lines.append("%s (%s)" % [item.item_name, rarity_name])

	return "\n".join(lines)


func _update_button_availability(gem_amount: int) -> void:
	_standard_chest_button.disabled = gem_amount < ChestSystem.get_chest_cost(ChestConfig.ChestType.STANDARD)
	_gold_chest_button.disabled = gem_amount < ChestSystem.get_chest_cost(ChestConfig.ChestType.GOLD)
	_platinum_chest_button.disabled = gem_amount < ChestSystem.get_chest_cost(ChestConfig.ChestType.PLATINUM)
