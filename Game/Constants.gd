class_name Constants
extends RefCounted

# Card colors (used for matching and active-color tracking)
enum CardColor {
	RED = 0,
	YELLOW = 1,
	BLUE = 2,
	GREEN = 3,
	WILD = 4, # Wild / unchosen color
}

# Card types / values
enum CardType {
	NUMBER_0 = 0,
	NUMBER_1 = 1,
	NUMBER_2 = 2,
	NUMBER_3 = 3,
	NUMBER_4 = 4,
	NUMBER_5 = 5,
	NUMBER_6 = 6,
	NUMBER_7 = 7,
	NUMBER_8 = 8,
	NUMBER_9 = 9,
	SKIP = 10,
	REVERSE = 11,
	DRAW_TWO = 12,
	WILD = 13,
	WILD_DRAW_FOUR = 14,
}

# Standard 4 colors in UNO
const COLORS: Array[CardColor] = [
	CardColor.RED,
	CardColor.YELLOW,
	CardColor.BLUE,
	CardColor.GREEN,
]

# Color name lookup
const COLOR_NAMES: Dictionary = {
	CardColor.RED: "Red",
	CardColor.YELLOW: "Yellow",
	CardColor.BLUE: "Blue",
	CardColor.GREEN: "Green",
	CardColor.WILD: "Wild",
}

# Type name lookup
const TYPE_NAMES: Dictionary = {
	CardType.NUMBER_0: "0",
	CardType.NUMBER_1: "1",
	CardType.NUMBER_2: "2",
	CardType.NUMBER_3: "3",
	CardType.NUMBER_4: "4",
	CardType.NUMBER_5: "5",
	CardType.NUMBER_6: "6",
	CardType.NUMBER_7: "7",
	CardType.NUMBER_8: "8",
	CardType.NUMBER_9: "9",
	CardType.SKIP: "Skip",
	CardType.REVERSE: "Reverse",
	CardType.DRAW_TWO: "Draw Two",
	CardType.WILD: "Wild",
	CardType.WILD_DRAW_FOUR: "Wild Draw Four",
}

# Official UNO scoring points
const CARD_POINTS: Dictionary = {
	CardType.NUMBER_0: 0,
	CardType.NUMBER_1: 1,
	CardType.NUMBER_2: 2,
	CardType.NUMBER_3: 3,
	CardType.NUMBER_4: 4,
	CardType.NUMBER_5: 5,
	CardType.NUMBER_6: 6,
	CardType.NUMBER_7: 7,
	CardType.NUMBER_8: 8,
	CardType.NUMBER_9: 9,
	CardType.SKIP: 20,
	CardType.REVERSE: 20,
	CardType.DRAW_TWO: 20,
	CardType.WILD: 50,
	CardType.WILD_DRAW_FOUR: 50,
}

# Deck size
const STANDARD_DECK_SIZE: int = 108

# Player limits (session)
const MIN_PLAYER_COUNT: int = 2
const MAX_PLAYER_COUNT: int = 8

# Initial hand size per player (standard UNO)
const INITIAL_HAND_SIZE: int = 7
