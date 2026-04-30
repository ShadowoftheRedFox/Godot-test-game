class_name WorldChunk extends MeshInstance3D

var world_controller: WorldController = null
var lod: int = 1
# same as name, but not transformed as StringName, because it somehow creates problem
var id: String = ""

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	assert(world_controller != null, "No world controller")

func create_chunk(pos: Vector3, chunk_name: String) -> void:
	position = pos
	global_position = pos
	
	name = chunk_name
	id = chunk_name
	label_3d.text = chunk_name
	# TODO do it in another thread
	create_mesh()

func apply_noise() -> void:
	var sTool: SurfaceTool = SurfaceTool.new()
	var dataTool: MeshDataTool = MeshDataTool.new()
	sTool.clear()
	sTool.create_from(mesh, 0)
	var array_mesh: ArrayMesh = sTool.commit()
	dataTool.clear()
	dataTool.create_from_surface(array_mesh, 0)
	var vertex_count: int = dataTool.get_vertex_count()
	
	for noise_component: NoiseComponent in world_controller.noises:
		var noise: FastNoiseLite = noise_component.texture.noise
		var strength: float = noise_component.strength
		noise.offset = position
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

	set_surface_override_material(0, mat)
	if world_controller.noises.size() > 0:
		apply_noise()
	collision_shape_3d.shape = pmesh.create_trimesh_shape()
	mesh = pmesh

func _process(_delta: float) -> void:
	# check the distance, without accounting for height differences
	var player_position: Vector2 = Vector2(world_controller.player.global_position.x, world_controller.player.global_position.z)
	var chunk_position: Vector2 = Vector2(position.x, position.z)
	var dist: int = ceili(player_position.distance_squared_to(chunk_position))
	
	var rdist: float = world_controller.render_distance * world_controller.render_distance * world_controller.chunk_size * world_controller.chunk_size / 1.25
	
	if dist > rdist:
		#print("Render: " + str(rdist) + ", dist: " + str(dist)) 
		erase()
		return
	
	# redraw with LOD
	# - chunk_size to have a minimum distance before LOD
	# * chunk_size to have the LOD depending on the current chunk size
	var new_LOD: int = max(1, ceili(float(dist - world_controller.chunk_size) / float(rdist) * world_controller.chunk_size))
	if lod != new_LOD:
		#print("Supposed lod: " + str(new_LOD))
		lod = new_LOD
		create_mesh()

# called before getting deleted
func erase() -> void:
	world_controller.loaded_chunks.erase(self.id)
	queue_free()
