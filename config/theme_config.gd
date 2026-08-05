class_name ThemeConfig
extends Resource
## Single source of truth for the game's color palette.
##
## Every UI color should originate here instead of being hardcoded in
## scenes or scripts. assets/theme/main_theme.tres encodes the same
## palette as an actual Godot Theme resource, since Control nodes read
## styling from a Theme, not from a script — if you change a color
## here, update the matching StyleBox/font colors in main_theme.tres
## to keep the two in sync.

@export_group("Palette")

## Base background color behind all UI (see the Background ColorRect
## in main.tscn).
@export var background_color: Color = Color("#1a1a2e")

## Background color for panels (PanelContainer-based UI like
## ChestShop, QuestPanel, and cards).
@export var panel_color: Color = Color("#16213e")

## Accent color used for highlights and the progress bar fill.
@export var accent_color: Color = Color("#0f3460")

## Primary color for buttons.
@export var button_color: Color = Color("#e94560")

## Primary text color.
@export var text_color: Color = Color("#ffffff")

## Secondary/muted text color, for less prominent labels.
@export var text_secondary_color: Color = Color("#a8a8b3")

## Color used for positive/success feedback (e.g. completed quests).
@export var success_color: Color = Color("#4caf50")
