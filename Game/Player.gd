class_name Player
extends RefCounted

## Represents a player in a game session.
## Holds player identity, display name, current card hand, total score,
## and connection-ready session metadata (e.g. peer_id, is_host, is_connected).
## Pure data model with no UI or networking dependencies.

var id: int = 0
var name: String = ""
var hand: Array[Card] = []
var score: int = 0
var is_host: bool = false
var is_connected: bool = true
var peer_id: int = 0
var has_declared_uno: bool = false

func _init(p_id: int = 0, p_name: String = "", p_is_host: bool = false) -> void:
	id = p_id
	name = p_name
	is_host = p_is_host
	peer_id = p_id

## Returns number of cards currently in player's hand.
func hand_size() -> int:
	return hand.size()

## Returns true if player has no cards in hand.
func is_hand_empty() -> bool:
	return hand.is_empty()

## Returns true if the player has an identical card in hand.
func has_card(target_card: Card) -> bool:
	if target_card == null:
		return false
	for c in hand:
		if c.is_same_as(target_card):
			return true
	return false

## Adds a single card to player's hand.
func add_card(card: Card) -> void:
	if card != null:
		hand.append(card)

## Adds multiple cards to player's hand.
func add_cards(new_cards: Array[Card]) -> void:
	for c in new_cards:
		add_card(c)

## Removes the first matching card from player's hand.
## Returns true if found and removed, false otherwise.
func remove_card(target_card: Card) -> bool:
	if target_card == null:
		return false
	for i in range(hand.size()):
		if hand[i].is_same_as(target_card):
			hand.remove_at(i)
			return true
	return false

## Removes and returns the card at index, or null if index is out of bounds.
func remove_card_at(index: int) -> Card:
	if index < 0 or index >= hand.size():
		return null
	return hand.pop_at(index)

## Clears all cards from hand.
func clear_hand() -> void:
	hand.clear()

## Returns total point value of all cards currently held in hand.
func calculate_hand_points() -> int:
	var total: int = 0
	for c in hand:
		total += c.get_points()
	return total

## Adds points to the player's cumulative score.
func add_score(points: int) -> void:
	score += points

## Resets player's cumulative score to 0.
func reset_score() -> void:
	score = 0

## Serializes player data to a plain Dictionary.
## If include_hand is false, hand contents remain empty while card_count reflects hand size.
func to_dict(include_hand: bool = true) -> Dictionary:
	var hand_data: Array = []
	if include_hand:
		for c in hand:
			hand_data.append(c.to_dict())
	return {
		"id": id,
		"name": name,
		"score": score,
		"is_host": is_host,
		"is_connected": is_connected,
		"peer_id": peer_id,
		"has_declared_uno": has_declared_uno,
		"card_count": hand.size(),
		"hand": hand_data,
	}

## Deserializes a Player instance from a Dictionary.
static func from_dict(data: Dictionary) -> Player:
	var p = Player.new(
		data.get("id", 0),
		data.get("name", ""),
		data.get("is_host", false)
	)
	p.score = data.get("score", 0)
	p.is_connected = data.get("is_connected", true)
	p.peer_id = data.get("peer_id", p.id)
	p.has_declared_uno = data.get("has_declared_uno", false)
	p.hand.clear()
	var hand_data: Array = data.get("hand", [])
	for c_data in hand_data:
		if c_data is Dictionary:
			p.hand.append(Card.from_dict(c_data))
	return p

func _to_string() -> String:
	return "Player(id=%d, name='%s', cards=%d, score=%d, host=%s, connected=%s)" % [
		id, name, hand.size(), score, str(is_host), str(is_connected)
	]
