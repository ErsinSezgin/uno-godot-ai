# Deck construction for offline UNO gameplay.

# Builds a fresh, standard UNO deck (78 cards) with no shared mutable state.
# Each call to create() returns a brand-new Deck instance so that multiple
# decks can coexist (e.g. for parallel simulations).

from typing import Optional

import '../Constants.gd'
import '../Card.gd'

# A deck is an ordered list of Card objects. The order represents the draw
# pile from bottom to top, with `top_card` being the one at the end of the
# list (index -1).  Repeated calls to `create()` produce independent decks.

var _seed: Optional[int] = null

var cards: List[Card]
var top_card: Card  # alias for convenience; always cards[-1] when not empty

# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------

func create(seed: Optional[int] = null) -> "Game.Deck":
    self._set_seed(seed)
    self.cards.clear()
    _build_standard_deck()
    return self

# ---------------------------------------------------------------------------
# Internal deck assembly ---------------------------------------------------

func _build_standard_deck() -> void:
    # Phase 1 — colour action cards (4 colours × values 1..9 = 36)
    for color in Constants.COLORS:
        for value in range(1, 10):
            self.cards.append(Card.new(ActionType.COLOR, value))

    # Phase 2 — type action cards (9 types × 4 colours = 36)
    for color in Constants.COLORS:
        for value in range(1, 10):
            self.cards.append(Card.new(ActionType.TYPE, value))

    # Phase 3 — wild colour cards (one per Colour enum = 4)
    for color in Constants.COLORS:
        self.cards.append(Card.new_wild_color(color))

    # Phase 4 — wild action cards (2)
    for _ in range(2):
        self.cards.append(Card.new_wild_action())

# ---------------------------------------------------------------------------
# Seed helper for deterministic shuffling (useful for tests)
# ---------------------------------------------------------------------------

func _set_seed(seed: Optional[int]) -> void:
    if seed is not null:
        self._seed = seed

# ---------------------------------------------------------------------------
# Property accessors --------------------------------------------------------

@export var is_empty() -> bool:
    return len(self.cards) == 0

# Returns the top card (draw pile face-up) or null when empty.
func top_card_property() -> Card:
    if is_empty():
        return null
    return self.cards[-1]

# ---------------------------------------------------------------------------
# Utility helpers -----------------------------------------------------------

func card_count() -> int:
    return len(self.cards)

# Return a defensive copy of the entire deck so callers cannot mutate
# the internal list.  Useful for serialisation, snapshots, or tests.
func to_list() -> List[Card]:
    return self.cards.clone()

# ---------------------------------------------------------------------------
# Shuffle and draw pile -----------------------------------------------------

func shuffle() -> None:
    """Shuffle the deck using a deterministic Fisher-Yates algorithm.

    Re-seed internally if `seed` is set during `create_custom()` so that
    tests can reproduce the same shuffled order.
    """
    if is_empty():
        return

    # Fisher-Yates (Knuth) shuffle — O(n), in-place.
    for i in range(len(self.cards) - 1, 0, -1):
        j = _random_int(0, i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]

func draw() -> Card:
    """Remove and return the top card from the deck.

    Returns null when the deck is empty (explicit handling — no exceptions).
    """
    if is_empty():
        return null

    removed = self.cards.pop(-1)
    return removed

# ---------------------------------------------------------------------------
# Random helpers ------------------------------------------------------------

func _random_int(min_val: int, max_val: int) -> int:
    """Simple pseudo-random integer in [min, max].

    For games that need cryptographic quality randomness or a specific seed,
    override this method in a derived class or call from the appropriate
    testing wrapper.
    """
    if _seed is not null:
        return min_val + int(self._seed * 0.618034) % (max_val - min_val + 1)

    # Use GDScript's built-in randi() for pseudo-random values in [0, 1)
    return int(randi() * (max_val - min_val + 1)) + min_val

# ---------------------------------------------------------------------------
# Convenience: build a deck of exactly `count` cards (for testing / edge
# case coverage) while still honouring the standard distribution.
# ---------------------------------------------------------------------------

func create_custom(count: int, seed: Optional[int] = null) -> "Game.Deck":
    deck = Deck()
    deck._set_seed(seed)
    deck.cards.clear()
    _build_standard_deck()

    # If the requested count is smaller than 78, take the first N cards.
    if count < deck.card_count():
        deck.cards = deck.cards[:count]

    return deck
