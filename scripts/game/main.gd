extends Node2D
## Manual test harness for the core loop (FarmPlot, UpgradeSystem,
## ResourceManager).
##
## Spawns a handful of plots, applies any offline progress, then
## prints coin balance and total production rate on an interval. No
## UI — verification is done by reading the output console. Not part
## of the shipping game; replace with real UI once it exists.

const FARM_PLOT_COUNT := 3
const PRINT_INTERVAL_SECONDS := 5.0
const FARM_CONFIG_PATH := "res://data/farm_config.tres"

@onready var _resource_manager: ResourceManager = $ResourceManager


func _ready() -> void:
	_spawn_farm_plots()
	_apply_offline_progress()
	_start_status_timer()


## Creates [constant FARM_PLOT_COUNT] plots using the default
## FarmConfig and registers each with the ResourceManager.
func _spawn_farm_plots() -> void:
	var farm_config: FarmConfig = load(FARM_CONFIG_PATH) as FarmConfig

	for i: int in range(FARM_PLOT_COUNT):
		var plot: FarmPlot = FarmPlot.new()
		plot.name = "FarmPlot%d" % (i + 1)
		plot.config = farm_config
		add_child(plot)
		_resource_manager.register_plot(plot)


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
