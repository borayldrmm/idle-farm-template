class_name QuestCard
extends PanelContainer
## UI card showing one quest's name, description, progress, and a
## Claim button.
##
## QuestCard is purely a view. It renders whatever QuestPanel pushes
## into it via [method update_progress] / [method mark_completed], and
## forwards the Claim button to QuestManager.complete_quest() — it
## does not update its own display on press, since the resulting
## EventBus.on_quest_completed round-trip (routed through QuestPanel)
## is what actually updates the card.

@onready var _quest_name_label: Label = $Content/QuestNameLabel
@onready var _description_label: Label = $Content/DescriptionLabel
@onready var _progress_label: Label = $Content/ProgressLabel
@onready var _progress_bar: ProgressBar = $Content/ProgressBar
@onready var _claim_button: Button = $Content/ClaimButton

var _quest_id: String = ""
var _objective_type: QuestConfig.ObjectiveType = QuestConfig.ObjectiveType.COLLECT_COINS


func _ready() -> void:
	_claim_button.pressed.connect(_on_claim_button_pressed)


## Binds this card to [param config] with its current
## [param current_progress] and [param is_claimed] state.
func setup(config: QuestConfig, current_progress: float, is_claimed: bool) -> void:
	_quest_id = config.quest_id
	_objective_type = config.objective_type

	_quest_name_label.text = config.quest_name
	_description_label.text = config.description

	update_progress(current_progress, config.target_amount)
	if is_claimed:
		mark_completed()


## Updates the progress label/bar and re-evaluates whether the Claim
## button should be enabled.
func update_progress(current_progress: float, target_amount: float) -> void:
	_progress_label.text = _format_progress_text(current_progress, target_amount)
	_progress_bar.value = _to_percentage(current_progress, target_amount)
	_claim_button.disabled = current_progress < target_amount


## Marks this quest as already claimed: disables the Claim button and
## shows it as done.
func mark_completed() -> void:
	_claim_button.disabled = true
	_claim_button.text = "Claimed"


func _on_claim_button_pressed() -> void:
	QuestManager.complete_quest(_quest_id)


func _format_progress_text(current_progress: float, target_amount: float) -> String:
	var unit_label: String = _get_progress_unit_label(_objective_type)
	return "%d/%d %s" % [int(round(current_progress)), int(round(target_amount)), unit_label]


func _get_progress_unit_label(objective_type: QuestConfig.ObjectiveType) -> String:
	match objective_type:
		QuestConfig.ObjectiveType.COLLECT_COINS:
			return "coins collected"
		QuestConfig.ObjectiveType.UPGRADE_PLOT:
			return "plots upgraded"
		QuestConfig.ObjectiveType.OPEN_CHEST:
			return "chests opened"
		QuestConfig.ObjectiveType.REACH_PRODUCTION_RATE:
			return "coins/sec reached"
		_:
			return "progress"


func _to_percentage(current_progress: float, target_amount: float) -> float:
	if target_amount <= 0.0:
		return 0.0
	return clamp(current_progress / target_amount * 100.0, 0.0, 100.0)
