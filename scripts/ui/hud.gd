class_name HUD
extends HBoxContainer
## Heads-up display: shows the player's coin and gem balances.
##
## HUD is purely a view over GameManager's currency state — it reads
## the starting balances on ready and reacts to EventBus signals to
## stay current. It never mutates game state.

@onready var _coin_label: Label = $CoinLabel
@onready var _gem_label: Label = $GemLabel


func _ready() -> void:
	EventBus.on_coins_changed.connect(_on_coins_changed)
	EventBus.on_gems_changed.connect(_on_gems_changed)

	_update_coin_label(GameManager.coins)
	_update_gem_label(GameManager.gems)


func _on_coins_changed(new_amount: int) -> void:
	_update_coin_label(new_amount)


func _on_gems_changed(new_amount: int) -> void:
	_update_gem_label(new_amount)


func _update_coin_label(amount: int) -> void:
	_coin_label.text = "Coins: %d" % amount


func _update_gem_label(amount: int) -> void:
	_gem_label.text = "Gems: %d" % amount
