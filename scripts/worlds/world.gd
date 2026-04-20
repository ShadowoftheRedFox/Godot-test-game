class_name WorldController extends Node3D

const CHUNK = preload("uid://dtqtgvf43ympc")

@onready var player: Player = $Player
@onready var chunks: Node3D = $Chunks

@export var chunk_size := 10

@export var render_distance := 2
var loaded_chunks: Array[WorldChunk] = []

var current_pos := Vector2i.ZERO
var old_pos := Vector2i.ZERO

func _ready() -> void:
	assert(render_distance>=1, "Invalid render distance")
	assert(chunk_size>=1, "Invalid chunk size")
	
	# create first chunks
	for x in range(render_distance*2+1):
		for y in range(render_distance*2+1):
			create_chunk(Vector2i(x-render_distance, y-render_distance))

func _process(_delta: float) -> void:
	# check where the player is to generate more chunk (centered)
	current_pos = Vector2i((int)(player.position.x / (chunk_size)), (int)(player.position.z / (chunk_size)))
	
	# update chunks render
	if current_pos != old_pos:
		old_pos = current_pos
		print("new pos: " + str(current_pos))
		update_chunk()

func create_chunk(pos: Vector2i) -> void:
	var chunk: WorldChunk = CHUNK.instantiate()
	chunk.world_controller = self
	chunk.pos = pos
	loaded_chunks.append(chunk)
	chunks.add_child(chunk)

func update_chunk() -> void:
	var to_remove: Array[WorldChunk] = []
	for i in range(loaded_chunks.size()):
		var c: WorldChunk = loaded_chunks[i]
		print("distance to " + str(c.pos) + ": " + str(c.pos.distance_squared_to(current_pos)))
		if c.pos.distance_squared_to(current_pos) >= (render_distance+1)*(render_distance+1):
			c.erase()
			c.queue_free()
			to_remove.append(c)
	
	for c in to_remove:
		loaded_chunks.remove_at(loaded_chunks.find(c))
	
	#TODO create new chunks
