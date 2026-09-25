extends Node

import '../Game/Card.gd'
import '../Game/Constants.gd'

func _ready() -> void:
    run_tests()
    print("All Card tests passed.")

func run_tests() -> void:
    # Test 1: Create a red 5 card
    var card = Card.new(Color.RED, 5)
    assert(card.type == ActionType.COLOR)
    assert(card.value == 5)

    # Test 2: Wild color card
    var wild_color = Card.new_wild_color(Color.RED)
    assert(wild_color.type == ActionType.COLOR)
    assert(wild_color.value == 0)
    assert(wild_color.is_wild())

    # Test 3: Wild action card
    var wild_action = Card.new_wild_action()
    assert(wild_action.type == ActionType.TYPE)
    assert(wild_action.value == 0)
    assert(wild_action.is_wild())

    # Test 4: Type card
    var type_card = Card.new_type_card(5)
    assert(type_card.type == ActionType.TYPE)
    assert(type_card.value == 5)

    # Test 5: matches_color works for non-wild
    assert(card.matches_color(Color.RED))
    assert(!card.matches_color(Color.YELLOW))

    # Test 6: matches_color works for wild
    assert(wild_color.matches_color(Color.RED))
    assert(wild_color.matches_color(Color.YELLOW))

    # Test 7: matches_action_type
    assert(card.matches_action_type(ActionType.COLOR))
    assert(!card.matches_action_type(ActionType.TYPE))

    # Test 8: to_dict / from_dict roundtrip
    var d = card.to_dict()
    var cloned = Card.new(d["type"], d["value"])
    assert(card.is_same_as(cloned))

    # Test 9: __repr__ produces expected string
    assert(card.__repr__().startswith("Card(type="))
