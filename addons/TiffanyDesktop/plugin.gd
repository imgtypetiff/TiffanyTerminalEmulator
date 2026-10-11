@tool
extends EditorPlugin

var dock: EditorDock = EditorDock.new()

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
