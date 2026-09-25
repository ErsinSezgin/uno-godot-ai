class_name TurnOrder
extends RefCounted

## Helper class for managing turn progression and direction in UNO.
## Supports 2+ players, direction reversal (Clockwise / Counter-Clockwise),
## skip card advances, and safe modulo wraparound for all edge cases.

enum Direction {
	CLOCKWISE = 1,
	COUNTER_CLOCKWISE = -1,
}

var player_count: int = 0
var current_index: int = 0
var direction: int = Direction.CLOCKWISE
var player_ids: Array = []

func _init(p_count: int = 0, p_start_index: int = 0, p_direction: int = Direction.CLOCKWISE) -> void:
	player_count = max(0, p_count)
	direction = Direction.COUNTER_CLOCKWISE if p_direction == Direction.COUNTER_CLOCKWISE else Direction.CLOCKWISE
	if player_count > 0:
		current_index = posmod(p_start_index, player_count)
	else:
		current_index = 0

## Sets the number of players and normalizes the current index.
func set_player_count(count: int) -> void:
	player_count = max(0, count)
	if player_count > 0:
		current_index = posmod(current_index, player_count)
	else:
		current_index = 0

## Configures player IDs/objects for easy ID-based queries.
func set_players(ids: Array) -> void:
	player_ids = ids.duplicate()
	set_player_count(player_ids.size())

## Returns the current turn index.
func get_current_index() -> int:
	return current_index

## Sets the current turn index directly, normalized to player_count.
func set_current_index(idx: int) -> void:
	if player_count > 0:
		current_index = posmod(idx, player_count)
	else:
		current_index = 0

## Returns the current direction (1 for CLOCKWISE, -1 for COUNTER_CLOCKWISE).
func get_direction() -> int:
	return direction

## Returns true if the turn direction is clockwise (forward).
func is_clockwise() -> bool:
	return direction == Direction.CLOCKWISE

## Reverses the turn direction and returns the new direction.
func reverse_direction() -> int:
	direction = -direction
	return direction

## Calculates the next player index after `steps` in the current direction without advancing state.
func get_next_index(steps: int = 1) -> int:
	if player_count <= 0:
		return 0
	return posmod(current_index + (steps * direction), player_count)

## Calculates the previous player index before `steps` in the current direction without advancing state.
func get_previous_index(steps: int = 1) -> int:
	if player_count <= 0:
		return 0
	return posmod(current_index - (steps * direction), player_count)

## Advances the turn by `steps` (default 1) in the active direction and returns the new index.
func advance_turn(steps: int = 1) -> int:
	current_index = get_next_index(steps)
	return current_index

## Advances turn by 2 steps to skip the next player, returning the new index.
func skip_turn() -> int:
	return advance_turn(2)

## Returns current player ID if player_ids is set, otherwise current_index.
func get_current_player_id():
	if not player_ids.is_empty() and current_index < player_ids.size():
		return player_ids[current_index]
	return current_index

## Returns next player ID without modifying state.
func get_next_player_id(steps: int = 1):
	var next_idx: int = get_next_index(steps)
	if not player_ids.is_empty() and next_idx < player_ids.size():
		return player_ids[next_idx]
	return next_idx

## Static pure helper to compute the next player index without an instance.
static func get_next_player(current: int, total: int, dir: int = Direction.CLOCKWISE, steps: int = 1) -> int:
	if total <= 0:
		return 0
	return posmod(current + (steps * dir), total)

## Static pure helper to compute the previous player index without an instance.
static func get_previous_player(current: int, total: int, dir: int = Direction.CLOCKWISE, steps: int = 1) -> int:
	if total <= 0:
		return 0
	return posmod(current - (steps * dir), total)

## Static pure helper to invert a direction.
static func invert_direction(dir: int) -> int:
	return -dir

## Serializes turn order state to a plain Dictionary.
func to_dict() -> Dictionary:
	return {
		"player_count": player_count,
		"current_index": current_index,
		"direction": direction,
		"player_ids": player_ids.duplicate(),
	}

## Deserializes TurnOrder from a Dictionary.
static func from_dict(data: Dictionary) -> TurnOrder:
	var to = TurnOrder.new(
		data.get("player_count", 0),
		data.get("current_index", 0),
		data.get("direction", Direction.CLOCKWISE)
	)
	var ids: Array = data.get("player_ids", [])
	if not ids.is_empty():
		to.set_players(ids)
	return to

func _to_string() -> String:
	var dir_str = "Clockwise" if direction == Direction.CLOCKWISE else "CounterClockwise"
	return "TurnOrder(current=%d, total=%d, dir=%s)" % [current_index, player_count, dir_str]
