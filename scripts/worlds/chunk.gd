class_name WorldChunk extends MeshInstance3D

var ntg: NoiseTerrainGenerator = NoiseTerrainGenerator.new()

var world_controller: WorldController = null
# maximum distance from world chunk (squared)
var max_dist: float = 0.0


var lod: int = 1
# same as name, but not transformed as StringName, because it somehow creates problem
var id: String = ""

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	max_dist = world_controller.render_distance * world_controller.render_distance * world_controller.chunk_size * world_controller.chunk_size / 2.0
	assert(world_controller != null, "No world controller")

func create_chunk(pos: Vector3, chunk_name: String) -> void:
	position = pos
	global_position = pos
	
	name = chunk_name
	id = chunk_name
	label_3d.text = chunk_name
	# TODO do it in another thread
	create_mesh()

# create the chunk mesh and collisions
func create_mesh() -> void:
	var pmesh: PlaneMesh = PlaneMesh.new()
	pmesh.size = Vector2(world_controller.chunk_size, world_controller.chunk_size)

	@warning_ignore("integer_division")
	var subdivide_size: int = world_controller.chunk_size / lod
	pmesh.subdivide_depth = subdivide_size
	pmesh.subdivide_width = subdivide_size
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf())

	material_override = mat
	mesh = ntg.apply_noise(world_controller.noises, pmesh, position)
	collision_shape_3d.shape = mesh.create_trimesh_shape()

func _process(_delta: float) -> void:
	# check the distance, without accounting for height differences
	var player_position: Vector2 = Vector2(world_controller.player.global_position.x, world_controller.player.global_position.z)
	var chunk_position: Vector2 = Vector2(position.x, position.z)
	# distance to erase chunk, doesn't take y
	var dist: int = ceili(player_position.distance_squared_to(chunk_position))
	# distance from the chunk, with y
	var true_dist: int = ceili(world_controller.player.global_position.distance_squared_to(position))

	if dist > max_dist:
		erase()
		return
	
	# redraw with LOD
	var new_LOD: int = calc_new_lod(true_dist)
	if lod != new_LOD:
		lod = new_LOD
		create_mesh()

func calc_new_lod(distance_to_player_squared: float) -> int:
	var max_LOD: int = world_controller.chunk_size - 1
	var chunk_square: int = world_controller.chunk_size * world_controller.chunk_size
	var minimum_chunks_before_lod: float = world_controller.distance_before_LOD
	if distance_to_player_squared <= minimum_chunks_before_lod ** 2:
		return 1
	return min(max_LOD, lerp(1, max_LOD, float(distance_to_player_squared / max_dist)))

# called before getting deleted
func erase() -> void:
	world_controller.loaded_chunks.erase(self.id)
	queue_free()
