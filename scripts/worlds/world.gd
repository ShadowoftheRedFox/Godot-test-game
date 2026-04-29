class_name WorldController extends Node3D

const CHUNK = preload("uid://dtqtgvf43ympc")

@onready var player: Player = $Player
@onready var chunks: Node3D = $Chunks

@export_range(10.0, 1000.0) var chunk_size := 50
@export_range(3.0, 100.0, 2.0) var render_distance := 7
@export var noises: Array[NoiseComponent] = []

var loaded_chunks := PackedStringArray([])
var last_chunk: WorldChunk = null
var ray: RayCast3D

var thread := Thread.new()

func _ready() -> void:
	assert(render_distance>=1, "Invalid render distance")
	assert(chunk_size>=1, "Invalid chunk size")
	
	# make sure render distance is odd
	render_distance = render_distance + (1 - render_distance % 2)
	
	create_chunk_section()
	create_raycast()

func _process(_delta: float) -> void:
	# check chunk changed
	var collide := ray.get_collider()
	if collide == null:
		return

	var collided_chunk := (collide as StaticBody3D).get_parent() as WorldChunk
	if last_chunk != collided_chunk:
		last_chunk = collided_chunk
		#thread.start(create_chunk_section.bind(last_chunk.global_position))
		#thread.wait_to_finish()
		create_chunk_section(last_chunk.global_position)

func create_chunk_section(current_position: Vector3 = Vector3.ZERO):
	var half_render_distance := render_distance / 2.0
	for i in range(render_distance * render_distance):
		var half_point := Vector3(((i % render_distance) - half_render_distance) * chunk_size,
		0,
		((i / render_distance) - half_render_distance) * chunk_size)
		# center the player on the middle of the center chunk
		var offset := current_position + half_point + Vector3(chunk_size / 2.0, 0, chunk_size / 2.0)
		var chunk_name := "chunk_" + str(offset.x) + ":" + str(offset.z)
		
		# if chunk_name in loaded_chunks:
		if loaded_chunks.has(chunk_name):
			continue
		else:
			create_chunk(offset, chunk_name)

func create_chunk(pos: Vector3, chunk_name: String) -> void:
	var chunk: WorldChunk = CHUNK.instantiate()
	chunk.world_controller = self as WorldController
	
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


func _exit_tree() -> void:
	if thread == null:
		return
	thread.wait_to_finish()
