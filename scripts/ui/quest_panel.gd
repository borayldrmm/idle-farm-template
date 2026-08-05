class_name QuestPanel
extends PanelContainer
## Quest list UI: shows daily and weekly quests in separate tabs and
## keeps each QuestCard in sync with QuestManager via EventBus.
##
## QuestPanel owns the mapping from quest_id to its QuestCard so that
## EventBus progress/completion signals — which only carry a quest_id
## — can be routed to the right card without every card needing its
## own EventBus subscription.

const QUEST_CARD_SCENE: PackedScene = preload("res://scenes/ui/quest_card.tscn")

@onready var _daily_list: VBoxContainer = $Content/Tabs/Daily
@onready var _weekly_list: VBoxContainer = $Content/Tabs/Weekly

var _cards_by_quest_id: Dictionary = {}


func _ready() -> void:
	EventBus.on_quest_progress_updated.connect(_on_quest_progress_updated)
	EventBus.on_quest_completed.connect(_on_quest_completed)

	_populate_quest_list(QuestConfig.QuestType.DAILY, _daily_list)
	_populate_quest_list(QuestConfig.QuestType.WEEKLY, _weekly_list)


func _populate_quest_list(quest_type: QuestConfig.QuestType, container: VBoxContainer) -> void:
	for config: QuestConfig in QuestManager.get_quests(quest_type):
		var card: QuestCard = QUEST_CARD_SCENE.instantiate()
		container.add_child(card)

		var current_progress: float = QuestManager.get_quest_progress(config.quest_id)
		var is_claimed: bool = QuestManager.is_quest_claimed(config.quest_id)
		card.setup(config, current_progress, is_claimed)

		_cards_by_quest_id[config.quest_id] = card


func _on_quest_progress_updated(quest_id: String, current: float, target: float) -> void:
	var card: QuestCard = _cards_by_quest_id.get(quest_id) as QuestCard
	if card != null:
		card.update_progress(current, target)


func _on_quest_completed(quest_id: String, _reward_type: String, _reward_amount: int) -> void:
	var card: QuestCard = _cards_by_quest_id.get(quest_id) as QuestCard
	if card != null:
		card.mark_completed()
