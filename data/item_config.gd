class_name ItemConfig
extends Resource
## Defines a single droppable item: its identity, rarity, and the
## gameplay effect it grants when owned.
##
## ChestSystem rolls ItemConfig instances as chest rewards;
## GameManager stores which ones the player owns. New items are added
## by creating additional .tres instances of this resource in
## data/items/ — no code changes required.

enum Rarity { COMMON, RARE, LEGENDARY }
enum EffectType { PRODUCTION_BOOST, OFFLINE_BOOST, GEM_BONUS }

@export_group("Identity")

## Display name of the item.
@export var item_name: String = "Item"

## Player-facing description of what the item does.
@export var description: String = ""

@export_group("Rarity")

## How rare this item is. Drives which chest drop-weight bucket it
## belongs to.
@export var rarity: Rarity = Rarity.COMMON

@export_group("Effect")

## Which gameplay system this item's effect modifies.
@export var effect_type: EffectType = EffectType.PRODUCTION_BOOST

## Magnitude of the effect. Interpretation depends on effect_type
## (e.g. a fractional multiplier for PRODUCTION_BOOST/OFFLINE_BOOST,
## a flat amount for GEM_BONUS).
@export var effect_amount: float = 0.0
