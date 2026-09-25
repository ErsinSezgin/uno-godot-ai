extends Node

func _ready() -> void:
	run_tests()
	print("All Discard tests passed successfully!")

func run_tests() -> void:
	# Test 1: Empty discard pile state
	var pile = DiscardPile.new()
	assert(pile.is_empty(), "Fresh discard pile should be empty")
	assert(pile.card_count() == 0, "Fresh discard pile should have 0 cards")
	assert(pile.get_top_card() == null, "Fresh discard pile top_card should be null")
	assert(pile.top_card == null, "Fresh discard pile top_card property should be null")
	assert(!pile.can_replenish(), "Empty discard pile cannot replenish")

	# Test 2: Discarding colored cards tracks top card and active color
	var red_5 = Card.create_number(Constants.CardColor.RED, 5)
	pile.discard(red_5)
	assert(!pile.is_empty(), "Discard pile should not be empty")
	assert(pile.card_count() == 1, "Discard pile should have 1 card")
	assert(pile.get_top_card() == red_5, "Top card should be red_5")
	assert(pile.top_card == red_5, "top_card property should be red_5")
	assert(pile.get_active_color() == Constants.CardColor.RED, "Active color should be RED")

	var blue_skip = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.SKIP)
	pile.discard(blue_skip)
	assert(pile.card_count() == 2, "Discard pile should have 2 cards")
	assert(pile.get_top_card() == blue_skip, "Top card should now be blue_skip")
	assert(pile.get_active_color() == Constants.CardColor.BLUE, "Active color should now be BLUE")

	# Test 3: Discarding Wild card with chosen color
	var wild = Card.create_wild()
	pile.discard(wild, Constants.CardColor.YELLOW)
	assert(pile.card_count() == 3, "Discard pile should have 3 cards")
	assert(pile.get_top_card() == wild, "Top card should be wild")
	assert(pile.get_active_color() == Constants.CardColor.YELLOW, "Active color should be YELLOW for wild card")
	assert(wild.is_wild(), "Card itself should remain wild")

	# Test 4: can_replenish check
	assert(pile.can_replenish(), "Discard pile with 3 cards can replenish")

	# Single card discard pile cannot replenish
	var single_pile = DiscardPile.new()
	single_pile.discard(red_5)
	assert(!single_pile.can_replenish(), "Discard pile with 1 card cannot replenish")
	var empty_deck = Deck.new(false)
	var replenished_count = single_pile.replenish_deck(empty_deck)
	assert(replenished_count == 0, "Replenish should return 0 when only 1 card in discard pile")
	assert(single_pile.card_count() == 1, "Single pile still has 1 card")
	assert(single_pile.get_top_card() == red_5, "Single pile top card preserved")

	# Test 5: Replenishing preserves active top card and active color
	# Setup: Pile with Green 2, Yellow 4, Red Skip, and top card Wild Draw Four (chosen color Green)
	var test_pile = DiscardPile.new()
	var g2 = Card.create_number(Constants.CardColor.GREEN, 2)
	var y4 = Card.create_number(Constants.CardColor.YELLOW, 4)
	var r_skip = Card.create_action(Constants.CardColor.RED, Constants.CardType.SKIP)
	var wd4 = Card.create_wild_draw_four()

	test_pile.discard(g2)
	test_pile.discard(y4)
	test_pile.discard(r_skip)
	test_pile.discard(wd4, Constants.CardColor.GREEN)

	assert(test_pile.card_count() == 4, "Test pile should have 4 cards")
	assert(test_pile.get_top_card() == wd4, "Top card should be wd4")
	assert(test_pile.get_active_color() == Constants.CardColor.GREEN, "Active color should be GREEN")

	var target_deck = Deck.new(false) # empty deck
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	var count = test_pile.replenish_deck(target_deck, rng)

	assert(count == 3, "Should replenish 3 eligible cards into deck")
	assert(test_pile.card_count() == 1, "Discard pile must now have exactly 1 card")
	assert(test_pile.get_top_card() == wd4, "Active top card must be preserved")
	assert(test_pile.top_card == wd4, "top_card property must be preserved")
	assert(test_pile.get_active_color() == Constants.CardColor.GREEN, "Wild active color (GREEN) must not be lost")
	assert(target_deck.card_count() == 3, "Target deck should now have 3 cards")

	# Test 6: Wild-card state needed for active color is not accidentally lost on recycled cards
	# Add a wild card underneath, let caller dirty its color, and verify reshuffle restores WILD color
	var pile_with_wild = DiscardPile.new()
	var old_wild = Card.create_wild()
	old_wild.color = Constants.CardColor.RED # caller or previous turn might have set color
	var top_card_blue = Card.create_number(Constants.CardColor.BLUE, 7)

	pile_with_wild.discard(old_wild)
	pile_with_wild.discard(top_card_blue)

	var draw_deck = Deck.new(false)
	pile_with_wild.replenish_deck(draw_deck)

	assert(pile_with_wild.card_count() == 1, "Pile should retain 1 top card")
	assert(pile_with_wild.get_top_card() == top_card_blue, "Top card is blue 7")
	assert(pile_with_wild.get_active_color() == Constants.CardColor.BLUE, "Active color is BLUE")

	# Verify recycled old_wild is back to CardColor.WILD
	assert(draw_deck.card_count() == 1, "Deck should have 1 card")
	var drawn_card = draw_deck.draw()
	assert(drawn_card.is_wild(), "Recycled card should be wild")
	assert(drawn_card.color == Constants.CardColor.WILD, "Recycled wild card color must be restored to WILD")

	# Test 7: Replenishing into deck with existing cards places recycled cards at bottom
	var deck_with_cards = Deck.new(false)
	var top_existing = Card.create_number(Constants.CardColor.RED, 1)
	deck_with_cards.add_card(top_existing, true) # on top

	var discard_to_recycle = DiscardPile.new()
	var bot1 = Card.create_number(Constants.CardColor.BLUE, 2)
	var bot2 = Card.create_number(Constants.CardColor.YELLOW, 3)
	var current_top = Card.create_number(Constants.CardColor.GREEN, 9)
	discard_to_recycle.discard(bot1)
	discard_to_recycle.discard(bot2)
	discard_to_recycle.discard(current_top)

	discard_to_recycle.replenish_deck(deck_with_cards)
	assert(deck_with_cards.card_count() == 3, "Deck should have 1 existing + 2 recycled cards")
	# Drawing from deck should yield the existing top card first
	var first_draw = deck_with_cards.draw()
	assert(first_draw == top_existing, "Existing card on top of deck should be drawn first")

	# Test 8: Deck.replenish_from_discard helper works seamlessly
	var deck8 = Deck.new(false)
	var pile8 = DiscardPile.new()
	pile8.discard(Card.create_number(Constants.CardColor.RED, 8))
	pile8.discard(Card.create_number(Constants.CardColor.RED, 9))
	var replenished = deck8.replenish_from_discard(pile8)
	assert(replenished == 1, "Deck.replenish_from_discard should replenish 1 card")
	assert(deck8.card_count() == 1, "Deck should now have 1 card")
	assert(pile8.card_count() == 1, "Pile should have 1 card remaining")

	# Test 9: Serialization round-trip (to_dict / from_dict)
	var serialize_pile = DiscardPile.new()
	serialize_pile.discard(Card.create_number(Constants.CardColor.YELLOW, 1))
	serialize_pile.discard(Card.create_wild(), Constants.CardColor.BLUE)

	var pile_dict = serialize_pile.to_dict()
	var restored_pile = DiscardPile.from_dict(pile_dict)
	assert(restored_pile.card_count() == 2, "Restored pile card count should match")
	assert(restored_pile.get_active_color() == Constants.CardColor.BLUE, "Restored active color should match")
	assert(restored_pile.get_top_card().is_wild(), "Restored top card should be wild")
