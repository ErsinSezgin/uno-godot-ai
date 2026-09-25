# Discard pile management for UNO gameplay.

# Handles the discard pile and provides reshuffle/replenish logic to return
# eligible discarded cards back into the draw pile.  The "active top card" (the
# most recently played card) is preserved during replenishment so that the active
# color / type can be continued into the next round.

import '../Constants.gd'
import '../Card.gd'

# The discard pile is an ordered list of Card objects.  Index 0 is the oldest
# discarded card; index -1 (the end) is the top card (most recently played).
var cards: List[Card]

# Cached reference to the top card for quick access.  Updated whenever the
# pile is modified.
var top_card: Card = null

# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------

func new() -> "Game.Discard":
    self.cards.clear()
    return self

# ---------------------------------------------------------------------------
# Core operations ----------------------------------------------------------

func push(card: Card) -> void:
    """Add a card to the discard pile (most recently played).

    The card becomes the new top card.
    """
    self.cards.append(card)
    self.top_card = card

func pop() -> Card:
    """Remove and return the top card from the discard pile.

    Returns null when the pile is empty (used during reshuffle).
    """
    if is_empty():
        return null

    removed = self.cards.pop(-1)
    # Update top card to the new most-recently-played card.
    self.top_card = null if is_empty() else self.cards[-1]
    return removed

@export var is_empty() -> bool:
    return len(self.cards) == 0

@export func card_count() -> int:
    return len(self.cards)

# ---------------------------------------------------------------------------
# Replenish / reshuffle helpers --------------------------------------------

func eligible_for_reshuffle(active_color: Optional[Color] = null,
                           active_type: Optional[ActionType] = null) -> List[Card]:
    """Return a list of discarded cards that can be returned to the draw pile.

    A card is eligible if it matches either:
      - The active color (when `active_color` is set), or
      - The active type/action type (when `active_type` is set).

    Wild cards are always eligible.

    Important: the returned list does NOT remove cards from the discard
    pile — callers are responsible for calling `pop()` to actually reclaim them.

    Parameters:
      active_color: The current active color (Red, Yellow, Blue, Green).
                    Set to null if no color has been established yet.
      active_type:  The current active action type (Color or Type).
                    Set to null if no type has been established yet.

    Returns:
      A list of eligible Card objects, oldest first.
    """
    if is_empty():
        return []

    eligible = []
    for card in self.cards:
        if active_color is not null and card.matches_color(active_color):
            eligible.append(card)
        elif active_type is not null and card.matches_action_type(active_type):
            eligible.append(card)

    return eligible

func replenish(draw_deck: "Game.Deck", active_color: Optional[Color] = null,
               active_type: Optional[ActionType] = null) -> int:
    """Move eligible discarded cards back into the draw deck.

    Returns the number of cards moved from discard to draw pile.
    """
    eligible = eligible_for_reshuffle(active_color, active_type)

    moved_count = 0
    for card in eligible:
        # Remove from discard pile (pops from the end, which is oldest first)
        idx = self.cards.find(card)
        if idx >= 0:
            # Remove by index (safe since we're iterating over a copy).
            self.cards.remove_at(idx)

            # Push into draw deck (goes to the bottom of the draw pile).
            draw_deck.cards.insert(0, card)

            moved_count += 1

    # Update top card to the most recently played (still at index -1).
    if is_empty():
        self.top_card = null
    else:
        self.top_card = self.cards[-1]

    return moved_count

# ---------------------------------------------------------------------------
# Convenience: peek at the top card without removing it. ---------------------

func peek_top() -> Card:
    """Return the top card without removing it.

    Returns null when the pile is empty.
    """
    return self.top_card

# ---------------------------------------------------------------------------
# Utility: check if a specific card is in the discard pile. ------------------

func contains(card: Card) -> bool:
    """Return true if the discard pile contains a copy of `card`.

    Uses value equality (same type and value), not reference equality.
    """
    for c in self.cards:
        if c.is_same_as(card):
            return true

    return false

# ---------------------------------------------------------------------------
# Utility: clear the discard pile. -----------------------------------------

func clear() -> void:
    self.cards.clear()
    self.top_card = null
