@tool
extends EditorPlugin

var items_watcher: ItemFileWatcher = ItemFileWatcher.new()

func _enter_tree():
	print("File watcher started")

	var fs = EditorInterface.get_resource_filesystem()

	if not fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.connect(_on_filesystem_changed)

func _exit_tree():
	var fs = EditorInterface.get_resource_filesystem()

	if fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.disconnect(_on_filesystem_changed)

func _on_filesystem_changed():
	items_watcher._check()
