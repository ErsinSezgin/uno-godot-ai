class_name NetworkManager
extends Node

## Placeholder: NetworkManager for ENet-based multiplayer.
## This will be expanded in later tasks to handle host/client connection lifecycle.

var is_host: bool = false
var is_connected: bool = false

func start_host(_port: int) -> void:
	pass

func connect_host(_host_address: String, _port: int) -> void:
	pass

func disconnect_network() -> void:
	is_connected = false
