class_name WorldChunk extends MeshInstance3D

var world_controller: WorldController = null
var pos := Vector2i.ZERO
var collision : CollisionShape3D = null

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	create_mesh()
	
func create_mesh() -> void:
	mesh = PlaneMesh.new()
	mesh.size = Vector2(world_controller.chunk_size, world_controller.chunk_size)
	collision_shape_3d.shape = mesh.create_trimesh_shape()
	position = Vector3(pos.x * world_controller.chunk_size, 0, pos.y * world_controller.chunk_size)
	
	label_3d.text = str(pos)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf())

	set_surface_override_material(0, mat)
