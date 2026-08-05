class_name AdProvider
extends RefCounted
## Abstract interface for an ad backend.
##
## AdManager depends on this abstraction rather than on a concrete ad
## SDK, so the mock implementation used during development
## (MockAdProvider) can be swapped for a real SDK plugin wrapper (e.g.
## AdMob) in production via [method AdManager.set_provider] without
## AdManager or any of its callers changing.
##
## Subclasses must override every method below.

## Returns true if an ad of [param ad_type] (an AdManager.AdType
## value) is currently available to show.
func is_ad_ready(_ad_type: int) -> bool:
	push_error("AdProvider: is_ad_ready() not implemented")
	return false


## Requests a rewarded ad. Must call [param on_finished] exactly once
## with [code]true[/code] if the player watched it to completion, or
## [code]false[/code] if it failed or was skipped.
func show_rewarded_ad(on_finished: Callable) -> void:
	push_error("AdProvider: show_rewarded_ad() not implemented")
	on_finished.call(false)


## Requests an interstitial ad. Fire-and-forget — no completion
## callback, matching how interstitials are typically consumed.
func show_interstitial_ad() -> void:
	push_error("AdProvider: show_interstitial_ad() not implemented")
