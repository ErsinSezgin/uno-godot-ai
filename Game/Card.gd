extends Node

import '../Constants.gd'

# Represents a single UNO card.
# A card has an action type (color or type) and a value that identifies it within that type.
# Wild cards have value 0; normal action cards have values 1-9.

var type: ActionType
var value: int

func new(type: ActionType, value: int) -> "Game.Card":
    self.type = type
    self.value = value

func __repr__() -> String:
    return "Card(type={self.type}, value={self.value})"

func to_dict() -> Dict[str, any]:
    return {
        "type": self.type,
        "value": self.value
    }

func from_dict(data: Dict[str, any]) -> "Game.Card":
    self.type = data["type"]
    self.value = data["value"]

# Convenience: create a wild color card for a given Color.
func new_wild_color(color: Color) -> "Game.Card":
    self.type = ActionType.COLOR
    self.value = 0
    return self

# Convenience: create a wild action card.
func new_wild_action() -> "Game.Card":
    self.type = ActionType.TYPE
    self.value = 0
    return self

# Convenience: create a normal action card (value 1-9).
func new_action(value: int) -> "Game.Card":
    self.type = ActionType.COLOR
    self.value = value
    return self

# Convenience: create a type-card (value 1-9).
func new_type_card(value: int) -> "Game.Card":
    self.type = ActionType.TYPE
    self.value = value
    return self

func is_wild() -> bool:
    # Value 0 indicates a wild card (wild color or wild action).
    return self.value == 0

func matches_color(color: Color) -> bool:
    # A card matches a color if it is that color or wild.
    if self.is_wild():
        return true
    match self.type:
        ActionType.COLOR => self.value == color  # Action cards are indexed by their Color enum value
        _ => false

func matches_action_type(at: ActionType) -> bool:
    # A card matches an action type if it is that type or wild.
    if self.is_wild():
        return true
    match self.type:
        ActionType.COLOR => at == ActionType.COLOR
        ActionType.TYPE  => at == ActionType.TYPE

func is_same_as(other: "Game.Card") -> bool:
    return self.type == other.type and self.value == other.value
