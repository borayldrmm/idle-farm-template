class_name ChestConfig
extends Resource
## Cost and item-drop parameters for one chest tier.
##
## Each ChestConfig resource describes one chest tier (standard, gold,
## platinum — see data/chests/ for the default instances). ChestSystem
## reads these values to price a chest open and roll its item drops.
## New tiers can be added by creating additional .tres instances of
## this resource — no code changes required.

enum ChestType { STANDARD, GOLD, PLATINUM }

@export_group("Identity")

## Which chest tier this resource describes.
@export var chest_type: ChestType = ChestType.STANDARD

@export_group("Cost")

## Gem cost to open this chest.
@export var gem_cost: int = 50

@export_group("Item Drops")

## Minimum number of items dropped per open.
@export var min_item_drops: int = 1

## Maximum number of items dropped per open.
@export var max_item_drops: int = 2

## Relative weights for [Common, Rare, Legendary], in that order,
## matching ItemConfig.Rarity. Weights don't need to sum to 1 — they
## are normalized at roll time.
@export var rarity_weights: Array[float] = [80.0, 18.0, 2.0]
