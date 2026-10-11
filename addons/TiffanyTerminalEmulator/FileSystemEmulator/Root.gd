extends Node
class_name VirtualFS

@export var root_path := "user://FILESYSTEM"

var root: FSDirectoryNode

func _ready():
	DirAccess.make_dir_recursive_absolute("user://FILESYSTEM/usr/bin")
	root = FSDirectoryNode.new()
	root.fs_name = "/"
	root.real_path = root_path
	root.is_root = true
	add_child(root)
	root.refresh()
