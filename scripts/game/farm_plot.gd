class_name FarmPlot
extends Node
## A single farm plot: an idle production unit that earns resources
## automatically on a fixed timer and can be leveled up to increase
## its output.
##
## FarmPlot only knows how to produce and level up — it has no
## knowledge of upgrade cost or affordability. UpgradeSystem is
## responsible for validating and paying for a level-up before calling
## [method level_up] on a plot.

## How often, in seconds, this plot produces resources.
const PRODUCTION_TICK_SECONDS := 1.0

## Base stats for this plot, assigned in the Inspector.
## See data/farm_config.tres for the default values.
@export var config: FarmConfig

## Type of resource this plot produces. Reported through
## EventBus.on_resource_produced so other systems can react to it.
@export var resource_type: String = "coin"

## Current upgrade level of this plot. Starts at 1.
var level: int = 1

## Resource units produced per second at the current level.
var production_rate: float = 0.0

var _production_timer: Timer


func _ready() -> void:
	_recalculate_production_rate()
	_start_production_timer()


## Increases this plot's level by one and recalculates its production
## rate. Does not touch currency — callers must handle payment first.
func level_up() -> void:
	level += 1
	_recalculate_production_rate()


## Returns this plot's current production rate, in resource units per
## second.
func get_production_rate() -> float:
	return production_rate


func _recalculate_production_rate() -> void:
	if config == null:
		push_error("FarmPlot: no FarmConfig assigned, cannot compute production rate")
		return
	production_rate = config.base_production_rate * level


func _start_production_timer() -> void:
	_production_timer = Timer.new()
	_production_timer.wait_time = PRODUCTION_TICK_SECONDS
	_production_timer.autostart = true
	_production_timer.timeout.connect(_on_production_tick)
	add_child(_production_timer)


func _on_production_tick() -> void:
	if production_rate <= 0.0:
		return

	if resource_type == "coin":
		GameManager.add_coins(int(round(production_rate)))

	EventBus.on_resource_produced.emit(resource_type, production_rate)
