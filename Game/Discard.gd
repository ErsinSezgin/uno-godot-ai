class_name DiscardPile
extends RefCounted

## Placeholder for T007: Discard pile and reshuffle support.

var cards: Array[Card] = []
var top_card: Card = null

func is_empty() -> bool:
	return cards.is_empty()

func card_count() -> int:
	return cards.size()
