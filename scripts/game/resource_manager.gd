class_name ResourceManager
extends Node
## Owns and coordinates every FarmPlot in the game.
##
## ResourceManager is the aggregate root for production: it tracks all
## active plots, reports the combined production rate, and grants
## offline progress earned while the game wasn't running. It does not
## know how a single plot computes its own rate — that stays inside
## FarmPlot.

## All farm plots currently registered with this manager.
var _plots: Array[FarmPlot] = []


## Registers [param plot] so its production counts toward the total.
func register_plot(plot: FarmPlot) -> void:
	if plot in _plots:
		return
	_plots.append(plot)


## Unregisters [param plot], e.g. when it is removed from the scene.
func unregister_plot(plot: FarmPlot) -> void:
	_plots.erase(plot)


## Returns the combined production rate, in resource units per
## second, across every registered plot.
func get_total_production_rate() -> float:
	var total: float = 0.0
	for plot in _plots:
		total += plot.get_production_rate()
	return total


## Grants coins for time elapsed since the last save while the game
## was closed, capped at config.max_offline_progress_seconds. Returns
## the number of coins granted.
func apply_offline_progress() -> int:
	var offline_seconds: float = _get_capped_offline_seconds()
	if offline_seconds <= 0.0:
		return 0

	var earned_coins: int = int(round(get_total_production_rate() * offline_seconds))
	if earned_coins > 0:
		GameManager.add_coins(earned_coins)

	return earned_coins


## Returns how many seconds have elapsed since GameManager's last save,
## capped at the configured offline progress limit. Returns 0 if there
## is no prior save to measure from.
func _get_capped_offline_seconds() -> float:
	var last_save_timestamp: int = GameManager.last_save_timestamp
	if last_save_timestamp <= 0:
		return 0.0

	var now: float = Time.get_unix_time_from_system()
	var elapsed_seconds: float = max(0.0, now - last_save_timestamp)
	return min(elapsed_seconds, GameManager.config.max_offline_progress_seconds)
