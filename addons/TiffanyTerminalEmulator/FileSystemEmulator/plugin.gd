@tool
extends EditorPlugin

var folder_path: String = get_script().resource_path.get_base_dir()
var fs: String = folder_path.path_join("FileRoot.tscn")

func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton("fs",fs)
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton("fs")
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
