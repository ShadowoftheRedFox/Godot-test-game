# Global node under GameState
extends Node

## A reference to the player node
var player: Player
## The base attack of the player
var base_attack: int = 5;

## Save manager script that handle save/load of files for the game
var SM: SaveModule = SaveModule.new()
## Constant manager for global constant
var CONST: ConstantManager = ConstantManager.new()
## Sound manager that handle sound mixing
var SdM: SoundManager = SoundManager.new()
## A reference to the console
var CONSOLE: ConsoleModule = ConsoleModule.new()

func _ready() -> void:
	# load parameters
	SM.load_parameters()

## Function to call when quitting. It will perform the necessary actions before quitting.
func quit_game() -> void:
	get_tree().quit()
