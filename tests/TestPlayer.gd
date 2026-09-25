extends Node

func _ready() -> void:
	run_tests()
	print("All Player tests passed successfully!")

func run_tests() -> void:
	# Test 1: Player creation with default and custom values
	var p1 = Player.new(1, "Alice", true)
	assert(p1.id == 1, "Player id should be 1")
	assert(p1.name == "Alice", "Player name should be Alice")
	assert(p1.is_host == true, "Player should be host")
	assert(p1.peer_id == 1, "Player peer_id should default to id")
	assert(p1.is_connected == true, "Player should be connected by default")
	assert(p1.score == 0, "Initial score should be 0")
	assert(p1.hand_size() == 0, "Initial hand size should be 0")
	assert(p1.is_hand_empty() == true, "Initial hand should be empty")
	assert(p1.has_declared_uno == false, "UNO declaration should be false initially")

	# Test 2: Adding cards and querying hand
	var r5 = Card.create_number(Constants.CardColor.RED, 5)
	var b_skip = Card.create_action(Constants.CardColor.BLUE, Constants.CardType.SKIP)
	var wild = Card.create_wild()

	p1.add_card(r5)
	assert(p1.hand_size() == 1, "Hand size should be 1")
	assert(!p1.is_hand_empty(), "Hand should not be empty")
	assert(p1.has_card(r5), "Player should have r5")

	var dummy_r5 = Card.create_number(Constants.CardColor.RED, 5)
	assert(p1.has_card(dummy_r5), "has_card should match identical card values")

	var y7 = Card.create_number(Constants.CardColor.YELLOW, 7)
	assert(!p1.has_card(y7), "Player should not have y7")

	p1.add_cards([b_skip, wild])
	assert(p1.hand_size() == 3, "Hand size should now be 3")

	# Test 3: Calculate hand points
	# r5: 5 pts, b_skip: 20 pts, wild: 50 pts => 75 pts
	var points = p1.calculate_hand_points()
	assert(points == 75, "Hand points should be 75 (got %d)" % points)

	# Test 4: Removing cards
	var removed = p1.remove_card(b_skip)
	assert(removed == true, "Removing b_skip should return true")
	assert(p1.hand_size() == 2, "Hand size should now be 2")
	assert(!p1.has_card(b_skip), "b_skip should no longer be in hand")

	var not_removed = p1.remove_card(y7)
	assert(not_removed == false, "Removing card not in hand should return false")
	assert(p1.hand_size() == 2, "Hand size should remain 2")

	var removed_at = p1.remove_card_at(0)
	assert(removed_at.is_same_as(r5), "remove_card_at(0) should return r5")
	assert(p1.hand_size() == 1, "Hand size should now be 1")

	var invalid_remove = p1.remove_card_at(99)
	assert(invalid_remove == null, "remove_card_at out of bounds should return null")

	# Test 5: Score management
	p1.add_score(50)
	assert(p1.score == 50, "Score should be 50")
	p1.add_score(25)
	assert(p1.score == 75, "Score should be 75")
	p1.reset_score()
	assert(p1.score == 0, "Score should be reset to 0")

	# Test 6: Serialization to_dict and from_dict roundtrip
	var p2 = Player.new(42, "Bob", false)
	p2.score = 120
	p2.is_connected = false
	p2.peer_id = 42
	p2.has_declared_uno = true
	var g3 = Card.create_number(Constants.CardColor.GREEN, 3)
	var wd4 = Card.create_wild_draw_four()
	p2.add_cards([g3, wd4])

	var p2_dict = p2.to_dict()
	assert(p2_dict["id"] == 42, "Serialized id should be 42")
	assert(p2_dict["name"] == "Bob", "Serialized name should be Bob")
	assert(p2_dict["score"] == 120, "Serialized score should be 120")
	assert(p2_dict["is_host"] == false, "Serialized is_host should be false")
	assert(p2_dict["is_connected"] == false, "Serialized is_connected should be false")
	assert(p2_dict["peer_id"] == 42, "Serialized peer_id should be 42")
	assert(p2_dict["has_declared_uno"] == true, "Serialized has_declared_uno should be true")
	assert(p2_dict["card_count"] == 2, "Serialized card_count should be 2")
	assert(p2_dict["hand"].size() == 2, "Serialized hand size should be 2")

	var restored_p2 = Player.from_dict(p2_dict)
	assert(restored_p2.id == p2.id, "Restored id should match")
	assert(restored_p2.name == p2.name, "Restored name should match")
	assert(restored_p2.score == p2.score, "Restored score should match")
	assert(restored_p2.is_host == p2.is_host, "Restored is_host should match")
	assert(restored_p2.is_connected == p2.is_connected, "Restored is_connected should match")
	assert(restored_p2.peer_id == p2.peer_id, "Restored peer_id should match")
	assert(restored_p2.has_declared_uno == p2.has_declared_uno, "Restored has_declared_uno should match")
	assert(restored_p2.hand_size() == 2, "Restored hand size should match")
	assert(restored_p2.has_card(g3), "Restored hand should have g3")
	assert(restored_p2.has_card(wd4), "Restored hand should have wd4")

	# Test 7: Serialization with include_hand = false (for hiding opponents' hands)
	var hidden_dict = p2.to_dict(false)
	assert(hidden_dict["card_count"] == 2, "Hidden dict should still expose card count")
	assert(hidden_dict["hand"].is_empty(), "Hidden dict hand array should be empty")

	# Test 8: String representation
	var desc = str(p2)
	assert(desc.find("Bob") != -1, "String representation should contain player name")
	assert(desc.find("42") != -1, "String representation should contain player ID")
