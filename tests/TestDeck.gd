extends Node

func _ready() -> void:
	run_tests()
	print("All Deck tests passed successfully!")

func run_tests() -> void:
	# Test 1: Standard deck card count (108 cards total)
	var deck = Deck.new()
	assert(deck.card_count() == Constants.STANDARD_DECK_SIZE, "Standard deck must contain exactly 108 cards (got %d)" % deck.card_count())
	assert(!deck.is_empty(), "Deck must not be empty initially")

	# Test 2: Card counts per color (25 cards each: 1 zero, 18 numbers, 2 skip, 2 reverse, 2 draw two)
	for color in Constants.COLORS:
		var color_count = deck.count_by_color(color)
		assert(color_count == 25, "Color %s must have 25 cards (got %d)" % [Constants.COLOR_NAMES[color], color_count])

		# Exactly 1 '0' card per color
		var zero_count = 0
		for c in deck.cards:
			if c.color == color and c.card_type == Constants.CardType.NUMBER_0:
				zero_count += 1
		assert(zero_count == 1, "Color %s must have exactly 1 zero card (got %d)" % [Constants.COLOR_NAMES[color], zero_count])

		# Exactly 2 of each number 1-9 per color
		for num in range(1, 10):
			var num_count = 0
			var expected_type = num as Constants.CardType
			for c in deck.cards:
				if c.color == color and c.card_type == expected_type:
					num_count += 1
			assert(num_count == 2, "Color %s number %d must appear 2 times (got %d)" % [Constants.COLOR_NAMES[color], num, num_count])

		# Exactly 2 Skip cards per color
		var skip_count = 0
		for c in deck.cards:
			if c.color == color and c.card_type == Constants.CardType.SKIP:
				skip_count += 1
		assert(skip_count == 2, "Color %s must have 2 Skip cards (got %d)" % [Constants.COLOR_NAMES[color], skip_count])

		# Exactly 2 Reverse cards per color
		var reverse_count = 0
		for c in deck.cards:
			if c.color == color and c.card_type == Constants.CardType.REVERSE:
				reverse_count += 1
		assert(reverse_count == 2, "Color %s must have 2 Reverse cards (got %d)" % [Constants.COLOR_NAMES[color], reverse_count])

		# Exactly 2 Draw Two cards per color
		var draw2_count = 0
		for c in deck.cards:
			if c.color == color and c.card_type == Constants.CardType.DRAW_TWO:
				draw2_count += 1
		assert(draw2_count == 2, "Color %s must have 2 Draw Two cards (got %d)" % [Constants.COLOR_NAMES[color], draw2_count])

	# Test 3: Wild cards represented correctly
	var wild_count = deck.count_by_type(Constants.CardType.WILD)
	assert(wild_count == 4, "Must have 4 Wild cards (got %d)" % wild_count)

	var wild_draw4_count = deck.count_by_type(Constants.CardType.WILD_DRAW_FOUR)
	assert(wild_draw4_count == 4, "Must have 4 Wild Draw Four cards (got %d)" % wild_draw4_count)

	assert(deck.count_wilds() == 8, "Must have 8 total wild cards (got %d)" % deck.count_wilds())

	# Verify every wild card has color == CardColor.WILD and is_wild() == true
	for c in deck.cards:
		if c.is_wild():
			assert(c.color == Constants.CardColor.WILD, "Wild cards must have WILD color")
			assert(c.is_wild(), "is_wild() must be true")

	# Test 4: Repeated creation produces independent instances without shared mutable state
	var deck1 = Deck.new()
	var deck2 = Deck.new()
	assert(deck1.card_count() == 108, "Deck 1 should have 108 cards")
	assert(deck2.card_count() == 108, "Deck 2 should have 108 cards")

	# Mutate deck1 - draw a card
	var drawn1 = deck1.draw()
	assert(deck1.card_count() == 107, "Deck 1 should now have 107 cards")
	assert(deck2.card_count() == 108, "Deck 2 must still have 108 cards (no shared mutable state)")

	# Mutate a card in deck1 - ensure deck2's card is not mutated
	drawn1.value = 99
	for c in deck2.cards:
		assert(c.value != 99, "Deck 2 cards must be distinct instances from Deck 1")

	# Test 5: Shuffle changes order
	var unshuffled = Deck.new()
	var shuffled = Deck.new()
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	shuffled.shuffle(rng)

	assert(shuffled.card_count() == 108, "Shuffled deck must still have 108 cards")

	var differences = 0
	for i in range(108):
		if !shuffled.cards[i].is_same_as(unshuffled.cards[i]):
			differences += 1
	assert(differences > 50, "Shuffling should change the card order significantly (got %d diffs)" % differences)

	# Test 6: Drawing removes cards from the draw pile
	var test_draw_deck = Deck.new()
	var initial_count = test_draw_deck.card_count()
	var card_drawn = test_draw_deck.draw()
	assert(card_drawn != null, "Drawing from non-empty deck should return a Card")
	assert(test_draw_deck.card_count() == initial_count - 1, "Drawing should decrement card count")

	# Test 7: Drawing from an empty pile is handled explicitly (returns null)
	var empty_deck = Deck.new(false)
	assert(empty_deck.is_empty(), "Empty deck should report is_empty")
	assert(empty_deck.card_count() == 0, "Empty deck should have 0 cards")
	var null_card = empty_deck.draw()
	assert(null_card == null, "Drawing from empty deck must return null without crashing")

	# Test 8: draw_cards multiple cards
	var draw_multi_deck = Deck.new()
	var hand = draw_multi_deck.draw_cards(Constants.INITIAL_HAND_SIZE)
	assert(hand.size() == 7, "Should draw initial hand of 7 cards")
	assert(draw_multi_deck.card_count() == 108 - 7, "Deck should have 101 cards remaining")
