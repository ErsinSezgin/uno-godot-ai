class_name Card
extends RefCounted

## Represents a single UNO card.
## A card has a color (Red, Yellow, Blue, Green, or Wild) and a card_type (0-9, Skip, Reverse, Draw Two, Wild, Wild Draw Four).

var color: Constants.CardColor = Constants.CardColor.WILD
var card_type: Constants.CardType = Constants.CardType.NUMBER_0
var value: int = 0

func _init(p_color: int = Constants.CardColor.WILD, p_type: int = Constants.CardType.NUMBER_0, p_value: int = -1) -> void:
	color = p_color as Constants.CardColor
	card_type = p_type as Constants.CardType
	if p_value >= 0:
		value = p_value
	elif p_type >= Constants.CardType.NUMBER_0 and p_type <= Constants.CardType.NUMBER_9:
		value = int(p_type)
	else:
		value = -1

func is_wild() -> bool:
	return card_type == Constants.CardType.WILD or card_type == Constants.CardType.WILD_DRAW_FOUR or color == Constants.CardColor.WILD

func is_action() -> bool:
	return card_type == Constants.CardType.SKIP or card_type == Constants.CardType.REVERSE or card_type == Constants.CardType.DRAW_TWO

func is_number() -> bool:
	return card_type >= Constants.CardType.NUMBER_0 and card_type <= Constants.CardType.NUMBER_9

func get_points() -> int:
	return Constants.CARD_POINTS.get(card_type, 0)

func matches_color(target_color: int) -> bool:
	if is_wild() or target_color == Constants.CardColor.WILD:
		return true
	return color == target_color

func matches_type(target_type: int) -> bool:
	if is_wild():
		return true
	return card_type == target_type

func is_same_as(other: Card) -> bool:
	if other == null:
		return false
	return color == other.color and card_type == other.card_type and value == other.value

func to_dict() -> Dictionary:
	return {
		"color": int(color),
		"type": int(card_type),
		"value": value,
	}

static func from_dict(data: Dictionary) -> Card:
	var c: int = data.get("color", Constants.CardColor.WILD)
	var t: int = data.get("type", Constants.CardType.NUMBER_0)
	var v: int = data.get("value", -1)
	return Card.new(c, t, v)

func _to_string() -> String:
	if card_type == Constants.CardType.WILD:
		return "Wild"
	if card_type == Constants.CardType.WILD_DRAW_FOUR:
		return "Wild Draw Four"
	var col_name: String = Constants.COLOR_NAMES.get(color, "Unknown")
	var type_name: String = Constants.TYPE_NAMES.get(card_type, str(value))
	return "%s %s" % [col_name, type_name]

## Helper to get the SVG asset path for this card
func get_asset_path() -> String:
	if card_type == Constants.CardType.WILD:
		return "res://resources/cards/wild.svg"
	if card_type == Constants.CardType.WILD_DRAW_FOUR:
		return "res://resources/cards/wild_draw4.svg"
	var col_str: String = ""
	match color:
		Constants.CardColor.RED: col_str = "red"
		Constants.CardColor.YELLOW: col_str = "yellow"
		Constants.CardColor.BLUE: col_str = "blue"
		Constants.CardColor.GREEN: col_str = "green"
		_: col_str = "wild"
	var type_str: String = ""
	match card_type:
		Constants.CardType.SKIP: type_str = "skip"
		Constants.CardType.REVERSE: type_str = "reverse"
		Constants.CardType.DRAW_TWO: type_str = "draw2"
		_: type_str = str(value)
	return "res://resources/cards/%s_%s.svg" % [col_str, type_str]

## Static factory methods for convenience
static func create_number(p_color: Constants.CardColor, p_num: int) -> Card:
	return Card.new(p_color, p_num as Constants.CardType, p_num)

static func create_action(p_color: Constants.CardColor, p_type: Constants.CardType) -> Card:
	return Card.new(p_color, p_type, -1)

static func create_wild() -> Card:
	return Card.new(Constants.CardColor.WILD, Constants.CardType.WILD, -1)

static func create_wild_draw_four() -> Card:
	return Card.new(Constants.CardColor.WILD, Constants.CardType.WILD_DRAW_FOUR, -1)
