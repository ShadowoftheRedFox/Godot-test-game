extends BaseScene

@onready var mark: Marker3D = $Marker3D

func get_default_player_spawn() -> Vector3:
	return mark.position
