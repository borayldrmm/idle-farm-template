extends Node2D
## Manual test harness for the core loop (FarmPlot, UpgradeSystem,
## ResourceManager) and the UI that presents it.
##
## Spawns a handful of plots, wires each one into the plot list,
## applies any offline progress, then prints coin balance and total
## production rate on an interval as a console cross-check.

const FARM_PLOT_COUNT: int = 3
const PRINT_INTERVAL_SECONDS: float = 5.0
const FARM_CONFIG_PATH: String = "res://data/farm_config.tres"

@onready var _resource_manager: ResourceManager = $ResourceManager
@onready var _plot_list: PlotList = $CanvasLayer/Root/PlotScroll/PlotList
@onready var _ad_buttons: AdButtons = $CanvasLayer/Root/AdButtons
@onready var _save_button: Button = $CanvasLayer/Root/SaveButton


func _ready() -> void:
	_save_button.pressed.connect(GameManager.save_game)
	_ad_buttons.setup(_resource_manager)
	_spawn_farm_plots()
	_apply_offline_progress()
	_start_status_timer()


## Creates [constant FARM_PLOT_COUNT] plots using the default
## FarmConfig, registers each with the ResourceManager, and gives it
## a card in the plot list.
func _spawn_farm_plots() -> void:
	var farm_config: FarmConfig = load(FARM_CONFIG_PATH) as FarmConfig

	for i: int in range(FARM_PLOT_COUNT):
		var plot: FarmPlot = FarmPlot.new()
		plot.name = "FarmPlot%d" % (i + 1)
		plot.config = farm_config
		add_child(plot)
		_resource_manager.register_plot(plot)
		_plot_list.add_plot_card(plot)


## Grants coins earned while the game was closed, if any, and prints
## the result.
func _apply_offline_progress() -> void:
	var earned_coins: int = _resource_manager.apply_offline_progress()
	if earned_coins > 0:
		print("Offline progress: earned %d coins" % earned_coins)


func _start_status_timer() -> void:
	var status_timer: Timer = Timer.new()
	status_timer.wait_time = PRINT_INTERVAL_SECONDS
	status_timer.autostart = true
	status_timer.timeout.connect(_print_status)
	add_child(status_timer)


func _print_status() -> void:
	var total_rate: float = _resource_manager.get_total_production_rate()
	print("Coins: %d | Total production rate: %.2f/sec" % [GameManager.coins, total_rate])
