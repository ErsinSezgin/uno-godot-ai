class_name Rules
extends RefCounted

## Pure UNO rule engine functions.
## Contains deterministic, UI-independent legality checks for playing cards.

## Evaluates whether `card` can legally be played given `top_card` and `active_color`.
## - Wild cards (Wild, Wild Draw Four) are always playable.
## - Matching the effective active color is legal.
## - Matching the top card's type / value (e.g. 5 on 5, Skip on Skip) is legal.
## - Any card not matching color or type is rejected.
static func is_card_legal(card: Card, top_card: Card, active_color: int = Constants.CardColor.WILD) -> bool:
	if card == null:
		return false

	# If there is no top card in play yet, any card is playable
	if top_card == null:
		return true

	# Wild cards can be played on any card
	if card.is_wild():
		return true

	# Determine the effective color to match.
	# If active_color is explicitly set to a standard color (RED, YELLOW, BLUE, GREEN),
	# that is the color to match. Otherwise fall back to top_card's color.
	var color_to_match: int = active_color
	if color_to_match == Constants.CardColor.WILD:
		color_to_match = top_card.color

	# Color match: if the card matches the active/top color
	if color_to_match != Constants.CardColor.WILD and card.color == color_to_match:
		return true

	# Type / value match:
	# Only non-wild top cards can be matched by type/value
	if not top_card.is_wild():
		# Number cards match by numeric value
		if card.is_number() and top_card.is_number():
			if card.value == top_card.value:
				return true

		# Action cards (Skip, Reverse, Draw Two) match by card type
		if card.is_action() and top_card.is_action():
			if card.card_type == top_card.card_type:
				return true

	return false

## Returns a filtered Array[Card] of cards in `hand` that are legally playable.
static func get_playable_cards(hand: Array[Card], top_card: Card, active_color: int = Constants.CardColor.WILD) -> Array[Card]:
	var playable: Array[Card] = []
	for c in hand:
		if is_card_legal(c, top_card, active_color):
			playable.append(c)
	return playable

## Returns true if the player has at least one legally playable card in `hand`.
static func has_legal_move(hand: Array[Card], top_card: Card, active_color: int = Constants.CardColor.WILD) -> bool:
	for c in hand:
		if is_card_legal(c, top_card, active_color):
			return true
	return false
