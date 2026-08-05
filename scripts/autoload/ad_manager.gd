extends Node
## Global ad-serving singleton (autoload).
##
## AdManager is the single entry point game systems use to request
## ads. It owns rewarded-ad cooldown tracking and the "ads removed"
## IAP flag, and delegates actual ad presentation to an AdProvider so
## a real SDK integration (AdMob, etc.) can replace MockAdProvider in
## production without any caller changing — see [method set_provider].

enum AdType { REWARDED, INTERSTITIAL }

## True once the player owns the remove-ads IAP. While true,
## show_rewarded_ad() and show_interstitial_ad() both no-op.
var is_ads_removed: bool = false

var _provider: AdProvider = MockAdProvider.new()
var _last_rewarded_ad_timestamp: int = 0


## Swaps in a different AdProvider (e.g. a real SDK wrapper) in place
## of the default mock. Intended to be called once during app startup,
## before any ad is requested.
func set_provider(provider: AdProvider) -> void:
	_provider = provider


## Returns true if an ad of [param ad_type] can be shown right now —
## ads must not be removed, and, for rewarded ads, the cooldown must
## have elapsed and the provider must report readiness.
func is_ad_ready(ad_type: AdType) -> bool:
	if is_ads_removed:
		return false

	if ad_type == AdType.REWARDED and _is_rewarded_ad_on_cooldown():
		return false

	return _provider.is_ad_ready(ad_type)


## Requests a rewarded ad. [param on_finished] is called exactly once
## with [code]true[/code] if the player earned the reward, or
## [code]false[/code] if ads are removed, the cooldown hasn't elapsed,
## or the ad failed. The outcome is also reported via EventBus.
func show_rewarded_ad(on_finished: Callable) -> void:
	if not is_ad_ready(AdType.REWARDED):
		_complete_rewarded_ad(false, on_finished)
		return

	_provider.show_rewarded_ad(func(success: bool) -> void:
		_complete_rewarded_ad(success, on_finished)
	)


## Requests an interstitial ad. No-ops (and reports failure via
## EventBus) if ads are removed or none is ready.
func show_interstitial_ad() -> void:
	if not is_ad_ready(AdType.INTERSTITIAL):
		EventBus.on_ad_failed.emit(AdType.INTERSTITIAL)
		return

	_provider.show_interstitial_ad()


func _complete_rewarded_ad(success: bool, on_finished: Callable) -> void:
	if success:
		_last_rewarded_ad_timestamp = int(Time.get_unix_time_from_system())
		EventBus.on_rewarded_ad_completed.emit()
	else:
		EventBus.on_ad_failed.emit(AdType.REWARDED)

	if on_finished.is_valid():
		on_finished.call(success)


func _is_rewarded_ad_on_cooldown() -> bool:
	if _last_rewarded_ad_timestamp <= 0:
		return false

	var elapsed_seconds: float = Time.get_unix_time_from_system() - _last_rewarded_ad_timestamp
	return elapsed_seconds < GameManager.config.rewarded_ad_cooldown_seconds
