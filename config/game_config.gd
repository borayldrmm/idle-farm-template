class_name GameConfig
extends Resource
## Single source of truth for all game-tunable values.
##
## Every gameplay constant lives here instead of being hardcoded across
## the codebase. Properties are exported so designers can tweak them
## from the Inspector without touching code. [GameManager] owns the
## active instance of this resource; read values from there rather
## than instantiating [GameConfig] elsewhere.

@export_group("Game Info")

## Display name of the game, shown in UI and save metadata.
@export var game_name: String = "Idle Farm"

## Semantic version string of the current build.
@export var game_version: String = "0.1.0"

@export_group("Currency Names")

## Display name for the primary soft currency.
@export var coin_name: String = "Coin"

## Display name for the premium hard currency.
@export var gem_name: String = "Gem"

@export_group("Starting Resources")

## Amount of coins a new save starts with.
@export var starting_coins: int = 100

## Amount of gems a new save starts with.
@export var starting_gems: int = 1000

@export_group("Offline Progress")

## Maximum amount of offline production time the game will credit,
## in seconds. Defaults to 28800 seconds (8 hours).
@export var max_offline_progress_seconds: float = 28800.0

@export_group("Advertisement")

## Minimum time, in seconds, players must wait between watching
## rewarded ads. Used by AdManager's cooldown check.
@export var rewarded_ad_cooldown_seconds: float = 300.0

## Number of player actions between automatic interstitial ad
## opportunities.
@export var interstitial_ad_interval: int = 3

@export_group("Boost")

## Duration, in seconds, of the production boost granted by a
## completed rewarded ad.
@export var boost_duration_seconds: float = 120.0
