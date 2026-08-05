class_name FarmConfig
extends Resource
## Base production and upgrade-cost stats for a farm plot type.
##
## Each FarmConfig resource describes the tunable stats of one plot
## type (see data/farm_config.tres for the default instance).
## FarmPlot reads [member base_production_rate] to compute its output;
## UpgradeSystem reads the upgrade-cost fields to price level-ups.
## New plot types can be added later by creating additional .tres
## instances of this resource — no code changes required.

@export_group("Production")

## Coins produced per second at level 1.
@export var base_production_rate: float = 1.0

@export_group("Upgrade Cost")

## Coin cost to upgrade from level 1 to level 2.
@export var base_upgrade_cost: int = 50

## Multiplier applied to the upgrade cost per additional level.
## cost(level) = base_upgrade_cost * upgrade_cost_multiplier^(level - 1)
@export var upgrade_cost_multiplier: float = 1.15
