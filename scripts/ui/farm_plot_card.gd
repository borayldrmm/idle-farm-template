class_name FarmPlotCard
extends PanelContainer
## UI card showing a single FarmPlot's name, level, production rate,
## and upgrade cost, with a button to upgrade it.
##
## FarmPlotCard is purely a view: it reads FarmPlot/UpgradeSystem state
## to render itself and forwards the Upgrade button to UpgradeSystem.
## It never mutates game state directly.

@onready var _plot_name_label: Label = $Content/PlotNameLabel
@onready var _production_label: Label = $Content/ProductionLabel
@onready var _cost_label: Label = $Content/CostLabel
@onready var _upgrade_button: Button = $Content/UpgradeButton

var _plot: FarmPlot


func _ready() -> void:
	_upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	EventBus.on_resource_produced.connect(_on_resource_produced)


## Binds this card to [param plot] and refreshes its display.
func setup(plot: FarmPlot) -> void:
	_plot = plot
	_refresh_display()


func _on_upgrade_button_pressed() -> void:
	if _plot == null:
		return
	UpgradeSystem.try_upgrade(_plot)
	_refresh_display()


func _on_resource_produced(_resource_type: String, _amount: float) -> void:
	_refresh_display()


func _refresh_display() -> void:
	if _plot == null:
		return

	_plot_name_label.text = "%s - Lv. %d" % [_plot.name, _plot.level]
	_production_label.text = "%.2f coin/sec" % _plot.get_production_rate()
	_cost_label.text = "Upgrade cost: %d" % UpgradeSystem.get_upgrade_cost(_plot)
