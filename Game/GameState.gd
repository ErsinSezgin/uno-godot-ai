class_name GameState
extends Node

## Placeholder: GameState data model for the authoritative game state.
## This will be expanded in later tasks to hold players, deck, turn order, etc.

var round_state: Dictionary = {}
var scores: Dictionary = {}
var current_player: int = -1

func reset_round() -> void:
	round_state.clear()
	scores.clear()
	current_player = -1
