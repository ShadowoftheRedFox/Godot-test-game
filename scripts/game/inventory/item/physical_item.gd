class_name PhysicalItem extends Node3D

## Current item data.
@export var item: InventoryItem = null
## Reference to teh instantiated item physical node.
var itemPhysical: RigidBody3D = null
## Reference to the mesh instance that will host teh item mesh.
var mesh3d: MeshInstance3D = null

func _ready() -> void:
	assert(item != null, "an item is required to display it")
	assert(item.item_physical.can_instantiate(), "item physical is not instantiable")

	# add the item physical into the tree
	itemPhysical = item.item_physical.instantiate()
	itemPhysical.name = "physicalItem-" + item.item_name
	add_child(itemPhysical)

	# listen to event
	itemPhysical.body_entered.connect(_on_body_entered)

	# setup mesh
	mesh3d = itemPhysical.find_child("MeshInstance3D")
	assert(mesh3d != null, "a reference to the mesh instance 3d is required to display the physical item")
	mesh3d.mesh = item.item_mesh

func _on_body_entered(_body: Node) -> void:
	for collider: Node3D in itemPhysical.get_colliding_bodies():
		if collider.name == GameState.player.name:
			# add itself to the inventory
			var left: int = GameState.player.inventory.add_item(item, 1)
			if left == 0:
				queue_free()
