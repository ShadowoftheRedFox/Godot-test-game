class_name WorldController extends Node3D

const CHUNK: PackedScene = preload("uid://dtqtgvf43ympc")

@onready var player: Player = $Player
@onready var chunks: Node3D = $Chunks

@export_range(10, 1000, 10, "or_greater") var chunk_size: int = 50
@export_range(3, 100, 2, "or_greater") var render_distance: int = 7
@export var noises: Array[NoiseComponent] = []

var loaded_chunks: PackedStringArray = PackedStringArray([])
var last_chunk: WorldChunk = null
var ray: RayCast3D

func _ready() -> void:
	assert(render_distance >= 1, "Invalid render distance")
	assert(chunk_size >= 1, "Invalid chunk size")
	
	# make sure render distance is odd
	render_distance = render_distance + (1 - render_distance % 2)
	
	loaded_chunks.resize(render_distance * render_distance)
	
	create_chunk_section()
	create_raycast()

func _process(_delta: float) -> void:
	# check chunk changed
	var collide: Object = ray.get_collider()
	if collide == null:
		return

	var collided_chunk: WorldChunk = (collide as StaticBody3D).get_parent()
	if last_chunk != collided_chunk:
		last_chunk = collided_chunk
		#thread.start(create_chunk_section.bind(last_chunk.global_position))
		#thread.wait_to_finish()
		create_chunk_section(last_chunk.global_position)

func create_chunk_section(current_position: Vector3 = Vector3.ZERO) -> void:
	var half_render_distance: float = render_distance / 2.0
	for i: int in range(render_distance * render_distance):
		@warning_ignore("integer_division")
		var half_point: Vector3 = Vector3(((i % render_distance) - half_render_distance) * chunk_size,
		0,
		((i / render_distance) - half_render_distance) * chunk_size)
		# center the player on the middle of the center chunk
		var offset: Vector3 = current_position + half_point + Vector3(chunk_size / 2.0, 0, chunk_size / 2.0).round()
		var chunk_name: String = "chunk_" + str(offset.x) + ":" + str(offset.z)
		
		# if chunk_name in loaded_chunks:
		if loaded_chunks.has(chunk_name):
			continue
		else:
			create_chunk(offset, chunk_name)

func create_chunk(pos: Vector3, chunk_name: String) -> void:
	var chunk: WorldChunk = CHUNK.instantiate()
	chunk.world_controller = self
	
	loaded_chunks.append(chunk_name)
	#chunks.add_child(chunk)
	chunks.call_deferred("add_child", chunk)
	#chunk.create_chunk(pos, chunk_name)
	chunk.call_deferred("create_chunk", pos, chunk_name)

func create_raycast() -> void:
	ray = RayCast3D.new()
	
	ray.target_position.y = -1000
	ray.collision_mask = 2 # ChunkRayCastMask
	
	ray.name = "PlayerChunkRaycast"
	
	ray.debug_shape_custom_color = Color.RED
	ray.debug_shape_thickness = 5
	
	player.add_child(ray)
