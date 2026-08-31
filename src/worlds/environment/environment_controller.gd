#@tool
class_name EnvironmentController extends WorldEnvironment

## The length of the day in seconds.
const DAY_LENGTH: int = 2400
## The length of an in game hour in seconds.
const DAY_HOURS_LENGTH: int = 100
## The length of an in game minute in seconds.
@warning_ignore("integer_division")
const HOUR_MINUTES_LENGTH: int = EnvironmentController.DAY_LENGTH / EnvironmentController.DAY_HOURS_LENGTH

enum Weather {
	CLEAR,
	SLIGHT_CLOUD,
	CLOUDY,
	VERY_CLOUDY
}

enum Fog {
	CLEAR,
	SLIGHT_FOG,
	FOG,
	VERY_FOGGY
}

## If the day night cycle is enabled
@export var day_night_cycle_enabled: bool = true
## Lentgh of a day in second
@export_range(1, 24 * 60 * 60) var day_length: int = 600

var angle_speed: float = 1.0

@onready var sun: DirectionalLight3D = %Sun

func _ready() -> void:
	set_day_length(day_length)

	# set itself as the global environment
	Global.environment = self

func _process(delta: float) -> void:
	if !day_night_cycle_enabled:
		return

	@warning_ignore("unsafe_cast")
	# when this script is in tool mode, recalculate the speed each time in case we edit it live
	if (get_script() as Script).is_tool():
		angle_speed = deg_to_rad(360.0 / day_length)

	#sun.rotate_x(angle_speed * delta)
	sun.rotate_object_local(Vector3.RIGHT, angle_speed * delta)

	# if the sun is below the horizon, disable light for the night
	if sun.rotation.x <= 0.0:
		sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
	else:
		sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY

## Get and return the current time of the day, between 0 and DAY_LENGTH.
func get_time() -> float:
	# since we use the rotation to get the time
	# rotation 0 is sunset, so rotation.x - PI/2 is midnight
	var rad: float = fmod(sun.rotation.x - PI / 2, TAU)
	# the angle can be negative, fix it
	if rad < 0.0:
		rad += TAU
	return (rad / TAU) * DAY_LENGTH

## change the current time of the day to the given value
func set_time(time: int) -> void:
	time = absi(time % DAY_LENGTH)
	sun.rotate(Vector3.RIGHT, float(time) / float(DAY_LENGTH) * TAU)

func set_day_length(length: int = DAY_LENGTH) -> void:
	if length <= 0:
		day_night_cycle_enabled = false

	day_length = length
	angle_speed = deg_to_rad(360.0 / float(day_length))

## Change the current weather
func set_weather(_weather: Weather) -> void:
	pass

## Change the current fog
func set_fog(_fog: Fog) -> void:
	pass

## Change the current wind
func set_wind(_direction: Vector2i, _strength: float) -> void:
	pass
