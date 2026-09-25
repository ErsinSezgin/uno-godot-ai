extends Node

func _ready() -> void:
	run_tests()
	print("All Rules tests passed successfully!")

func run_tests() -> void:
	# Test 1: Null card handling
	assert(!Rules.is_card_legal(null, null), "Null card should be rejected")
	var r5 = Card.create_number(Constants.CardColor.RED, 5)
	assert(!Rules.is_card_legal(null, r5), "Null card should be rejected against valid top card")

	# Test 2: Null top card allows any card
	assert(Rules.is_card_legal(r5, null), "Any card is playable on null top card")

	# Test 3: Same color works
	var r2 = Card.create_number(Constants.CardColor.RED, 2)
	assert(Rules.is_card_legal(r5, r2), "Red 5 should be playable on Red 2")
	var r_skip = Card.create_action(Constants.CardColor.RED, Constants.CardType.SKIP)
	assert(Rules.is_card_legal(r_skip, r5), "Red Skip should be playable on Red 5")
	var b_skip = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.SKIP)
	var b_draw2 = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.DRAW_TWO)
	assert(Rules.is_card_legal(b_draw2, b_skip), "Blue Draw Two should be playable on Blue Skip")

	# Test 4: Same type / value works across different colors
	var b5 = Card.create_number(Constants.CardColor.BLUE, 5)
	var y5 = Card.create_number(Constants.CardColor.YELLOW, 5)
	var g5 = Card.create_number(Constants.CardColor.GREEN, 5)
	assert(Rules.is_card_legal(b5, r5), "Blue 5 should be playable on Red 5")
	assert(Rules.is_card_legal(y5, r5), "Yellow 5 should be playable on Red 5")
	assert(Rules.is_card_legal(g5, r5), "Green 5 should be playable on Red 5")

	# Same action card type across different colors
	var g_skip = Card.create_action(Constants.CardColor.GREEN, Constants.CardType.SKIP)
	assert(Rules.is_card_legal(g_skip, b_skip), "Green Skip should be playable on Blue Skip")
	var r_rev = Card.create_action(Constants.CardColor.RED, Constants.CardType.REVERSE)
	var y_rev = Card.create_action(Constants.CardColor.YELLOW, Constants.CardType.REVERSE)
	assert(Rules.is_card_legal(y_rev, r_rev), "Yellow Reverse should be playable on Red Reverse")

	# Test 5: Wild works anywhere
	var wild = Card.create_wild()
	var wd4 = Card.create_wild_draw_four()
	assert(Rules.is_card_legal(wild, r5), "Wild should be playable on Red 5")
	assert(Rules.is_card_legal(wd4, b_skip), "Wild Draw Four should be playable on Blue Skip")
	assert(Rules.is_card_legal(wild, y_rev), "Wild should be playable on Yellow Reverse")
	assert(Rules.is_card_legal(wd4, wild), "Wild Draw Four should be playable on Wild")

	# Test 6: Invalid cards are rejected
	var y7 = Card.create_number(Constants.CardColor.YELLOW, 7)
	assert(!Rules.is_card_legal(y7, r5), "Yellow 7 should NOT be playable on Red 5")
	assert(!Rules.is_card_legal(b_skip, r5), "Blue Skip should NOT be playable on Red 5")
	assert(!Rules.is_card_legal(r_skip, b_draw2), "Red Skip should NOT be playable on Blue Draw Two")

	# Test 7: Active color matching when top card is Wild
	var wild_top = Card.create_wild()
	# With active_color set to GREEN:
	var g3 = Card.create_number(Constants.CardColor.GREEN, 3)
	assert(Rules.is_card_legal(g3, wild_top, Constants.CardColor.GREEN), "Green 3 is playable when active color is GREEN")
	assert(!Rules.is_card_legal(r5, wild_top, Constants.CardColor.GREEN), "Red 5 is NOT playable when active color is GREEN")
	assert(!Rules.is_card_legal(y7, wild_top, Constants.CardColor.GREEN), "Yellow 7 is NOT playable when active color is GREEN")
	# Wild cards remain playable even when active color is chosen
	assert(Rules.is_card_legal(wild, wild_top, Constants.CardColor.GREEN), "Wild is playable on Wild with active color")
	assert(Rules.is_card_legal(wd4, wild_top, Constants.CardColor.GREEN), "WD4 is playable on Wild with active color")

	# Number card cannot match Wild card type
	var wild_top_number = Card.create_wild()
	assert(!Rules.is_card_legal(r5, wild_top_number, Constants.CardColor.BLUE), "Red 5 cannot match type on Wild top card")

	# Test 8: Card convenience method is_playable_on
	assert(r5.is_playable_on(r2), "r5.is_playable_on(r2) should be true")
	assert(!y7.is_playable_on(r5), "y7.is_playable_on(r5) should be false")
	assert(wild.is_playable_on(r5), "wild.is_playable_on(r5) should be true")

	# Test 9: get_playable_cards and has_legal_move
	var hand: Array[Card] = [y7, b_skip, wild, g3]
	# Top card is Red 7
	var r7 = Card.create_number(Constants.CardColor.RED, 7)
	var playable = Rules.get_playable_cards(hand, r7, Constants.CardColor.RED)
	# y7 (matches 7) and wild (matches anything)
	assert(playable.size() == 2, "Expected 2 playable cards (got %d)" % playable.size())
	assert(playable.has(y7), "y7 should be playable on r7")
	assert(playable.has(wild), "wild should be playable on r7")
	assert(Rules.has_legal_move(hand, r7, Constants.CardColor.RED) == true, "has_legal_move should return true")

	# Hand with no legal moves
	var dead_hand: Array[Card] = [b_skip, b_draw2]
	assert(Rules.has_legal_move(dead_hand, r5, Constants.CardColor.RED) == false, "No legal moves on Red 5")
	var dead_playable = Rules.get_playable_cards(dead_hand, r5, Constants.CardColor.RED)
	assert(dead_playable.is_empty(), "get_playable_cards should be empty for dead hand")

	# Test 10: Determinism check (calling legality check repeatedly gives identical results)
	for _i in range(50):
		assert(Rules.is_card_legal(r5, r2) == true, "Determinism: r5 on r2")
		assert(Rules.is_card_legal(y7, r5) == false, "Determinism: y7 on r5")
		assert(Rules.is_card_legal(wild, b_skip) == true, "Determinism: wild on b_skip")
