class_name PhysicalItem extends Node3D

## Current item data.
@export var item: StringName = ""
## Reference to the instantiated item physical node.
var itemPhysical: RigidBody3D = null
## Reference to the mesh instance that will host the item mesh.
var mesh3d: MeshInstance3D = null

func _ready() -> void:
	assert(ItemRegistry.get_self().has_item_name(item), "unknwon item \"%s\"" % item)
	assert(ItemRegistry.get_self().get_item(item).item_physical.can_instantiate(), "item physical is not instantiable")

	# add the item physical into the tree
	itemPhysical = ItemRegistry.get_self().get_item(item).item_physical.instantiate()
	itemPhysical.name = "physicalItem-" + item
	add_child(itemPhysical)

	# listen to event
	itemPhysical.body_entered.connect(_on_body_entered)

	# setup mesh
	mesh3d = itemPhysical.find_child("MeshInstance3D")
	assert(mesh3d != null, "a reference to the mesh instance 3d is required to display the physical item")
	mesh3d.mesh = ItemRegistry.get_self().get_item(item).item_mesh

func _on_body_entered(_body: Node) -> void:
	for collider: Node3D in itemPhysical.get_colliding_bodies():
		if collider.name == Global.player.name:
			# add itself to the inventory
			var left: int = Global.player.inventory.add_item(item, 1)
			if left == 0:
				queue_free()
