class_name QuestConfig
extends Resource
## Defines a single quest: its type, objective, target, and reward.
##
## QuestManager reads QuestConfig instances (see data/quests/ for the
## default daily/weekly quests) to track progress and grant rewards.
## New quests are added by creating additional .tres instances in
## data/quests/ — no code changes required.

enum QuestType { DAILY, WEEKLY }
enum ObjectiveType { COLLECT_COINS, UPGRADE_PLOT, OPEN_CHEST, REACH_PRODUCTION_RATE }
enum RewardType { COINS, GEMS }

@export_group("Identity")

## Unique identifier for this quest. Used by QuestManager to track
## progress/completion and referenced in EventBus signals.
@export var quest_id: String = ""

## Display name of the quest.
@export var quest_name: String = "Quest"

## Player-facing description of what the quest asks for.
@export var description: String = ""

@export_group("Type")

## Whether this quest resets daily or weekly.
@export var quest_type: QuestType = QuestType.DAILY

@export_group("Objective")

## What kind of progress this quest tracks.
@export var objective_type: ObjectiveType = ObjectiveType.COLLECT_COINS

## Amount of progress required to complete the quest. Interpretation
## depends on objective_type (coins collected, plots upgraded, chests
## opened, or a production rate to reach).
@export var target_amount: float = 0.0

@export_group("Reward")

## Which currency the reward is paid in.
@export var reward_type: RewardType = RewardType.COINS

## Amount of the reward currency granted on completion.
@export var reward_amount: int = 0
