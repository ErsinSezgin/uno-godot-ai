# UNO card resources

These are original, simple vector card assets intended as a starter art pack for the Godot UNO project.

## Files

- `red_0.svg` ... `blue_9.svg`: number cards
- `*_skip.svg`, `*_reverse.svg`, `*_draw2.svg`: colored action cards
- `wild.svg`, `wild_draw4.svg`: core wild cards
- `wild_swap.svg`, `wild_color.svg`: optional/custom wild cards
- `card_back.svg`: card back
- `../reference/card_design_sheet.png`: generated visual reference sheet

## Godot

You can place this `resources` directory at the root of the Godot project and load the SVGs directly as `Texture2D` resources.

For example:
`res://resources/cards/red_7.svg`

The art is intentionally separated from the game logic so the card visuals can be replaced later without changing the UNO rules.

## Note

The project task list uses standard UNO-style cards as its baseline. `wild_swap.svg` and `wild_color.svg` are included as optional custom visuals; do not add their gameplay rules unless you explicitly want those variants.
