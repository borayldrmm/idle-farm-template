extends Node
## Global signal bus (Observer pattern) for decoupled cross-system communication.
##
## Systems that need to react to game events — UI, audio, analytics,
## and so on — subscribe to these signals instead of holding direct
## references to GameManager or to each other. This keeps systems
## modular: any listener can be added or removed without the emitting
## system knowing it exists.
##
## Only authoritative systems (currently GameManager) should emit
## these signals. Everything else should treat EventBus as read-only.

## Emitted whenever the player's coin balance changes.
signal on_coins_changed(new_amount: int)

## Emitted whenever the player's gem balance changes.
signal on_gems_changed(new_amount: int)

## Emitted whenever an idle/production system produces a resource.
signal on_resource_produced(resource_type: String, amount: float)

## Emitted after the game state has been successfully saved to disk.
signal on_game_saved()

## Emitted after the game state has been successfully loaded from disk.
signal on_game_loaded()

## Emitted after a chest is opened, reporting the chest tier's name
## (e.g. "STANDARD") and the items that were rolled.
signal on_chest_opened(chest_type: String, items: Array)

## Emitted when a rewarded ad completes successfully and the player
## has earned their reward.
signal on_rewarded_ad_completed()

## Emitted when an ad could not be shown (removed, on cooldown, not
## ready, or failed). [param ad_type] is an AdManager.AdType value.
signal on_ad_failed(ad_type: int)

## Emitted when a production boost starts, reporting its duration in
## seconds.
signal on_boost_started(duration_seconds: float)

## Emitted when an active production boost ends.
signal on_boost_ended()

## Emitted whenever a FarmPlot finishes leveling up, reporting its new
## level. Drives QuestManager's UPGRADE_PLOT objective.
signal on_plot_upgraded(new_level: int)

## Emitted whenever a quest's progress changes.
signal on_quest_progress_updated(quest_id: String, current: float, target: float)

## Emitted when a quest's reward has been claimed. [param reward_type]
## is a QuestConfig.RewardType name (e.g. "COINS").
signal on_quest_completed(quest_id: String, reward_type: String, reward_amount: int)
