class_name WorldChunk extends MeshInstance3D

var world_controller: WorldController = null
var pos := Vector3.ZERO
var collision : CollisionShape3D = null
var lod := 1

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var label_3d: Label3D = $Label3D

func create_chunk() -> void:
	position = pos
	global_position = pos
	
	label_3d.text = name
	create_mesh()

# create the chunk mesh and collisions
func create_mesh() -> void:
	mesh = PlaneMesh.new()
	mesh.size = Vector2(world_controller.chunk_size, world_controller.chunk_size)
	var subdivide_size: int = world_controller.chunk_size / lod
	mesh.subdivide_depth = subdivide_size
	mesh.subdivide_width = subdivide_size
	
	collision_shape_3d.shape = mesh.create_trimesh_shape()

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf())

	set_surface_override_material(0, mat)

func _process(_delta) -> void:
	var player_position := Vector2(world_controller.player.global_position.x, world_controller.player.global_position.z)
	var chunk_position := Vector2(position.x, position.z)
	var dist := ceili(player_position.distance_squared_to(chunk_position))
	
	var rdist := world_controller.render_distance * world_controller.render_distance * world_controller.chunk_size * world_controller.chunk_size / 1.25
	
	if dist > rdist:
		print("Render: " + str(rdist) + ", dist: " + str(dist)) # FIXME doesn't load centered on player
		erase()
		return
	# TODO redraw LOD
	var new_LOD = ceili((dist+1.0)/(rdist+1.0)) # FIXME doesn"t get a correct LOD
	if lod != new_LOD:
		#print("Supposed lod: " + str(dist/4))
		lod = new_LOD
		create_mesh()

# called before getting deleted
func erase() -> void:
	print("erasing " + name)
	world_controller.loaded_chunks.erase(name)
	queue_free()
