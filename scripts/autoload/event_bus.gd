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
