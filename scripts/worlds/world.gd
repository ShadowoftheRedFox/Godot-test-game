class_name WorldController extends Node3D

const CHUNK = preload("uid://dtqtgvf43ympc")

@onready var player: Player = $Player
@onready var chunks: Node3D = $Chunks

@export var chunk_size := 10

@export var render_distance := 1
var loaded_chunks: Array[WorldChunk] = []

func _ready() -> void:
	assert(render_distance>=1, "Invalid render distance")
	assert(chunk_size>=1, "Invalid chunk size")
	
	# create first chunks
	for x in range(render_distance*2+1):
		for y in range(render_distance*2+1):
			var chunk: WorldChunk = CHUNK.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			chunk.world_controller = self
			chunk.pos = Vector2i(x-render_distance, y-render_distance)
			loaded_chunks.append(chunk)
			chunks.add_child(chunk)
