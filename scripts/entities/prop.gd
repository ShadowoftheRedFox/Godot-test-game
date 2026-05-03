class_name Prop extends RigidBody3D

signal hit(damage: int)

@onready var health_component: HealthComponent = %HealthComponent
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@export var death_animation_component: DeathAnimationComponent

@export var shape: Shape3D
@export var mesh: Mesh
@export var material_override: Material

@export var max_healh: int = 100
@export var current_health: int = 100

func _ready() -> void:
	hit.connect(_on_hit)
	health_component.died.connect(_on_death)
	
	assert(mesh != null, "Prop mesh is null")
	assert(shape != null, "Prop shape is null")
	
	collision_shape_3d.shape = shape
	mesh_instance_3d.mesh = mesh
	if material_override != null:
		mesh_instance_3d.material_override = material_override
	
	health_component.max_health = max_healh
	health_component.current_health = current_health

# TODO better way to interract between two unknown bodies than throwing a signal in the space?
func _on_hit(damage: int) -> void:
	if damage <= 0:
		health_component.damage(-damage)
	else:
		health_component.heal(damage)

func _on_death() -> void:
	if death_animation_component == null:
		queue_free()
	
	death_animation_component._on_death()
