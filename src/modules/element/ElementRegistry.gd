## Holds the game elements definition.
@abstract class_name ElementRegistry extends AbstractRegistry

#TODO mod compatible with prefixes, and can ignore prefix if name is unique

## Get dictionary holding the element.[br]
## We get this way, so the engine can type check on extended element definitions.
@abstract func _get_dictionary() -> Dictionary[StringName, ElementDefinition]

func _freeze() -> void:
	_get_dictionary().make_read_only()

func add_object(obj: Object) -> bool:
	if obj == null || obj is not ElementDefinition:
		return false
	return add_element(obj as ElementDefinition)

@warning_ignore_start("unsafe_call_argument")
func get_object(id: Variant) -> Object:
	return get_element(type_convert(id, TYPE_STRING_NAME))

func has_object(id: Variant) -> bool:
	return has_element_name(type_convert(id, TYPE_STRING_NAME))

func remove_object(id: Variant) -> bool:
	return remove_element_name(type_convert(id, TYPE_STRING_NAME))
@warning_ignore_restore("unsafe_call_argument")

func size() -> int:
	return _get_dictionary().size()

## Add a element in the registered element list.
## Return true on success, false otherwise.
func add_element(element: ElementDefinition) -> bool:
	return _get_dictionary().set(element.get_id(), element)

## Remove an element from the element list.
## Return true on success, false otherwise.
func remove_element(element: ElementDefinition) -> bool:
	if element == null || !has_element(element):
		return true
	return remove_element_name(element.get_id())

## Remove an element from the element list by its name.
## Return true on success, false otherwise.
func remove_element_name(name: StringName) -> bool:
	if name == null || !has_element_name(name):
		return true
	return _get_dictionary().erase(name)

## Get the registred element matching the name.
## Return the element if it is registred, null otherwise.
func get_element(name: StringName) -> ElementDefinition:
	return _get_dictionary().get(name)

## Check if the element is registered.
## Return true if it registered, false otherwise.
func has_element(element: ElementDefinition) -> bool:
	return has_element_name(element.get_id())

## Check if the element name is registered.
## Return true if it registered, false otherwise.
func has_element_name(name: StringName) -> bool:
	return _get_dictionary().has(name)

## Get the list of registered element names.
func get_element_name_list() -> Array[StringName]:
	return _get_dictionary().keys()
