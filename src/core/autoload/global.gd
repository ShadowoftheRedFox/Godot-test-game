# Global node under GameState
extends Node

## A reference to the player node
var player: Player

## Save manager script that handle save/load of files for the game
var SM: SaveModule = SaveModule.new()
## Constant manager for global constant
var CONST: ConstantManager = ConstantManager.new()
## Sound manager that handle sound mixing
var SDM: SoundManager = SoundManager.new()
## A reference to the console
var CONSOLE: ConsoleModule = ConsoleModule.new()
## A reference to the current environment
## Can be null if there is no environment
# when the controller is initialized, it'll set himself up here
var environment: EnvironmentController = null

func _ready() -> void:
	# load parameters
	SM.load_parameters()
	# find saves files if any
	# TODO SM.find_saves()

## Function to call when quitting. It will perform the necessary actions before quitting.
func quit_game() -> void:
	# notify everyone that we're quitting the game
	# so they can clean up, save, etc... cleanly
	# to listen, use _unhandled_input(event:InputEvent) 
	# with event.is_action_pressed(&"debug_quit")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
