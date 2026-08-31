class_name GameCommandApplication extends ConsoleApplication

func init_register() -> void:
	register(CommandTime.new())

	register(CommandGiveItem.new())
	register(CommandClearItem.new())
