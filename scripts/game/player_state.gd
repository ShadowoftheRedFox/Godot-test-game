# Global node under GameState
extends Node

## A reference to the player node
var player: Player
## The base attack of the player
var base_attack: int = 5;

## Function to call when quitting. It will perform the necessary actions before quitting.
func quit_game() -> void:
	get_tree().quit()
