extends FSNode
class_name FSDirectoryNode

var children_cache: Array[FSNode] = []
var loaded := false

func refresh() -> void:
	# clear old cache nodes
	for c in get_children():
		if c is FSNode:
			if !c.real_path.begins_with("res://"):
				c.queue_free()

	children_cache.clear()

	var dir := DirAccess.open(real_path)
	if dir == null:
		return

	dir.list_dir_begin()

	while true:
		var name := dir.get_next()
		if name == "":
			break

		if name == "." or name == "..":
			continue

		var full := real_path.path_join(name)

		if dir.current_is_dir():
			var node := FSDirectoryNode.new()
			node.fs_name = name
			node.real_path = full
			node.parent_node = self
			add_child(node)
			children_cache.append(node)
		else:
			var node := FSFileNode.new()
			node.fs_name = name
			node.real_path = full
			node.parent_node = self
			add_child(node)
			children_cache.append(node)

	dir.list_dir_end()
	loaded = true

func ensure_loaded():
	if !loaded:
		refresh()
