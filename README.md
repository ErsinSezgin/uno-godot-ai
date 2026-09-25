# UNO Godot Multiplayer — Bonsai Task Pack

This is a deliberately small, task-driven starter structure for a Godot 4.x UNO-style multiplayer game.

## Goal

Build a playable multiplayer UNO game where:
- players enter a display name on a simple start screen;
- one player can host a game;
- friends connect over a direct network connection;
- everyone sees player names, hands, turn state, scores, and round/game results;
- the game supports the core UNO rules;
- the project is organized so a local coding agent can implement one task per session.

## Important scope choice

This starter uses Godot's high-level multiplayer API (`ENetMultiplayerPeer`) for the initial implementation. It is intentionally not an account/authentication system. Names are session-local.

For internet play, direct ENet connections may require port forwarding or a VPN/virtual LAN depending on the network. A relay/server can be added later as an optional task.

## Engine

Target: Godot 4.x.

Do not upgrade the project architecture unless a task explicitly asks for it.

## Running

Open `project.godot` in Godot 4.x and run the project.

The starter UI is intentionally minimal. The task list is the actual implementation plan.

## Agent workflow

For each session:
1. Read `TASKS.md`.
2. Pick exactly the next unchecked task.
3. Read only the files relevant to that task.
4. Implement the task.
5. Run the project or relevant tests.
6. Fix errors introduced by the task.
7. Mark the task `[x]`.
8. Stop. Do not implement later tasks "while you're here".

Keep changes small and inspectable.

## Definition of done

A task is done only when:
- the stated acceptance criteria are met;
- the project still launches;
- no unrelated feature work was added;
- obvious parse/runtime errors from the changed code are fixed.

## Suggested multiplayer architecture

- `Net/NetworkManager.gd`: peer setup and connection lifecycle.
- `Game/GameState.gd`: authoritative state/data model.
- `Game/UnoRules.gd`: pure rule/deck helpers where practical.
- `Game/GameServer.gd`: host-side authoritative game logic.
- `Game/GameClient.gd`: client-side presentation/network bridge.
- `UI/`: menus and game UI.

The host should be authoritative for game state. Clients send requests such as "play this card" or "draw"; the host validates them and broadcasts resulting state.

## Security / trust model

This is a friendly game, not an anti-cheat system. The host should still validate all client gameplay requests because clients cannot be trusted to obey turn/rule constraints.

## Suggested future deployment

For LAN testing, direct ENet is enough.

For internet play without port forwarding, add a small relay/dedicated server later. Keep the gameplay state model independent from the transport so this can be changed without rewriting UNO rules.
