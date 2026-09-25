# Bonsai 2-bit Task List

Implement exactly one unchecked task per session unless a task explicitly says otherwise.

**Session tracking:** The next agent should read this file to see which tasks are complete. Tasks marked `[x]` are done; `[ ]` need to be implemented.

Status convention:
- `[ ]` not started
- `[x]` complete

Each task is intentionally small enough to fit comfortably inside a ~40k context-window coding session.

---

## Phase 0 — Project foundation

### T001 — [x] Verify Godot project skeleton (done)
- Goal: Make sure the project opens and runs.
- Files: `project.godot`, `Main.tscn`, `Main.gd`.
- Acceptance:
  - Godot 4.x opens the project.
  - Running the project shows a basic placeholder screen.
  - No parser/runtime errors.
- Do not add gameplay.

### T002 — [x] Create folder/module skeleton
- Goal: Create the planned `Game/`, `Net/`, and `UI/` directories and empty/minimal scripts.
- Acceptance:
  - Folders exist.
  - Scripts parse.
  - Project still runs.
- Do not implement networking or rules.

### T003 — [x] Add shared game constants
- Goal: Add a small constants/data definition for UNO colors, action types, and player limits.
- Acceptance:
  - Constants are accessible from gameplay code.
  - No duplicated string literals for core card colors/types in new code.
- Do not create deck logic yet.

---

## Phase 1 — Offline UNO model

### T004 — [x] Implement card data object
- Goal: Represent one UNO card with color and type/value.
- Acceptance:
  - Card can be created and inspected.
  - String/debug representation is useful.
  - No UI required.

### T005 — Implement deck construction
- Goal: Build the standard UNO deck data set.
- Acceptance:
  - Deck contains the intended standard card counts.
  - Wild cards are represented correctly.
  - Deck can be created repeatedly without shared mutable state.

### T006 — [x] Implement shuffle and draw pile
- Goal: Add a shuffled draw pile abstraction.
- Acceptance:
  - Shuffle changes order.
  - Drawing removes cards from the draw pile.
  - Drawing from an empty pile is handled explicitly.

### T007 — Implement discard pile and reshuffle support
- Goal: Add discard pile handling and a method to replenish the draw pile from eligible discarded cards.
- Acceptance:
  - Top discard is tracked.
  - Replenishing preserves the active top card.
  - Wild-card state needed for the active color is not accidentally lost.

### T008 — Implement player model
- Goal: Represent a session player with ID, display name, hand, score, and connection-ready metadata.
- Acceptance:
  - Player data can be created and serialized to a plain Dictionary.
  - No UI/networking.

### T009 — Implement pure card legality checks
- Goal: Decide whether a card is playable against the current top card and active color.
- Acceptance:
  - Same color works.
  - Same type/value works.
  - Wild works.
  - Invalid cards are rejected.
  - Logic is deterministic and has no UI dependency.

### T010 — Implement turn-order helpers
- Goal: Add helpers for next/previous player and direction reversal.
- Acceptance:
  - 2+ player order works.
  - Reverse changes direction.
  - Skip can advance correctly.
  - Edge cases wrap around.

### T011 — Implement round setup
- Goal: Create a fresh round state: players, deck, initial hands, discard card, active color, current player.
- Acceptance:
  - Valid starting state is produced.
  - Initial hands have the configured card count.
  - Starting discard handling is explicit and deterministic enough for tests.
- Keep special opening-card rules simple and documented.

### T012 — Implement play-card state transition
- Goal: Given a valid player/card choice, update the round state.
- Acceptance:
  - Card leaves player's hand.
  - Card enters discard pile.
  - Active color updates when needed.
  - Turn advances according to the card.
- Do not implement network RPCs.

### T013 — Implement draw-card state transition
- Goal: Draw one card for the current player, including draw-pile replenishment.
- Acceptance:
  - Exactly one card is drawn when possible.
  - Player hand updates.
  - Empty-pile behavior is handled.
  - Turn behavior is represented by explicit state.

### T014 — Implement UNO declaration and penalty state
- Goal: Track whether a player has declared UNO and represent the penalty condition.
- Acceptance:
  - Player can declare UNO at the appropriate time.
  - State can represent a failed declaration/penalty.
  - No networking/UI.

### T015 — Implement round-end and scoring
- Goal: Detect a winner and calculate scores from remaining opponents' cards.
- Acceptance:
  - Round ends when a hand reaches zero.
  - Card point values are centralized.
  - Winner's score increment is deterministic.
  - Game state can start another round.

