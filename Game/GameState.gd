class_name GameState
extends Node

## Authoritative GameState model for UNO.
## Manages players, deck, discard pile, turn order, active color, and round setup.
## Pure game model independent of networking and UI.

var players: Array[Player] = []
var deck: Deck = null
var discard_pile: DiscardPile = null
var turn_order: TurnOrder = null

var is_round_active: bool = false
var round_number: int = 0
var current_player: int = -1
var active_color: Constants.CardColor = Constants.CardColor.WILD

# Legacy / convenience dictionary
var round_state: Dictionary = {}
var scores: Dictionary = {}

## Adds a player to the session.
func add_player(player: Player) -> void:
	if player != null and not players.has(player):
		players.append(player)
		scores[player.id] = player.score

## Returns the player currently taking their turn, or null if no round is active.
func get_current_player() -> Player:
	if turn_order == null or players.is_empty():
		return null
	var idx = turn_order.get_current_index()
	if idx >= 0 and idx < players.size():
		return players[idx]
	return null

## Returns a player by their ID, or null if not found.
func get_player_by_id(id: int) -> Player:
	for p in players:
		if p.id == id:
			return p
	return null

## Returns number of players in the game.
func get_player_count() -> int:
	return players.size()

## Returns the top card of the discard pile.
func get_top_card() -> Card:
	if discard_pile == null:
		return null
	return discard_pile.get_top_card()

## Returns the effective active color.
func get_active_color() -> Constants.CardColor:
	if discard_pile != null:
		return discard_pile.get_active_color()
	return active_color

## Resets round state and clears hands.
func reset_round() -> void:
	is_round_active = false
	current_player = -1
	active_color = Constants.CardColor.WILD
	round_state.clear()
	for p in players:
		p.clear_hand()
		p.has_declared_uno = false
	if deck != null:
		deck.cards.clear()
	if discard_pile != null:
		discard_pile.clear()

## Sets up and begins a new round.
##
## Special opening-card rules (documented):
## - NUMBER (0-9): Normal start. First player (index 0) begins. Active color is card color.
## - SKIP: First player (index 0) is skipped. Play begins with player 1 (or next in order).
## - REVERSE: Direction reverses. In 2-player game, acts as skip (player 0 skipped).
##            In 3+ players, dealer/host reverses order and player at new next index begins.
## - DRAW_TWO: First player (index 0) draws 2 cards and their turn is skipped.
## - WILD: First player may choose starting color (defaults to WILD until chosen, or can match any color).
## - WILD_DRAW_FOUR: Official UNO rule: returned to bottom of deck and another card is flipped.
func setup_round(
	player_list: Array = [],
	rng: RandomNumberGenerator = null,
	custom_deck: Deck = null,
	custom_starting_card: Card = null,
	cards_per_player: int = Constants.INITIAL_HAND_SIZE
) -> bool:
	if not player_list.is_empty():
		players.clear()
		for p in player_list:
			add_player(p)

	if players.size() < Constants.MIN_PLAYER_COUNT:
		return false

	# Reset player hands and UNO state for new round (preserve cumulative score)
	for p in players:
		p.clear_hand()
		p.has_declared_uno = false

	round_number += 1

	# Initialize deck
	if custom_deck != null:
		deck = custom_deck
	else:
		deck = Deck.new(true)
		deck.shuffle(rng)

	# Deal initial hands to all players
	for _round in range(cards_per_player):
		for p in players:
			var drawn = deck.draw()
			if drawn != null:
				p.add_card(drawn)

	# Initialize discard pile and opening card
	discard_pile = DiscardPile.new()
	var starting_card: Card = custom_starting_card

	if starting_card == null:
		# Draw from deck until eligible starting card is found
		# Official UNO rule: Wild Draw Four cannot be opening card; return to deck and redraw
		while true:
			var candidate = deck.draw()
			if candidate == null:
				break
			if candidate.card_type == Constants.CardType.WILD_DRAW_FOUR:
				deck.add_card(candidate, false) # Return to bottom of deck
			else:
				starting_card = candidate
				break

	if starting_card == null:
		return false

	discard_pile.discard(starting_card)

	# Initialize turn order
	var player_ids_list: Array = []
	for p in players:
		player_ids_list.append(p.id)

	turn_order = TurnOrder.new(players.size(), 0, TurnOrder.Direction.CLOCKWISE)
	turn_order.set_players(player_ids_list)

	# Apply opening card rules
	_apply_opening_card_rules(starting_card)

	active_color = discard_pile.get_active_color()
	current_player = turn_order.get_current_index()
	is_round_active = true

	# Update scores dictionary
	for p in players:
		scores[p.id] = p.score

	return true

## Internal helper implementing documented opening-card effects.
func _apply_opening_card_rules(card: Card) -> void:
	if card == null:
		return

	if card.card_type == Constants.CardType.SKIP:
		# First player is skipped
		turn_order.advance_turn(1)
	elif card.card_type == Constants.CardType.REVERSE:
		turn_order.reverse_direction()
		if players.size() == 2:
			# In 2-player UNO, Reverse acts like a Skip
			turn_order.advance_turn(1)
		else:
			# Direction reversed from dealer: next turn advances in reversed direction
			turn_order.advance_turn(1)
	elif card.card_type == Constants.CardType.DRAW_TWO:
		# First player draws 2 cards and is skipped
		var first_player = players[0]
		first_player.add_cards(deck.draw_cards(2))
		turn_order.advance_turn(1)
	elif card.card_type == Constants.CardType.WILD:
		# Color is wild; first player can choose or play any card
		discard_pile.set_active_color(Constants.CardColor.WILD)

## Serializes the game state snapshot.
## If for_peer_id >= 0, only that peer's hand is visible; other players' hands are hidden.
func to_dict(for_peer_id: int = -1) -> Dictionary:
	var players_data: Array = []
	for p in players:
		var include_hand: bool = (for_peer_id == -1) or (p.id == for_peer_id)
		players_data.append(p.to_dict(include_hand))

	return {
		"is_round_active": is_round_active,
		"round_number": round_number,
		"current_player": current_player,
		"active_color": int(get_active_color()),
		"top_card": get_top_card().to_dict() if get_top_card() != null else null,
		"deck_card_count": deck.card_count() if deck != null else 0,
		"discard_card_count": discard_pile.card_count() if discard_pile != null else 0,
		"turn_order": turn_order.to_dict() if turn_order != null else null,
		"players": players_data,
		"scores": scores.duplicate(),
	}
