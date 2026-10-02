## An interface used to generalize UI menus.
@abstract class_name UIMenu extends MarginContainer

## Called before the menu is removed, to play animation for exemple.[br]
## Must call the given menu to be loaded at the end.
func remove(next_menu_uid: String = "", layer: MainGame.MenuLayer = MainGame.MenuLayer.UI) -> void:
	if next_menu_uid.is_empty():
		return
	Global.MAIN.load_menu(next_menu_uid, layer)
	queue_free()