---

## Phase 2 — Basic UI

### T016 — Build name entry screen
- Goal: Create a simple screen where a player enters a display name.
- Acceptance:
  - Empty names are rejected or replaced with a clear validation message.
  - Name is stored locally for the session.
  - Continue button changes to the next screen.

### T017 — Build host/join screen
- Goal: Add Host and Join controls plus address/port fields.
- Acceptance:
  - Host button can call a placeholder NetworkManager API.
  - Join button can call a placeholder NetworkManager API.
  - UI shows connection status text.
- Do not implement actual networking yet.

### T018 — Build lobby screen
- Goal: Show connected player names and host start control.
- Acceptance:
  - Lobby can display a list of player records.
  - Host has Start Game control.
  - Non-host players see a waiting state.

### T019 — Build basic game table UI
- Goal: Display top discard card, active color, current player, and local hand.
- Acceptance:
  - UI can render sample/mock state.
  - Cards are readable.
  - No networking required yet.

### T020 — Build card interaction UI
- Goal: Make local hand cards clickable/selectable.
- Acceptance:
  - Selected card has visible feedback.
  - Invalid selection can show a simple message.
  - UI emits a clear play-card intent.

### T021 — Build wild-color chooser
- Goal: Show a four-color choice when a wild card requires choosing a color.
- Acceptance:
  - Four choices are displayed.
  - Selection returns a color value.
  - Cancel/invalid states are handled.

### T022 — Build scoreboard UI
- Goal: Display player names, round score, and basic totals.
- Acceptance:
  - Scores update from a supplied data structure.
  - Current player/turn can be visually identified.
  - UI works with mock data.

### T023 — Build round/game result UI
- Goal: Show round winner and updated scoreboard.
- Acceptance:
  - Winner name is displayed.
  - Continue/new-round action exists.
  - UI can be driven without network code.

---

## Phase 3 — Networking foundation

### T024 — Implement NetworkManager host
- Goal: Create an ENet server and expose connection signals.
- Acceptance:
  - Host can start on configurable port.
  - Listening success/failure is surfaced.
  - Clean shutdown works.

### T025 — Implement NetworkManager client
- Goal: Connect to a host by address and port.
- Acceptance:
  - Client can connect to a host.
  - Connection success/failure/disconnect are surfaced.
  - Clean disconnect works.

### T026 — Define network message envelope
- Goal: Define one consistent Dictionary-based message format.
- Acceptance:
  - Message type and payload are standardized.
  - Version field exists.
  - Serialization/deserialization helpers exist.
- Do not send gameplay messages yet.

### T027 — Implement lobby join/leave synchronization
- Goal: Host assigns a stable peer/player ID and broadcasts lobby state.
- Acceptance:
  - Joining clients appear for everyone.
  - Disconnecting clients disappear.
  - Display names are synchronized.
  - Host remains authoritative.

### T028 — Implement host start-game request
- Goal: Let the host start the game through the network layer.
- Acceptance:
  - Only host can start.
  - All clients receive a game-start event.
  - Initial state is identical on all clients.

### T029 — Implement authoritative state snapshot
- Goal: Serialize enough game state for clients to render the current round.
- Acceptance:
  - Snapshot includes players, visible game state, scores, turn, active color, and each client's own hand.
  - Other players' hands remain hidden.
  - Snapshot can be applied without duplicating cards.

### T030 — Implement state synchronization after reconnect
- Goal: When a client reconnects during a lobby/game-supported state, host can send a fresh snapshot.
- Acceptance:
  - A new client can render the current authoritative state.
  - No duplicate player entries are created.
- If reconnecting mid-game is too large for the current architecture, document the limitation and support lobby-only reconnect first.

---

## Phase 4 — Multiplayer gameplay

### T031 — Network play-card request
- Goal: Client requests playing a specific card; host validates it.
- Acceptance:
  - Invalid player/turn/card requests are rejected.
  - Valid requests update host state.
  - Host broadcasts resulting snapshot/event.

### T032 — Network draw-card request
- Goal: Client requests a draw; host validates and applies it.
- Acceptance:
  - Only current player can draw.
  - Host controls the random draw.
  - Result reaches all clients.

### T033 — Network wild-color request
- Goal: Complete the network flow for choosing a color after a wild card.
- Acceptance:
  - Host validates that a color choice is required.
  - Active color updates once.
  - All clients receive the result.

### T034 — Network UNO declaration
- Goal: Synchronize UNO declaration and penalty state.
- Acceptance:
  - Declaration request is host-validated.
  - All clients see the relevant status.
  - Penalty is applied according to the rules defined in T014.

