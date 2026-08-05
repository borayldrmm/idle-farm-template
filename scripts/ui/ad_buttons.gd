class_name AdButtons
extends HBoxContainer
## UI buttons for watching rewarded ads: one grants a temporary 2x
## production boost, the other instantly grants offline progress.
##
## AdButtons is purely a view: it requests ads through AdManager and,
## on success, hands the actual reward off to RewardSystem or
## ResourceManager. It also mirrors AdManager's rewarded-ad cooldown
## by periodically re-checking readiness and disabling both buttons
## while no ad is available.

const COOLDOWN_POLL_INTERVAL_SECONDS: float = 1.0
const COUNTDOWN_TICK_SECONDS: float = 1.0

@onready var _boost_button: Button = $BoostButton
@onready var _speed_up_button: Button = $SpeedUpButton
@onready var _boost_time_label: Label = $BoostTimeLabel

var _resource_manager: ResourceManager
var _boost_seconds_remaining: float = 0.0
var _countdown_timer: Timer


func _ready() -> void:
	_boost_button.pressed.connect(_on_boost_button_pressed)
	_speed_up_button.pressed.connect(_on_speed_up_button_pressed)

	EventBus.on_boost_started.connect(_on_boost_started)
	EventBus.on_boost_ended.connect(_on_boost_ended)
	EventBus.on_rewarded_ad_completed.connect(_update_button_availability)
	EventBus.on_ad_failed.connect(_update_button_availability)

	_boost_time_label.visible = false
	_start_countdown_timer()
	_start_cooldown_poll_timer()
	_update_button_availability()


## Injects the ResourceManager the Speed Up button grants offline
## progress on. Must be called before the button is usable.
func setup(resource_manager: ResourceManager) -> void:
	_resource_manager = resource_manager


func _on_boost_button_pressed() -> void:
	AdManager.show_rewarded_ad(func(success: bool) -> void:
		if success:
			RewardSystem.apply_2x_boost(GameManager.config.boost_duration_seconds)
	)


func _on_speed_up_button_pressed() -> void:
	AdManager.show_rewarded_ad(func(success: bool) -> void:
		if success and _resource_manager != null:
			_resource_manager.apply_offline_progress()
	)


func _on_boost_started(duration_seconds: float) -> void:
	_boost_seconds_remaining = duration_seconds
	_boost_time_label.visible = true
	_update_boost_time_label()
	_countdown_timer.start()


func _on_boost_ended() -> void:
	_boost_time_label.visible = false
	_countdown_timer.stop()


func _start_countdown_timer() -> void:
	_countdown_timer = Timer.new()
	_countdown_timer.wait_time = COUNTDOWN_TICK_SECONDS
	_countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(_countdown_timer)


func _on_countdown_tick() -> void:
	_boost_seconds_remaining = max(0.0, _boost_seconds_remaining - COUNTDOWN_TICK_SECONDS)
	_update_boost_time_label()


func _update_boost_time_label() -> void:
	_boost_time_label.text = "Boost: %ds left" % int(ceil(_boost_seconds_remaining))


func _start_cooldown_poll_timer() -> void:
	var cooldown_poll_timer: Timer = Timer.new()
	cooldown_poll_timer.wait_time = COOLDOWN_POLL_INTERVAL_SECONDS
	cooldown_poll_timer.autostart = true
	cooldown_poll_timer.timeout.connect(_update_button_availability)
	add_child(cooldown_poll_timer)


func _update_button_availability() -> void:
	var is_ready: bool = AdManager.is_ad_ready(AdManager.AdType.REWARDED)
	_boost_button.disabled = not is_ready
	_speed_up_button.disabled = not is_ready
