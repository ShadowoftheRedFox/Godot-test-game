## Display command on a text label.
class_name ConsoleApplication extends CommandApplication

## Number of chars max that can be displayed on the console.
const CONSOLE_MAX_LENGTH: int = 10000

func trace(message: String) -> void:
	output.emit(TextEffectWrapper.new(message).color(Color.GRAY).i().get_value())

func error(message: String) -> void:
	output.emit(TextEffectWrapper.new(message).color(Color.RED).get_value())
