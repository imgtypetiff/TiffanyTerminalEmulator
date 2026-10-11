extends TerminalApplication

func _init() -> void:
	app_name = "ls"
	description = "you know"

func run(terminal: Terminal, parsed: Array, tty_number: int, profile: String) -> void:
	var current_dir: FSDirectoryNode = get_node(get_session().current_directory)
	if !current_dir.loaded:
		current_dir.refresh()
	var fsnodes: Array = current_dir.get_children()
	for n in fsnodes:
		add_to_log(n.fs_name)
	pass
