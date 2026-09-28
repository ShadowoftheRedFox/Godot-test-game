@tool
class_name ItemFileWatcher extends EditorScript

func _check() -> void:
	# simply call load items
	# this will check items as if the game was starting up
	ConstantManager.new()
