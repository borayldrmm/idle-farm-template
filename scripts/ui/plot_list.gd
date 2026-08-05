class_name PlotList
extends VBoxContainer
## Hosts one FarmPlotCard per active farm plot.
##
## PlotList only knows how to instantiate and add cards — it has no
## knowledge of where FarmPlot instances come from. Callers (main.gd)
## are responsible for creating plots and registering them here.

const FARM_PLOT_CARD_SCENE: PackedScene = preload("res://scenes/ui/farm_plot_card.tscn")


## Instantiates a FarmPlotCard bound to [param plot] and adds it to
## the list.
func add_plot_card(plot: FarmPlot) -> void:
	var card: FarmPlotCard = FARM_PLOT_CARD_SCENE.instantiate()
	add_child(card)
	card.setup(plot)
