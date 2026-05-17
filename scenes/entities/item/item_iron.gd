class_name ItemIron extends Node3D

@onready var mesh3d: MeshInstance3D = $MeshInstance3D
const ITEM_IRON: InventoryItem = preload("uid://nfhxb5ipgdms")

func _ready() -> void:
	mesh3d.mesh = ITEM_IRON.item_mesh
