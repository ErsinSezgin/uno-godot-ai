extends Node

# Placeholder: GameState data model for the authoritative game state.
# This will be expanded in later tasks to hold players, deck, turn order, etc.

import '../Constants.gd'

var round_state: Dict[str, any] = {}
var scores: Dict[str, any] = {}
# Current player index (0-based). Use Constants.MIN_PLAYER_COUNT as the minimum valid count.

func reset_round() -> void:
    round_state.clear()
    scores.clear()
    current_player = -1
