class_name Deck
extends RefCounted

## Manages an UNO deck / draw pile.
## In standard UNO, a fresh deck consists of 108 cards:
## - 4 suits (Red, Yellow, Blue, Green), each having 25 cards:
##   - 1 '0' card
##   - 2 each of '1' through '9' (18 cards)
##   - 2 Skip cards
##   - 2 Reverse cards
##   - 2 Draw Two cards
##   (25 * 4 = 100 colored cards)
## - 4 Wild cards
## - 4 Wild Draw Four cards
## Total: 108 cards.

var cards: Array[Card] = []

func _init(auto_build: bool = true) -> void:
	if auto_build:
		build_standard_deck()

## Builds a fresh standard 108-card UNO deck.
## Creates brand-new Card instances so there is no shared mutable state.
func build_standard_deck() -> void:
	cards.clear()
	cards = create_standard_cards()

## Static factory that returns a fresh Array[Card] with the standard 108 UNO cards.
## Can be called repeatedly without shared mutable state.
static func create_standard_cards() -> Array[Card]:
	var result: Array[Card] = []

	# For each of the 4 colors:
	for color in Constants.COLORS:
		# 1 '0' card
		result.append(Card.create_number(color, 0))

		# 2 each of '1' through '9'
		for num in range(1, 10):
			result.append(Card.create_number(color, num))
			result.append(Card.create_number(color, num))

		# 2 Skip cards
		result.append(Card.create_action(color, Constants.CardType.SKIP))
		result.append(Card.create_action(color, Constants.CardType.SKIP))

		# 2 Reverse cards
		result.append(Card.create_action(color, Constants.CardType.REVERSE))
		result.append(Card.create_action(color, Constants.CardType.REVERSE))

		# 2 Draw Two cards
		result.append(Card.create_action(color, Constants.CardType.DRAW_TWO))
		result.append(Card.create_action(color, Constants.CardType.DRAW_TWO))

	# 4 Wild cards
	for _i in range(4):
		result.append(Card.create_wild())

	# 4 Wild Draw Four cards
	for _i in range(4):
		result.append(Card.create_wild_draw_four())

	return result

## Returns the number of cards currently in the deck.
func card_count() -> int:
	return cards.size()

## Returns true if the deck has no cards.
func is_empty() -> bool:
	return cards.is_empty()

## Shuffles the deck cards in-place using Fisher-Yates algorithm.
## An optional RandomNumberGenerator can be provided for deterministic tests.
func shuffle(rng: RandomNumberGenerator = null) -> void:
	if cards.is_empty():
		return
	var n: int = cards.size()
	for i in range(n - 1, 0, -1):
		var j: int
		if rng != null:
			j = rng.randi_range(0, i)
		else:
			j = randi() % (i + 1)
		var tmp: Card = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp

## Draws the top card from the deck.
## Returns null if the deck is empty (explicitly handled).
func draw() -> Card:
	if cards.is_empty():
		return null
	return cards.pop_back()

## Draws multiple cards from the deck.
## Returns an array containing the drawn cards (up to count, or fewer if empty).
func draw_cards(count: int) -> Array[Card]:
	var drawn: Array[Card] = []
	for _i in range(count):
		var c: Card = draw()
		if c == null:
			break
		drawn.append(c)
	return drawn

## Adds a card to the bottom of the deck (or top if to_top is true).
func add_card(card: Card, to_top: bool = false) -> void:
	if card == null:
		return
	if to_top:
		cards.append(card)
	else:
		cards.push_front(card)

## Adds multiple cards to the deck.
func add_cards(new_cards: Array[Card], to_top: bool = false) -> void:
	for c in new_cards:
		add_card(c, to_top)

## Returns a shallow clone of the deck with copies of the card references,
## or deep clone if deep is true.
func clone(deep: bool = false) -> Deck:
	var new_deck: Deck = Deck.new(false)
	if deep:
		for c in cards:
			new_deck.cards.append(Card.from_dict(c.to_dict()))
	else:
		new_deck.cards = cards.duplicate()
	return new_deck

## Counts cards matching a specific color.
func count_by_color(target_color: Constants.CardColor) -> int:
	var count: int = 0
	for c in cards:
		if c.color == target_color:
			count += 1
	return count

## Counts cards matching a specific card type.
func count_by_type(target_type: Constants.CardType) -> int:
	var count: int = 0
	for c in cards:
		if c.card_type == target_type:
			count += 1
	return count

## Counts wild cards (Wild and Wild Draw Four).
func count_wilds() -> int:
	var count: int = 0
	for c in cards:
		if c.is_wild():
			count += 1
	return count

## Replenishes this deck from eligible cards in the discard pile.
## Preserves the discard pile's active top card and active color.
func replenish_from_discard(discard_pile: DiscardPile, rng: RandomNumberGenerator = null) -> int:
	if discard_pile == null:
		return 0
	return discard_pile.replenish_deck(self, rng)

