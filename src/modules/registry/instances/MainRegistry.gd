## The main registry. Holds other registry
class_name MainRegistry extends Registry

## Internal dictionary holding the registered registries.
var _registries: Dictionary[StringName, Registry] = {}

func _init() -> void:
    # TODO load main registries
    pass

func get_name() -> StringName:
    return "MainRegistry"


func add_object(obj: Object) -> bool:
    if obj == null || obj is not Registry:
        return false
    return add_registry(obj as Registry)

func remove_object(id: Variant) -> bool:
    @warning_ignore("unsafe_call_argument")
    return remove_registry_name(type_convert(id, TYPE_STRING_NAME))

func get_object(id: Variant) -> Object:
    @warning_ignore("unsafe_call_argument")
    return get_registry(type_convert(id, TYPE_STRING_NAME))

func has_object(id: Variant) -> bool:
    @warning_ignore("unsafe_call_argument")
    return has_registry_name(type_convert(id, TYPE_STRING_NAME))

func size() -> int:
    return _registries.size()

## Add a registry in the registered registry list.
## Return true on success, false otherwise.
func add_registry(registry: Registry) -> bool:
    if registry == null || has_registry(registry):
        return false
    return _registries.set(registry.get_name(), registry)

## Remove a registry from the registry list.
## Return true on success, false otherwise.
func remove_registry(registry: Registry) -> bool:
    if registry == null:
        return true
    return remove_registry_name(registry.get_name())

## Remove a registry from the registry list by its name.
## Return true on success, false otherwise.
func remove_registry_name(name: StringName) -> bool:
    if name == null || !has_registry_name(name):
        return true
    return _registries.erase(name)

## Get the registred registry matching the name.
## Return the registry if it is registred, null otherwise.
func get_registry(name: StringName) -> Registry:
    return _registries.get(name)

## Check if the registry is registered.
## Return true if it registered, false otherwise.
func has_registry(registry: Registry) -> bool:
    return has_registry_name(registry.get_name())

## Check if the registry name is registered.
## Return true if it registered, false otherwise.
func has_registry_name(name: StringName) -> bool:
    return _registries.has(name)
