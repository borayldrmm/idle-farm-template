class_name UpgradeSystem
extends RefCounted
## Calculates upgrade costs and orchestrates paying for and applying
## plot upgrades.
##
## UpgradeSystem knows how much an upgrade costs and how to pay for it
## through GameManager; it does not know how production rates are
## computed — that stays inside FarmPlot. Stateless by design, so its
## methods are exposed as static utilities rather than requiring an
## instance.

## Computes the coin cost to upgrade [param plot] from its current
## level to the next one.
static func get_upgrade_cost(plot: FarmPlot) -> int:
	return _calculate_cost(plot.config, plot.level)


## Attempts to upgrade [param plot] by one level.
## Spends coins through GameManager and only applies the level-up if
## payment succeeds. Returns [code]true[/code] if the upgrade happened.
static func try_upgrade(plot: FarmPlot) -> bool:
	var cost := get_upgrade_cost(plot)
	if not GameManager.spend_coins(cost):
		return false

	plot.level_up()
	EventBus.on_plot_upgraded.emit(plot.level)
	return true


## Computes cost(level) = base_upgrade_cost * upgrade_cost_multiplier^(level - 1),
## reading the formula's inputs from [param config].
static func _calculate_cost(config: FarmConfig, current_level: int) -> int:
	if config == null:
		push_error("UpgradeSystem: plot has no FarmConfig assigned, cannot compute cost")
		return 0

	var cost := config.base_upgrade_cost * pow(config.upgrade_cost_multiplier, current_level - 1)
	return int(round(cost))
