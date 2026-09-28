## Quick, easy and reliable way to wrap a string in a tag for a rich text label content.
class_name TextEffectWrapper

## Apply a tag around the given value, with the given arguments.
static func apply_tag(value: String, tag_name: String, arguments: Dictionary[String, String] = {}) -> String:
	if value == null || tag_name == null:
		return ""
	if arguments == null:
		arguments = {}

	var tag: String = tag_name
	# check if a key match the tag name, for special tags like "hint"
	if arguments.has(tag_name):
		tag += "=" + arguments.get(tag_name, "")
		# erase to be set later as arguments
		arguments.erase(tag_name)

	for key: String in arguments.keys():
		var kvalue: String = arguments.get(key, "")
		tag += " " + key + "=" + kvalue

	return "[" + tag + "]" + value + "[/" + tag_name + "]"

## Apply a standalone tag, like [br] or [char={codepoint}].
static func standalone_tag(tag_name: String, arguments: Dictionary[String, String] = {}) -> String:
	var tag: String = "[" + tag_name
	# check if a key match the tag name, for special tags like "hint"
	if arguments.has(tag_name):
		tag += "=" + arguments.get(tag_name, "")
		# erase to be set later as arguments
		arguments.erase(tag_name)

	for key: String in arguments.keys():
		var kvalue: String = arguments.get(key, "")
		tag += " " + key + "=" + kvalue

	return tag + "]"

## Return an HTML like color string "#ffffff" from the given color.
## If **include_alpha** is true, include two extra digits for the alpha range.
static func color_to_html(_color: Color, include_alpha: bool = false) -> String:
	return "#" + _color.to_html().erase(6, 0 if include_alpha else 2)

## Makes the text bold.
static func bold(text: String) -> String:
	return TextEffectWrapper.new(text).b().get_value()

## Makes the text bold.
static func italic(text: String) -> String:
	return TextEffectWrapper.new(text).i().get_value()

## Makes the text bold.
static func underline(text: String) -> String:
	return TextEffectWrapper.new(text).u().get_value()

## Makes the text bold and italic.
static func bi(text: String) -> String:
	return TextEffectWrapper.new(text).b().i().get_value()

## Makes the text bold and underlined.
static func bu(text: String) -> String:
	return TextEffectWrapper.new(text).b().u().get_value()

## Makes the text between brackets of the given color.
static func bracket_color(text: String, _color: Color) -> String:
	return TextEffectWrapper.new().color(_color).bracket(text).get_value()

## Apply b() to the array of values. Return the new edited array.
static func b_array(array: PackedStringArray) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.bold(e))
	return res

## Apply u() to the array of values. Return the new edited array.
static func u_array(array: PackedStringArray) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.underline(e))
	return res

## Apply i() to the array of values. Return the new edited array.
static func i_array(array: PackedStringArray) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.italic(e))
	return res

## Apply s() to the array of values. Return the new edited array.
static func s_array(array: PackedStringArray) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.new(e).s().get_value())
	return res

## Apply color() to the array of values. Return the new edited array.
static func color_array(array: PackedStringArray, _color: Color) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.new(e).color(_color).get_value())
	return res

## Apply bracket() to the array of values. Return the new edited array.
static func bracket_array(array: PackedStringArray) -> PackedStringArray:
	if array == null:
		return []
	var res: PackedStringArray = []
	for e: String in array:
		res.append(TextEffectWrapper.new().bracket(e).get_value())
	return res

## The current value of the effect.
var _value: String = ""

func _init(text: String = "") -> void:
	_value = text

## Get the formated value of this effect.
func get_value() -> String:
	return _value

## Bold.
func b() -> TextEffectWrapper:
	_value = apply_tag(_value, "b")
	return self

## Italic.
func i() -> TextEffectWrapper:
	_value = apply_tag(_value, "i")
	return self

## Underline.
func u() -> TextEffectWrapper:
	_value = apply_tag(_value, "u")
	return self

## Strikthrough.
func s(_color: Color = Color.WHITE) -> TextEffectWrapper:
	_value = apply_tag(_value, "s", {"color": color_to_html(_color)})
	return self

## Make a code block (unicode font).
func code() -> TextEffectWrapper:
	_value = apply_tag(_value, "code")
	return self

## Display char from codepoint.
func char(codepoint: int) -> TextEffectWrapper:
	_value += standalone_tag("char", {"char": str(codepoint)})
	return self

