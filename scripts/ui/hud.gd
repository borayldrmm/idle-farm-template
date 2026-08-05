class_name HUD
extends CanvasLayer
## Heads-up display: shows coin/gem balances, hosts one FarmPlotCard
## per active farm plot, and exposes the Save Game action.
##
## HUD is purely a view over game state — it reads balances from
## GameManager and reacts to EventBus signals, and never mutates game
## state itself except by forwarding the Save Game button press to
## GameManager.save_game().

const FARM_PLOT_CARD_SCENE: PackedScene = preload("res://scenes/ui/farm_plot_card.tscn")

@onready var _coin_label: Label = $Root/TopBar/CoinLabel
@onready var _gem_label: Label = $Root/TopBar/GemLabel
@onready var _plot_list: VBoxContainer = $Root/PlotList
@onready var _save_button: Button = $Root/SaveButton


func _ready() -> void:
	EventBus.on_coins_changed.connect(_on_coins_changed)
	EventBus.on_gems_changed.connect(_on_gems_changed)
	_save_button.pressed.connect(_on_save_button_pressed)

	_update_coin_label(GameManager.coins)
	_update_gem_label(GameManager.gems)


## Instantiates a FarmPlotCard bound to [param plot] and adds it to
## the plot list.
func add_plot_card(plot: FarmPlot) -> void:
	var card: FarmPlotCard = FARM_PLOT_CARD_SCENE.instantiate()
	_plot_list.add_child(card)
	card.setup(plot)


func _on_coins_changed(new_amount: int) -> void:
	_update_coin_label(new_amount)


func _on_gems_changed(new_amount: int) -> void:
	_update_gem_label(new_amount)


func _on_save_button_pressed() -> void:
	GameManager.save_game()


func _update_coin_label(amount: int) -> void:
	_coin_label.text = "Coins: %d" % amount


func _update_gem_label(amount: int) -> void:
	_gem_label.text = "Gems: %d" % amount
