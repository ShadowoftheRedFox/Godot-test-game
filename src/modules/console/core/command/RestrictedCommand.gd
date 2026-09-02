## A command that runs only if the caller is whitelisted or not blacklisted.
## By default, the command is on blacklist mode, with no blacklisted callers.
@abstract class_name RestrictedCommand extends Command

var whitelisted: bool = false
var blacklisted: bool = true
var blacklist: Array[String] = []
var whitelist: Array[String] = []

## Enable the blacklist and disable the whitelist.
## Does not reset the lists.
## Return the current command.
func enable_blacklist() -> RestrictedCommand:
	whitelisted = false
	blacklisted = true
	return self

## Enable the whitelist and disable the blacklist.
## Does not reset the lists.
## Return the current command.
func enable_whitelist() -> RestrictedCommand:
	whitelisted = true
	blacklisted = false
	return self

## Enable the blacklist, and set the current blacklist to the given list.
## Return the current command.
func set_blacklist(list: Array[String]) -> RestrictedCommand:
	enable_blacklist()
	blacklist = list
	return self

## Add a target to the blacklist.
## Return the current command.
func add_blacklist(target: String) -> RestrictedCommand:
	if !blacklist.has(target):
		blacklist.append(target)
	return self

## Enable the whitelist, and set the current whitelist to the given list.
## Return the current command.
func set_whitelist(list: Array[String]) -> RestrictedCommand:
	enable_whitelist()
	whitelist = list
	return self

## Add a target to the whitelist.
## Return the current command.
func add_whitelist(target: String) -> RestrictedCommand:
	if !whitelist.has(target):
		whitelist.append(target)
	return self

func run(caller: CommandApplication, input: CommandInput) -> bool:
	if !is_enabled():
		return false

	# check whitelist/blacklist
	if (whitelisted && !whitelist.has(caller.name)) || (blacklisted && blacklist.has(caller.name)):
		return false

	initialize(caller, input)

	if !ignore_validation:
		var error: String = input.validate()
		if !error.is_empty():
			caller.error(error)
			return false

	return execute(caller, input)
