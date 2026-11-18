extends TerminalApplication

func _init():
	app_name="Echo"
	description="Write arguments to the standard output"

func run(terminal : Terminal, params: Array, tty_number: int, profile: String):
	if params.size() == 3:
		if params[1] == ">>":
			var node = string_to_fsnode(str(params[2]).get_base_dir())
			if !node is FSDirectoryNode:
				add_error("ERROR: INVALID PATH")
				return
			else:
				node.refresh()
			var filename = str(params[2]).get_file()
			var children = node.get_children()
			var found_node: FSNode = null
			for child in children:
				if child is FSFileNode:
					if child.fs_name == filename:
						found_node = child
			if found_node != null:
				if found_node.real_path.begins_with("res://"):
					add_error("ERROR: INVALID FILE")
					return
				var f = FileAccess.open(node.real_path.path_join(str(params[2]).get_file()), FileAccess.WRITE)
				f.store_string(params[0])

			else:
				var f = FileAccess.open(node.real_path.path_join(str(params[2]).get_file()), FileAccess.WRITE)
				f.store_string(params[0])
			node.refresh()
			return
	add_to_log(" ".join(params))

func string_to_fsnode(string_path: String) -> FSNode:
	var current_dir: FSDirectoryNode
	# Check for / and . and shit
	if string_path.begins_with("/"):
		current_dir = fs.root
		string_path = string_path.substr(1)
	else:
		current_dir = get_node(get_session().current_directory)
		# Kinda janky, but "if it ain't broke don't fix it"
		if string_path.begins_with("./"):
			string_path = string_path.substr(2)
		if string_path == ".":
			return current_dir

	var string_array: Array = string_path.split("/", false)

	# If size() == 0, that means that the full path was handled already
	if string_array.size() == 0:
		return current_dir

	for i in range(string_array.size()):
		var n: String = string_array[i]

		if n == ".":
			continue

		if n == "..":
			if current_dir.parent_node != null:
				current_dir = current_dir.parent_node
			continue

		current_dir.ensure_loaded()

		var found_node: FSNode = null

		for child in current_dir.get_children():
			if child is FSNode and child.fs_name == n:
				found_node = child
				break

		if found_node == null:
			add_error("ERROR: INVALID PATH")
			return null

		# Intermediate path components must be directories.
		if i < string_array.size() - 1:
			if not found_node is FSDirectoryNode:
				add_error("ERROR: NOT A DIRECTORY")
				return null

			current_dir = found_node

		else:
			return found_node

	return current_dir
