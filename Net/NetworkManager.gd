extends Node

# Placeholder: NetworkManager for ENet-based multiplayer.
# This will be expanded in later tasks to handle host/client connection lifecycle.

var is_host: bool = false
var is_connected: bool = false

func start_host(port: int) -> void:
    # Placeholder: will call ENetMultiplayerPeer in later tasks.

func connect_host(host_address: string, port: int) -> void:
    # Placeholder: will call ENetMultiplayerPeer.connect() in later tasks.

func disconnect() -> void:
    is_connected = false
