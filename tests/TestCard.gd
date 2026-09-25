extends Node

func _ready() -> void:
	run_tests()
	print("All Card tests passed successfully!")

func run_tests() -> void:
	# Test 1: Create a red 5 card
	var card = Card.create_number(Constants.CardColor.RED, 5)
	assert(card.color == Constants.CardColor.RED, "Card color should be RED")
	assert(card.card_type == Constants.CardType.NUMBER_5, "Card type should be NUMBER_5")
	assert(card.value == 5, "Card value should be 5")
	assert(!card.is_wild(), "Red 5 should not be wild")
	assert(card.is_number(), "Red 5 should be a number card")
	assert(!card.is_action(), "Red 5 should not be an action card")

	# Test 2: Wild card
	var wild_card = Card.create_wild()
	assert(wild_card.color == Constants.CardColor.WILD, "Wild card color should be WILD")
	assert(wild_card.card_type == Constants.CardType.WILD, "Wild card type should be WILD")
	assert(wild_card.is_wild(), "Wild card should report is_wild == true")

	# Test 3: Wild Draw Four card
	var wild_draw4 = Card.create_wild_draw_four()
	assert(wild_draw4.color == Constants.CardColor.WILD, "Wild draw 4 color should be WILD")
	assert(wild_draw4.card_type == Constants.CardType.WILD_DRAW_FOUR, "Type should be WILD_DRAW_FOUR")
	assert(wild_draw4.is_wild(), "Wild draw 4 should report is_wild == true")

	# Test 4: Action card (Skip, Reverse, Draw Two)
	var skip_card = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.SKIP)
	assert(skip_card.color == Constants.CardColor.BLUE, "Skip card should be BLUE")
	assert(skip_card.card_type == Constants.CardType.SKIP, "Skip card should be SKIP")
	assert(skip_card.is_action(), "Skip card should be action")
	assert(!skip_card.is_number(), "Skip card should not be number")

	# Test 5: matches_color
	assert(card.matches_color(Constants.CardColor.RED), "Red card should match RED")
	assert(!card.matches_color(Constants.CardColor.YELLOW), "Red card should not match YELLOW")
	assert(wild_card.matches_color(Constants.CardColor.RED), "Wild card matches any color")
	assert(wild_card.matches_color(Constants.CardColor.GREEN), "Wild card matches any color")

	# Test 6: matches_type
	var yellow_5 = Card.create_number(Constants.CardColor.YELLOW, 5)
	assert(card.matches_type(yellow_5.card_type), "Red 5 and Yellow 5 should match type")
	assert(wild_card.matches_type(card.card_type), "Wild card matches any type")

	# Test 7: to_dict / from_dict roundtrip
	var dict = card.to_dict()
	var restored = Card.from_dict(dict)
	assert(card.is_same_as(restored), "Restored card from dict should match original")

	# Test 8: String representation
	assert(card.to_string() == "Red 5", "String representation should be 'Red 5'")
	assert(wild_card.to_string() == "Wild", "String representation should be 'Wild'")
	assert(wild_draw4.to_string() == "Wild Draw Four", "String representation should be 'Wild Draw Four'")

	# Test 9: Asset paths
	assert(card.get_asset_path() == "res://resources/cards/red_5.svg", "Asset path for red 5")
	assert(wild_card.get_asset_path() == "res://resources/cards/wild.svg", "Asset path for wild")
	assert(wild_draw4.get_asset_path() == "res://resources/cards/wild_draw4.svg", "Asset path for wild draw 4")
	assert(skip_card.get_asset_path() == "res://resources/cards/blue_skip.svg", "Asset path for blue skip")
