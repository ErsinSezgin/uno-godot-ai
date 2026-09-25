extends Node

func _ready() -> void:
	run_tests()
	print("All GameState tests passed successfully!")

func _create_players(count: int = 4) -> Array[Player]:
	var list: Array[Player] = []
	for i in range(count):
		list.append(Player.new(i + 1, "Player %d" % (i + 1)))
	return list

func run_tests() -> void:
	# Test 1: Minimum player validation
	var gs = GameState.new()
	var single_player = _create_players(1)
	var success_1p = gs.setup_round(single_player)
	assert(success_1p == false, "setup_round with 1 player should fail")
	assert(gs.is_round_active == false, "Round should not be active with 1 player")

	# Test 2: Standard 4-player round setup with normal number card
	var players = _create_players(4)
	var red_5 = Card.create_number(Constants.CardColor.RED, 5)
	var rng = RandomNumberGenerator.new()
	rng.seed = 42

	var success = gs.setup_round(players, rng, null, red_5, 7)
	assert(success == true, "setup_round should succeed")
	assert(gs.is_round_active == true, "Round should be active")
	assert(gs.round_number == 1, "Round number should be 1")
	assert(gs.get_player_count() == 4, "Should have 4 players")

	# Each player should have exactly 7 cards
	for p in players:
		assert(p.hand_size() == 7, "Player %s should have 7 cards (has %d)" % [p.name, p.hand_size()])
		assert(p.has_declared_uno == false, "Player %s UNO state should be false" % p.name)

	# Deck remaining card count when custom_starting_card is passed: 108 total - 4*7 dealt = 80
	assert(gs.deck.card_count() == 108 - 28, "Deck should have 80 cards remaining (got %d)" % gs.deck.card_count())

	# Discard pile state
	assert(gs.get_top_card() == red_5, "Top card should be red_5")
	assert(gs.get_active_color() == Constants.CardColor.RED, "Active color should be RED")

	# Current player should be player 0 (first player)
	assert(gs.current_player == 0, "Starting player should be index 0")
	assert(gs.get_current_player() == players[0], "get_current_player should return first player")

	# Test 2b: Round setup with natural deck draw (custom_starting_card == null)
	var gs_natural = GameState.new()
	var natural_players = _create_players(4)
	var nat_success = gs_natural.setup_round(natural_players, rng, null, null, 7)
	assert(nat_success == true, "Natural setup should succeed")
	assert(gs_natural.deck.card_count() == 108 - 28 - 1, "Deck should have 79 cards remaining (got %d)" % gs_natural.deck.card_count())
	assert(gs_natural.get_top_card() != null, "Top card should not be null")
	assert(gs_natural.get_top_card().card_type != Constants.CardType.WILD_DRAW_FOUR, "Opening card must not be Wild Draw Four")

	# Test 3: Opening card - Skip card skips player 0
	var gs_skip = GameState.new()
	var skip_players = _create_players(4)
	var blue_skip = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.SKIP)
	gs_skip.setup_round(skip_players, null, null, blue_skip, 7)
	assert(gs_skip.get_top_card() == blue_skip, "Opening card is Blue Skip")
	assert(gs_skip.current_player == 1, "Player 0 should be skipped, current player should be 1")
	assert(gs_skip.get_current_player() == skip_players[1], "Current player should be player 2")

	# Test 4: Opening card - Reverse card reverses direction
	var gs_rev = GameState.new()
	var rev_players = _create_players(4)
	var yellow_rev = Card.create_action(Constants.CardColor.YELLOW, Constants.CardType.REVERSE)
	gs_rev.setup_round(rev_players, null, null, yellow_rev, 7)
	assert(gs_rev.get_top_card() == yellow_rev, "Opening card is Yellow Reverse")
	assert(!gs_rev.turn_order.is_clockwise(), "Direction should be reversed")
	assert(gs_rev.current_player == 3, "In 4-player game with opening Reverse, turn goes to player 3")

	# Test 5: Opening card - Reverse in 2-player acts as skip
	var gs_rev2 = GameState.new()
	var rev2_players = _create_players(2)
	gs_rev2.setup_round(rev2_players, null, null, yellow_rev, 7)
	assert(gs_rev2.current_player == 1, "In 2-player game, Reverse skips player 0 so player 1 starts")

	# Test 6: Opening card - Draw Two forces player 0 to draw 2 and skip
	var gs_draw2 = GameState.new()
	var draw2_players = _create_players(4)
	var green_draw2 = Card.create_action(Constants.CardColor.GREEN, Constants.CardType.DRAW_TWO)
	gs_draw2.setup_round(draw2_players, null, null, green_draw2, 7)
	assert(gs_draw2.get_top_card() == green_draw2, "Opening card is Green Draw Two")
	assert(draw2_players[0].hand_size() == 9, "Player 0 should have drawn 2 cards (total 9, got %d)" % draw2_players[0].hand_size())
	assert(gs_draw2.current_player == 1, "Player 0 should be skipped, current is 1")

	# Test 7: Opening card - Wild allows choosing active color
	var gs_wild = GameState.new()
	var wild_players = _create_players(4)
	var wild_card = Card.create_wild()
	gs_wild.setup_round(wild_players, null, null, wild_card, 7)
	assert(gs_wild.get_top_card() == wild_card, "Opening card is Wild")
	assert(gs_wild.get_active_color() == Constants.CardColor.WILD, "Active color is initially WILD")
	assert(gs_wild.current_player == 0, "Player 0 starts on Wild")

	# Test 8: Custom hand size (e.g. 5 cards)
	var gs_custom = GameState.new()
	var custom_players = _create_players(2)
	gs_custom.setup_round(custom_players, null, null, red_5, 5)
	assert(custom_players[0].hand_size() == 5, "Player 1 should have 5 cards")
	assert(custom_players[1].hand_size() == 5, "Player 2 should have 5 cards")

	# Test 9: Snapshot serialization with hand hiding
	var p1_id = players[0].id
	var snapshot = gs.to_dict(p1_id)
	assert(snapshot["is_round_active"] == true, "Snapshot reports round active")
	assert(snapshot["round_number"] == 1, "Snapshot reports round 1")
	assert(snapshot["players"].size() == 4, "Snapshot has 4 players")
	# p1's hand should be visible
	assert(snapshot["players"][0]["hand"].size() == 7, "p1 hand visible")
	# p2, p3, p4 hands should be empty (hidden) but card_count == 7
	for i in range(1, 4):
		assert(snapshot["players"][i]["hand"].is_empty(), "Opponent hand hidden")
		assert(snapshot["players"][i]["card_count"] == 7, "Opponent card count preserved")

	# Test 10: reset_round cleans state
	gs.reset_round()
	assert(gs.is_round_active == false, "Round should no longer be active")
	assert(gs.current_player == -1, "current_player should be -1")
	assert(players[0].hand_size() == 0, "p1 hand cleared")
