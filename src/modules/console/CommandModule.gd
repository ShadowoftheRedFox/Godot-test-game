## Manage commands applicatios. It is also the main entry point of all command lines.
class_name CommandModule

## Holds registerd command application.
var _registered: Dictionary[String, CommandApplication] = {}

## Initialize default command application.
func _init() -> void:
	register(GameCommandApplication.new("main"))

## Register a new application. If an application of this name already exists, false is returned.
func register(application: CommandApplication) -> bool:
	if has_application(application.name):
		return false

	return _registered.set(application.name, application)

## Unregister an application command. Return true on success.
func unregister(application_name: String) -> bool:
	if !has_application(application_name):
		return false

	return _registered.erase(application_name)

## Return true if the command application name is registered.
func has_application(application_name: String) -> bool:
	return _registered.has(application_name)

## Return the command application if it is registered, null otherwise.
func get_application(application_name: String) -> CommandApplication:
	return _registered.get(application_name)

## Run a command line on the given application name.
func run(application_name: String, command_line: String) -> bool:
	print("Wanting to run application \"" + application_name + "\" with command: " + command_line)
	if !has_application(application_name):
		return false

	return get_application(application_name).run(command_line)
