class_name MockAdProvider
extends AdProvider
## Development stand-in for a real ad SDK.
##
## Simulates ads as always available and always completing
## successfully, so gameplay systems that depend on ads (rewards,
## boosts) can be built and tested before a real SDK plugin is
## integrated. Replace with a real AdProvider subclass in production.

func is_ad_ready(_ad_type: int) -> bool:
	return true


func show_rewarded_ad(on_finished: Callable) -> void:
	on_finished.call(true)


func show_interstitial_ad() -> void:
	pass
