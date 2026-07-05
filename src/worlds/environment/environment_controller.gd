#@tool
class_name EnvironmentController extends WorldEnvironment 

## The length of the day.
const DAY_LENGTH: int = 2400

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
@export_range(1, 24*60*60) var day_length: int = 600

var angle_speed: float = 1.0

@onready var sun: DirectionalLight3D = %Sun

func _ready() -> void:
	 # transform day_lentgh to randians per seconds
	angle_speed = deg_to_rad(360.0 / day_length)
	
	# set itself as the global environment
	Global.environment = self

func _process(delta: float) -> void:
	if !day_night_cycle_enabled:
		return
	
	@warning_ignore("unsafe_cast")
	# when this script is in tool mode, recalculate the speed each time in case we edit it live
	if ((get_script() as Script).is_tool()):
		angle_speed = deg_to_rad(360.0 / day_length)
	
	#sun.rotate_x(angle_speed * delta)
	sun.rotate_object_local(Vector3.RIGHT, angle_speed * delta)
	
	# if the sun is below the horizon, disable light for the night
	if  sun.rotation.x <= 0.0:
		sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
	else:
		sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY

## Get and return the current time of the day, between 0 and DAY_LENGTH.
func get_time() -> int:
	return int((fmod(sun.rotation.x, TAU) / TAU) * DAY_LENGTH)

## change the current time of the day to the given value
func set_time(time: int) -> void:
	pass

## Change the current weather
func set_weather(weather: Weather) -> void:
	pass

## Change the current fog
func set_fog(fog: Fog) -> void:
	pass

## Change the current wind
func set_wind(direction: Vector2i, strength: float) -> void:
	pass