### T035 — Network round completion and scoring
- Goal: Synchronize winner detection and score updates.
- Acceptance:
  - All clients see the same winner.
  - Scores are updated once.
  - Host can begin the next round.

### T036 — Prevent duplicate/out-of-order client actions
- Goal: Make gameplay requests robust against repeated clicks and stale state.
- Acceptance:
  - Repeated play/draw requests do not duplicate actions.
  - Requests with stale turn/state identifiers are rejected.
  - Host state remains authoritative.

### T037 — Add basic disconnect handling
- Goal: Handle a player leaving during lobby and game.
- Acceptance:
  - Remaining clients are informed.
  - Lobby removes the player.
  - Mid-round behavior is deterministic and documented.
  - No crash when the disconnected player was current player.

---

## Phase 5 — Rules and UX polish

### T038 — Add configurable game settings
- Goal: Add small settings for player count, target score, and optional rule toggles.
- Acceptance:
  - Settings are represented in one game configuration object.
  - Defaults preserve current behavior.
  - Host controls the game configuration.

### T039 — Add UNO button/flow
- Goal: Add a clear in-game UNO button and timing feedback.
- Acceptance:
  - Button is visible when useful.
  - Feedback tells the player whether the declaration was accepted.

### T040 — Add playable-card highlighting
- Goal: Highlight cards the current player can legally play.
- Acceptance:
  - Highlight matches the same legality function used by gameplay.
  - It never becomes a second rule implementation.

### T041 — Add basic animations and feedback
- Goal: Add lightweight card/turn feedback without changing game logic.
- Acceptance:
  - Playing/drawing a card has simple visual feedback.
  - Turn changes are noticeable.
  - Animations cannot block network state updates.

### T042 — Add error/status messages
- Goal: Centralize user-facing network/game errors.
- Acceptance:
  - Connection errors, invalid actions, and host shutdown have readable messages.
  - No raw engine error strings are required for normal users.

### T043 — Add rematch/new-round flow
- Goal: Let the host start another round after a round ends.
- Acceptance:
  - Scores persist.
  - Hands/deck reset.
  - Player order/configuration remains consistent.

### T044 — Add graceful host shutdown
- Goal: Tell clients the session ended before closing the peer.
- Acceptance:
  - Clients return to the start/menu screen.
  - No stale lobby state remains.

---

## Phase 6 — Testing and packaging

### T045 — Add automated tests for UNO rules
- Goal: Cover deck counts, legality, turn order, scoring, and key state transitions.
- Acceptance:
  - Tests can run from Godot's test setup or a simple project test scene.
  - Core rule regressions are caught.

### T046 — Add multiplayer smoke-test checklist
- Goal: Document a repeatable two/three-client test procedure.
- Acceptance:
  - LAN host/join steps are documented.
  - Common failure modes are documented.
  - Test covers join, start, play, draw, wild, UNO, scoring, disconnect.

### T047 — Clean project and remove placeholders
- Goal: Remove dead code, mock-only UI paths, and unused assets.
- Acceptance:
  - No known placeholder warnings relevant to release.
  - Project still launches and multiplayer smoke test passes.

### T048 — Create desktop export presets
- Goal: Configure export presets for the target desktop platforms.
- Acceptance:
  - Export configuration exists.
  - A debug build can be produced for at least the primary development OS.

### T049 — Final README for players
- Goal: Explain how to host, join, enter names, and play.
- Acceptance:
  - A friend can follow the instructions without reading source code.
  - LAN and internet/network limitations are clearly stated.

### T050 — Final architecture review
- Goal: Review the completed project against this task plan.
- Acceptance:
  - No known task regressions.
  - Host-authoritative gameplay is preserved.
  - Networking is separated enough that a relay/dedicated server could be added later.
  - Document remaining known limitations.

---

## Agent rules

1. One task per session.
2. Never silently skip acceptance criteria.
3. Do not redesign completed architecture without a concrete bug/reason.
4. Prefer small functions and data objects.
5. Keep rules independent from UI.
6. Keep network transport independent from UNO rules where practical.
7. Host is authoritative.
8. Never trust client-provided card legality, turn ownership, scores, or random outcomes.
9. Do not add accounts, databases, matchmaking, cosmetics, chat, or monetization unless a later task explicitly asks for them.
10. When uncertain, stop and document the ambiguity instead of implementing a large speculative feature.

11. Always commit your changes to remote `origin` after finishing a task.