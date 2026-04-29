@tool
class_name TerrainMeshNoise extends MeshInstance3D

@export var player: CharacterBody3D
@export var noises: Array[NoiseComponent] = []
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
	apply_noise()
	create_shape()

# apply the noises on the terrain mesh
func apply_noise() -> void:	
	if noises.size() == 0:
		return
	
	var sTool: SurfaceTool = SurfaceTool.new()
	var dataTool: MeshDataTool = MeshDataTool.new()
	sTool.clear()
	sTool.create_from(mesh, 0)
	var array_mesh: ArrayMesh = sTool.commit()
	dataTool.clear()
	dataTool.create_from_surface(array_mesh, 0)
	var vertex_count: int = dataTool.get_vertex_count()
	
	for noise_component: NoiseComponent in noises: 
		var noise: FastNoiseLite = noise_component.texture.noise
		var strength: float = noise_component.strength
		noise.offset = Vector3(offset.x, 0, offset.y)
		for i: int in range(vertex_count):
			var vertex: Vector3 = dataTool.get_vertex(i)
			var value: float = noise.get_noise_3d(vertex.x, vertex.y, vertex.z)
			vertex.y = value * strength
			dataTool.set_vertex(i, vertex)
	
	array_mesh.clear_surfaces()
	dataTool.commit_to_surface(array_mesh)
	sTool.clear()
	sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	sTool.create_from(array_mesh, 0)
	sTool.generate_normals()
	mesh = sTool.commit()

# create a collision shape of the mesh
func create_shape() -> void:
	if collision and not Engine.is_editor_hint():
		collision.shape = mesh.create_trimesh_shape()

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
	
	# FIXME there are jumps when offseting the noise, it seems we nee to devide the position by some ratio
	var ratio: float = 1/step
	offset.x = player_pos.x / ratio
	offset.y = player_pos.z / ratio
	update()
	snap_timer.start()
	
	
