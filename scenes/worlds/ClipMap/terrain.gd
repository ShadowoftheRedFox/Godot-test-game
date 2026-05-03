@tool
class_name Terrain extends MeshInstance3D

@export var player: CharacterBody3D
@export var noises: TerrainNoise
@export var offset: Vector2 = Vector2.ZERO
@export var collision: CollisionShape3D
@export_tool_button("Update", "Reload")
var update_button: Callable = update

var snap_timer: Timer = Timer.new()

func _ready() -> void:
	# setup a timer that will call itself every second
	add_child(snap_timer)
	snap_timer.connect("timeout", snap)
	snap_timer.wait_time = 1
	snap()
	
	update()

# update both mesh and shape
func update() -> void:
	#apply_noise()
	create_shape()

# apply the noises on the terrain mesh
func apply_noise() -> void:
	mesh = NoiseTerrainGenerator.new().apply_noise(noises, mesh, Vector3(offset.x, 0, offset.y))

# create a collision shape of the mesh
func create_shape() -> void:
	var size: int = 200
	var heights: PackedFloat32Array = PackedFloat32Array()
	heights.resize(size*size)

	for x: int in range(size):
		for y: int in range(size):
			var noise: FastNoiseLite = noises.textures[0].noise
			noise.frequency = noises.lacunarity
			noise.offset = Vector3(offset.x + x, 0, offset.y + y)
			var h: float = noise.get_noise_2d(x, y)
			h = (h + 1.0) * 0.5  # normalize to 0–1
			heights[x * size + y] = h * noises.persistance
	
	var map_shape: HeightMapShape3D = HeightMapShape3D.new()
	map_shape.map_width = size
	map_shape.map_depth = size
	map_shape.map_data = heights
	
	if collision and not Engine.is_editor_hint():
		collision.shape = map_shape
		#collision.shape = mesh.create_trimesh_shape()

######### TEMP #########
var ratio: float = 1
# FIXME there are jumps when offseting the noise, it seems we nee to devide the position by some ratio
######### TEMP #########

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("action_special_up"):
		if ratio < 1:
			ratio += 0.1
		else:
			ratio += 1
		print("Ratio: " + str(ratio))
	if Input.is_action_just_pressed("action_special_down"):
		if ratio <= 1:
			ratio = max(0, ratio - 0.1)
		else: 
			ratio -= 1
		print("Ratio: " + str(ratio))

# snap the terrain to the player position
func snap() -> void:
	if player == null:
		return
	
	# the difference in position for the snapped function to return something not zero
	var step: int = 20
	# get the difference in pos and update if enough
	var player_pos: Vector3 = player.global_transform.origin.snapped(Vector3(step, 0, step))
	# not far enough to update
	if global_transform.origin.x == player_pos.x and global_transform.origin.z == player_pos.z:
		snap_timer.start()
		return
	# update
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
	
	offset.x = player_pos.x / ratio
	offset.y = player_pos.z / ratio
	update()
	snap_timer.start()
	
	
