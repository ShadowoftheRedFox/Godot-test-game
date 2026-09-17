## Dictionary wrapper that holds a type of resource to be fetched during runtime.
@abstract class_name AbstractRegistry extends RefCounted

## Get the name of the registry. Must be unique.
@abstract func get_name() -> StringName

## Add an object in the registry.
## Return true on success, false otherwise.
@abstract func add_object(obj: Object) -> bool

## Remove an object from the registry by its ID.
## Return true on success, false otherwise.
## NOTE: if the object is not registered, returns true anyway.
@abstract func remove_object(id: Variant) -> bool

## Get the registred object matching the ID.
## Return the object if it is registred, null otherwise.
@abstract func get_object(id: Variant) -> Object

## Check if the given object ID is registered.
## Return true if it registered, false otherwise.
@abstract func has_object(id: Variant) -> bool

## Transform the ID.
## Useful if the ID if the object must be changed when stored or fetched.
func _transform_id(id: Variant) -> Variant:
    return id

## Returns the amount of objects registered inside.
@abstract func size() -> int
