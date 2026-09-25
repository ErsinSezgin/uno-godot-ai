extends Node

func _ready() -> void:
	run_tests()
	print("All TurnOrder tests passed successfully!")

func run_tests() -> void:
	# Test 1: 2-player turn progression
	var to2 = TurnOrder.new(2, 0, TurnOrder.Direction.CLOCKWISE)
	assert(to2.player_count == 2, "2 players")
	assert(to2.get_current_index() == 0, "Starts at player 0")
	assert(to2.get_next_index() == 1, "Next from 0 is 1")

	# Advance 0 -> 1
	var next_idx = to2.advance_turn()
	assert(next_idx == 1, "Advanced to 1")
	assert(to2.get_current_index() == 1, "Current is now 1")

	# Advance 1 -> 0 (wrap around)
	next_idx = to2.advance_turn()
	assert(next_idx == 0, "Advanced back to 0")

	# 2-player skip: skips next player and returns to current player
	var skip_idx = to2.skip_turn()
	assert(skip_idx == 0, "2-player skip from 0 returns to 0")
	to2.set_current_index(1)
	skip_idx = to2.skip_turn()
	assert(skip_idx == 1, "2-player skip from 1 returns to 1")

	# 2-player reverse
	to2.set_current_index(0)
	var new_dir = to2.reverse_direction()
	assert(new_dir == TurnOrder.Direction.COUNTER_CLOCKWISE, "Reversed to COUNTER_CLOCKWISE")
	assert(!to2.is_clockwise(), "Should not be clockwise")
	assert(to2.get_next_index() == 1, "In 2-player, next from 0 in reverse is 1")
	assert(to2.advance_turn() == 1, "Advanced to 1 in reverse")
	assert(to2.advance_turn() == 0, "Advanced back to 0 in reverse")

	# Test 2: 4-player turn order & wrapping
	var to4 = TurnOrder.new(4, 0, TurnOrder.Direction.CLOCKWISE)
	assert(to4.is_clockwise(), "Starts clockwise")
	assert(to4.advance_turn() == 1, "0 -> 1")
	assert(to4.advance_turn() == 2, "1 -> 2")
	assert(to4.advance_turn() == 3, "2 -> 3")
	assert(to4.advance_turn() == 0, "3 -> 0 (wrap around)")

	# Test 3: Reverse changes direction in 4-player
	to4.set_current_index(0)
	to4.reverse_direction()
	assert(!to4.is_clockwise(), "Direction is now counter-clockwise")
	assert(to4.get_next_index() == 3, "From 0 counter-clockwise, next is 3")
	assert(to4.advance_turn() == 3, "0 -> 3 in CCW")
	assert(to4.advance_turn() == 2, "3 -> 2 in CCW")
	assert(to4.advance_turn() == 1, "2 -> 1 in CCW")
	assert(to4.advance_turn() == 0, "1 -> 0 in CCW (wrap around)")

	# Reverse back to clockwise
	to4.reverse_direction()
	assert(to4.is_clockwise(), "Reversed back to clockwise")
	assert(to4.get_next_index() == 1, "From 0 clockwise, next is 1")

	# Test 4: Skip advances correctly (advances by 2)
	to4.set_current_index(1)
	assert(to4.skip_turn() == 3, "Clockwise skip from 1 advances to 3")
	assert(to4.skip_turn() == 1, "Clockwise skip from 3 wraps around to 1")

	# Skip in counter-clockwise
	to4.reverse_direction()
	to4.set_current_index(1)
	assert(to4.skip_turn() == 3, "CCW skip from 1 wraps around to 3")
	assert(to4.skip_turn() == 1, "CCW skip from 3 goes to 1")

	# Test 5: Previous player helper
	to4.reverse_direction() # Back to clockwise
	to4.set_current_index(0)
	assert(to4.get_previous_index() == 3, "Clockwise previous from 0 is 3")
	to4.set_current_index(2)
	assert(to4.get_previous_index() == 1, "Clockwise previous from 2 is 1")

	# Test 6: Player IDs support
	var to_ids = TurnOrder.new()
	to_ids.set_players(["peer_100", "peer_200", "peer_300"])
	assert(to_ids.player_count == 3, "Count is 3 from player_ids")
	assert(to_ids.get_current_player_id() == "peer_100", "Current ID is peer_100")
	assert(to_ids.get_next_player_id() == "peer_200", "Next ID is peer_200")
	to_ids.advance_turn()
	assert(to_ids.get_current_player_id() == "peer_200", "Current ID is now peer_200")

	# Test 7: Static pure helpers
	assert(TurnOrder.get_next_player(0, 4, TurnOrder.Direction.CLOCKWISE, 1) == 1, "Static next 0 -> 1")
	assert(TurnOrder.get_next_player(3, 4, TurnOrder.Direction.CLOCKWISE, 1) == 0, "Static next 3 -> 0")
	assert(TurnOrder.get_next_player(0, 4, TurnOrder.Direction.COUNTER_CLOCKWISE, 1) == 3, "Static CCW next 0 -> 3")
	assert(TurnOrder.get_next_player(0, 4, TurnOrder.Direction.CLOCKWISE, 2) == 2, "Static skip 0 -> 2")
	assert(TurnOrder.get_previous_player(0, 4, TurnOrder.Direction.CLOCKWISE, 1) == 3, "Static prev 0 -> 3")
	assert(TurnOrder.invert_direction(TurnOrder.Direction.CLOCKWISE) == TurnOrder.Direction.COUNTER_CLOCKWISE, "Static invert")

	# Test 8: Edge cases
	# 0 players
	var to0 = TurnOrder.new(0)
	assert(to0.advance_turn() == 0, "0 players should not crash")
	assert(to0.get_next_index() == 0, "0 players next is 0")

	# 1 player
	var to1 = TurnOrder.new(1)
	assert(to1.advance_turn() == 0, "1 player advance is 0")
	assert(to1.skip_turn() == 0, "1 player skip is 0")

	# Large step wrapping
	to4.set_current_index(0)
	assert(to4.get_next_index(9) == 1, "posmod(0 + 9, 4) == 1")

	# Negative start index normalization
	var to_neg = TurnOrder.new(4, -1)
	assert(to_neg.get_current_index() == 3, "Negative start index -1 on 4 players normalizes to 3")

	# Test 9: Serialization roundtrip
	var serialized = to4.to_dict()
	assert(serialized["player_count"] == 4, "player_count in dict")
	assert(serialized["direction"] == TurnOrder.Direction.CLOCKWISE, "direction in dict")

	var restored = TurnOrder.from_dict(serialized)
	assert(restored.player_count == 4, "Restored player_count")
	assert(restored.current_index == to4.current_index, "Restored current_index")
	assert(restored.direction == to4.direction, "Restored direction")
