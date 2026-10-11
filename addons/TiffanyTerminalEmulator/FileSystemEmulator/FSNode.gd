# FSNode.gd
extends Node
class_name FSNode

@export var fs_name: String = "": 
	set(x):
		fs_name = x
@export var real_path: String = ""

var parent_node: FSDirectoryNode = null
var is_root := false

func get_file_path() -> String:
	return real_path
