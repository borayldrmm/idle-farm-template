class_name RewardSystem
extends RefCounted
## Applies temporary production boosts, typically granted as a
## rewarded-ad payoff.
##
## RewardSystem never touches FarmPlot directly — it only announces
## the boost's start and end via EventBus. Every FarmPlot listens for
## those signals and adjusts its own production rate, which keeps
## RewardSystem decoupled from how many plots exist or where they
## live in the scene tree.

## Starts a 2x production boost for [param duration_seconds], then
## automatically ends it via a one-shot scene tree timer.
static func apply_2x_boost(duration_seconds: float) -> void:
	if duration_seconds <= 0.0:
		return

	EventBus.on_boost_started.emit(duration_seconds)

	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	var boost_timer: SceneTreeTimer = scene_tree.create_timer(duration_seconds)
	boost_timer.timeout.connect(_on_boost_timer_timeout)


static func _on_boost_timer_timeout() -> void:
	EventBus.on_boost_ended.emit()
