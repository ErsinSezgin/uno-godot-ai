# Game constants shared across UNO gameplay code.
# This is the single source of truth for core game data values so they never get duplicated in gameplay logic.

# --- Card colors (used for matching and active-color tracking) ---
enum Color:
    RED     = 0
    YELLOW  = 1
    BLUE    = 2
    GREEN   = 3

const COLORS: List[Color] = [RED, YELLOW, BLUE, GREEN]

# Human-readable color strings for UI logging / debugging
const COLOR_NAMES: Dict[Color, String] = {
    RED     : "Red",
    YELLOW  : "Yellow",
    BLUE    : "Blue",
    GREEN   : "Green"
}

# --- Card types (action types) ---
enum ActionType:
    COLOR  = "color"       # Match the active color (red, yellow, blue, green)
    TYPE   = "type"        # Match the action type (all cards of one kind)

const ACTION_TYPES: List[ActionType] = [Color, Type]
# The enum Color/Type values ARE the action types

# --- Player limits (session) ---
const MIN_PLAYER_COUNT: int   = 2
const MAX_PLAYER_COUNT: int   = 8

# --- Initial hand size per player (standard UNO) ---
const INITIAL_HAND_SIZE: int  = 7