## Makes a paragraph with the following options:
func p(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	#TODO
	return self

## Line break.
func br() -> TextEffectWrapper:
	_value += standalone_tag("br")
	return self

## Horizontal rule with the following options:
func hr(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	#TODO
	return self

## Align the text to the center.
func center() -> TextEffectWrapper:
	_value = apply_tag(_value, "center")
	return self

## Align the text to the left.
func left() -> TextEffectWrapper:
	_value = apply_tag(_value, "left")
	return self

## Align the text to the right.
func right() -> TextEffectWrapper:
	_value = apply_tag(_value, "right")
	return self

## Align the text to fill the space (justify).
func fill() -> TextEffectWrapper:
	_value = apply_tag(_value, "fill")
	return self

## Indent the text the given aomunt of time. Min is 1. Default is 1.
func indent(amount: int = 1) -> TextEffectWrapper:
	if amount <= 1:
		amount = 1
	for i: int in range(amount):
		_value = apply_tag(_value, "indent")
	return self

## Makes an url with the following options:
func url(link: String, options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	#TODO
	return self

## Create a hint: on mouse hover, the hint will appear.
func hint(text: String) -> TextEffectWrapper:
	_value = apply_tag(_value, "hint", {"hint": text})
	return self

## Add an image with the following options:
func img(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	#TODO
	return self
## Change the font with the following options:
func font(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	#TODO
	return self

## Change the font to the new size. Min is 0. Default is 1.
func font_size(size: int = 1) -> TextEffectWrapper:
	if size < 0:
		size = 0
	_value = apply_tag(_value, "font_size", {"font_size": str(size)})
	return self

## A drop cap is the starting letter of a paragraph that can span multiple lines.
## Makes a drop cap, with the following options:
func dropcap(font: String, font_size: int, color: String, _outline_size: int, _outline_color: String, margins: Array[int] = []) -> TextEffectWrapper:
	#TODO
	return self

## Enables custom OpenType font features.
## Values must **not** be separated by spaces; otherwise, the list won't be parsed correctly.
func opentype_features(features: PackedStringArray = []) -> TextEffectWrapper:
	if features == null:
		features = []

	_value = apply_tag(_value, "opentype_features", {"opentype_features": ",".join(features)})
	return self

## Override the language for the text.
func lang(lang_code: String) -> TextEffectWrapper:
	_value = apply_tag(_value, "lang", {"lang": lang_code})
	return self

## Change the color of the font.
func color(_color: Color) -> TextEffectWrapper:
	_value = apply_tag(_value, "color", {"color": color_to_html(_color)})
	return self

## Change the color of the background.
func bgcolor(_color: Color) -> TextEffectWrapper:
	_value = apply_tag(_value, "bgcolor", {"bgcolor": color_to_html(_color)})
	return self

## Change the color of the foreground.
## Foreground is drawn on top of the text, in a "redacted" like style.
func fgcolor(_color: Color) -> TextEffectWrapper:
	_value = apply_tag(_value, "fgcolor", {"fgcolor": color_to_html(_color)})
	return self

## Change the outline size of the text.
func outline_size(size: String) -> TextEffectWrapper:
	_value = apply_tag(_value, "outline_size", {"outline_size": str(size)})
	return self

## Change the ouline color of the text.
func outline_color(_color: Color) -> TextEffectWrapper:
	_value = apply_tag(_value, "outline_color", {"outline_color": color_to_html(_color)})
	return self

## Creates a table with the following options:
func table(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	# TODO
	return self

## Creates a table's cell with the following options:
func cell(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	# TODO
	return self

## Create an unordered list with the following options:
func ul(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	# TODO
	return self

## Create an unordered list with the following options:
func ol(options: Dictionary[String, String] = {}) -> TextEffectWrapper:
	# TODO
	return self

## Display the text between brackets, in a way that won't be parsed by the rich text label.
func bracket(tag_name: String, arguments: Dictionary[String, String] = {}) -> TextEffectWrapper:
	var tag: String = tag_name
	# check if a key match the tag name, for special tags like "hint"
	if arguments.has(tag_name):
		tag += "=" + arguments.get(tag_name, "")
		# erase to be set later as arguments
		arguments.erase(tag_name)

	for key: String in arguments.keys():
		var kvalue: String = arguments.get(key, "")
		tag += " " + key + "=" + kvalue

	_value = "[lb]" + tag + "[rb]" + _value + "[lb]/" + tag_name + "[rb]"
	return self

func _to_string() -> String:
	return _value
