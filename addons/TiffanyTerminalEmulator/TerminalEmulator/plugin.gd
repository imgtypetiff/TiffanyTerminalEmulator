@tool
extends EditorPlugin

func _enter_tree():
	var folder_path: String = get_script().resource_path.get_base_dir()
	add_autoload_singleton("Terminal", folder_path.path_join("assets/autoloads/terminal.gd"))
	add_autoload_singleton("Loading", folder_path.path_join("assets/loading/loading.tscn"))
	add_autoload_singleton("Screenshot", folder_path.path_join("assets/autoloads/screenshot_manager.gd"))
	var fs := EditorInterface.get_resource_filesystem()
	fs.connect("filesystem_changed", Callable(self, "_on_filesystem_changed"))

func _exit_tree():
	remove_autoload_singleton("Terminal")
	remove_autoload_singleton("Loading")
	remove_autoload_singleton("Screenshot")
	var fs := EditorInterface.get_resource_filesystem()
	if fs.is_connected("filesystem_changed", Callable(self, "_on_filesystem_changed")):
		fs.disconnect("filesystem_changed", Callable(self, "_on_filesystem_changed"))

func _on_filesystem_changed():
	var folder_path: String = get_script().resource_path.get_base_dir()
	var generator_script = load(folder_path.path_join("assets/editor_tools/reg_gen.gd"))
	if generator_script:
		generator_script.new()._run()
