extends TerminalApplication

func _init():
	app_name="cd"
	description="you know"
	
func run(terminal : Terminal, params: Array, tty_number: int, profile: String):
	if !params.size() == 1:
		add_error("ERROR: TOO MANY OR TOO LITTLE ARGUMENTS")
		return
	var current_dir: FSDirectoryNode = get_node(get_session().current_directory)
	if !current_dir.loaded:
		current_dir.refresh()
	var temp: Array = current_dir.get_children()
	var fsnodes: Dictionary[String, FSNode]
	for node in temp:
		if node is FSNode:
			fsnodes[node.fs_name] = node
	if fsnodes.keys().has(params[0]):
		get_session().current_directory = fsnodes[params[0]].get_path()
	else:
		var node = string_to_fsnode(params[0])
		if node is FSDirectoryNode:
			get_session().current_directory = node.get_path()
		elif node is FSFileNode:
			add_error("ERROR: PATH DOES NOT LEAD TO DIRECTORY")
		

## turns string paths (/usr/bin) into FSDirectoryNodes to cd into
## Returns null when no dir is found
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
