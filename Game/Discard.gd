class_name DiscardPile
extends RefCounted

## Manages the UNO discard pile.
## Tracks the active top card, active color (especially for Wild cards),
## and handles replenishing the draw pile from eligible discarded cards
## while preserving the active top card and active color state.

var cards: Array[Card] = []
var top_card: Card = null
var active_color: Constants.CardColor = Constants.CardColor.WILD

func _init(initial_cards: Array[Card] = []) -> void:
	if not initial_cards.is_empty():
		for c in initial_cards:
			discard(c)

## Returns true if the discard pile has no cards.
func is_empty() -> bool:
	return cards.is_empty()

## Returns the number of cards in the discard pile.
func card_count() -> int:
	return cards.size()

## Returns the current top card of the discard pile, or null if empty.
func get_top_card() -> Card:
	return top_card

## Returns the active color in play.
func get_active_color() -> Constants.CardColor:
	return active_color

## Explicitly sets the active color.
func set_active_color(new_color: Constants.CardColor) -> void:
	active_color = new_color

## Places a card on top of the discard pile.
## If chosen_color is specified (e.g. for Wild cards), active_color is set to it.
## If chosen_color is WILD or omitted:
## - For wild cards, active_color is set to WILD until chosen.
## - For colored cards, active_color is set to the card's color.
func discard(card: Card, chosen_color: int = Constants.CardColor.WILD) -> void:
	if card == null:
		return
	cards.append(card)
	top_card = card
	if card.is_wild():
		if chosen_color != Constants.CardColor.WILD:
			active_color = chosen_color as Constants.CardColor
		else:
			active_color = Constants.CardColor.WILD
	else:
		active_color = card.color

## Alias for discard.
func push_card(card: Card, chosen_color: int = Constants.CardColor.WILD) -> void:
	discard(card, chosen_color)

## Returns true if there are eligible discarded cards beneath the top card to replenish the draw pile.
func can_replenish() -> bool:
	return cards.size() > 1

## Extracts all cards beneath the active top card to be recycled.
## Preserves the active top card and keeps active_color intact.
## Resets wild card colors on recycled cards back to WILD so they can be reused cleanly.
func take_eligible_cards_for_reshuffle() -> Array[Card]:
	if cards.size() <= 1:
		return []

	var active_top: Card = cards.back()
	var eligible: Array[Card] = []

	for i in range(cards.size() - 1):
		var c: Card = cards[i]
		if c.is_wild():
			c.color = Constants.CardColor.WILD
		eligible.append(c)

	cards.clear()
	cards.append(active_top)
	top_card = active_top
	# active_color is preserved as-is

	return eligible

## Shuffles card array in place using Fisher-Yates.
static func _shuffle_cards(card_list: Array[Card], rng: RandomNumberGenerator = null) -> void:
	if card_list.is_empty():
		return
	var n: int = card_list.size()
	for i in range(n - 1, 0, -1):
		var j: int
		if rng != null:
			j = rng.randi_range(0, i)
		else:
			j = randi() % (i + 1)
		var tmp: Card = card_list[i]
		card_list[i] = card_list[j]
		card_list[j] = tmp

## Replenishes the provided Deck with eligible cards from this discard pile.
## Leaves the active top card on the discard pile with its active color preserved.
## Returns the count of cards added to the deck.
func replenish_deck(deck: Deck, rng: RandomNumberGenerator = null) -> int:
	if deck == null:
		return 0
	var recycled: Array[Card] = take_eligible_cards_for_reshuffle()
	if recycled.is_empty():
		return 0

	_shuffle_cards(recycled, rng)

	if deck.is_empty():
		deck.cards.clear()
		deck.cards.append_array(recycled)
	else:
		# Place recycled cards at the bottom (front) of the draw pile so current draw order is preserved
		var combined: Array[Card] = []
		combined.append_array(recycled)
		combined.append_array(deck.cards)
		deck.cards.clear()
		deck.cards.append_array(combined)

	return recycled.size()

## Clears the discard pile completely.
func clear() -> void:
	cards.clear()
	top_card = null
	active_color = Constants.CardColor.WILD

## Serializes the discard pile to a plain Dictionary.
func to_dict() -> Dictionary:
	var cards_data: Array = []
	for c in cards:
		cards_data.append(c.to_dict())
	return {
		"cards": cards_data,
		"top_card": top_card.to_dict() if top_card != null else null,
		"active_color": int(active_color),
	}

## Deserializes a DiscardPile from a Dictionary.
static func from_dict(data: Dictionary) -> DiscardPile:
	var pile = DiscardPile.new()
	var raw_cards: Array = data.get("cards", [])
	pile.cards.clear()
	for c_data in raw_cards:
		if c_data is Dictionary:
			pile.cards.append(Card.from_dict(c_data))
	if data.has("top_card") and data["top_card"] != null:
		pile.top_card = Card.from_dict(data["top_card"])
	elif not pile.cards.is_empty():
		pile.top_card = pile.cards.back()
	else:
		pile.top_card = null
	pile.active_color = data.get("active_color", Constants.CardColor.WILD) as Constants.CardColor
	return pile
