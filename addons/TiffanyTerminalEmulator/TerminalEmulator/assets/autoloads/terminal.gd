extends Node

signal command_run(tty_number: int, command: String)
signal tty
signal clear_log
signal print_log(tty_number: int, statement : String, use_color: bool, color: Color)
signal force_log(tty_number:int, statements : Array)

var current_directory: String 
var variables := {
	"camid": Callable(self, "get_cam_id"),
	"PATH": [get_script().resource_path.get_base_dir().get_base_dir().path_join("assets/applications"), "user://usr/bin"],
}

var folder_path: String = self.get_script().resource_path.get_base_dir().get_base_dir().get_base_dir()
var AppRegistry: Dictionary =  preload("res://addons/TiffanyTerminalEmulator/TerminalEmulator/registries/app_registry.gd").new().APPLICATIONS

var ttys: Dictionary[int, TTYSession] = {}: 
	set(v):
		for t in range(ttys.size()):
			if v[t] != ttys[t]:
				print(v[t], ", ", ttys[t])
		ttys = v

class Account:
	var account_name: String = ""
	var password: String = ""
	var privilege_level: privileges = privileges.RESTRICTED

func setup_account(account_name: String, password: String, privilege_level: privileges) -> Account:
	var acc: Account = Account.new()
	acc.account_name = account_name
	acc.password = password
	acc.privilege_level = privilege_level
	return acc

var accounts: Dictionary[String, Account] = {
	"guest": setup_account("guest", "", privileges.RESTRICTED),
	"root": setup_account("root", "", privileges.SYSTEM),
	"tiffany": setup_account("tiffany", "tiff", privileges.ADMINISTRATOR),
}

var profiles: Dictionary = {
	# Arrays because I HATE recursive dictionaries.
	"guest": ["", privileges.RESTRICTED],
	"root": ["", privileges.SYSTEM],
	"tiffany":["tiff",privileges.ADMINISTRATOR]
}

enum privileges{
	SYSTEM,
	ADMINISTRATOR,
	NORMAL,
	RESTRICTED
}

func _ready() -> void:
	# set up folders
	DirAccess.make_dir_recursive_absolute("user://FILESYSTEM/usr/bin")
	var usr: FSDirectoryNode = string_to_fsnode("/usr/bin/", null)
	# set up fake files
	for key in AppRegistry.keys():
		var uid = AppRegistry[key]
		var path = ResourceUID.uid_to_path(uid)
		var file: FSFileNode = FSFileNode.new()
		file.fs_name = key
		file.real_path = path
		usr.add_child(file)
	
	print("FILESYSTEM folder: ", ProjectSettings.globalize_path("user://FILESYSTEM"))
	var system_password =  profiles["root"][0]
	use_tty(0, self, "root", system_password)


func path_search(app: String):
	for p in variables["PATH"]:
		var apps: Dictionary = {}
		var dir = DirAccess.open(p)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					if !file_name.begins_with("."):
						pass
				else:
					if !file_name.begins_with("."):
						if file_name.get_extension() == "gd":
							if !file_name.contains(" "):
								if app == file_name.get_basename():
									return p.path_join(file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")


func get_cam_id():
	var cam3d := get_viewport().get_camera_3d()
	var cam2d := get_viewport().get_camera_2d()
	if cam2d is Camera2D && cam3d is Camera3D:
		return [str(cam3d.get_instance_id()), str(cam2d.get_instance_id())]
	elif cam2d is Camera2D:
		return [str(null), str(cam2d.get_instance_id())]
	elif cam3d is Camera3D:
		return [str(cam3d.get_instance_id()), str(null)]

func run_command(profile: String, tty_number: int, command : String):
	if !ttys.keys().has(tty_number):
		return
	if !ttys[tty_number].active:
		return
	if command.is_empty():
		command_run.emit(tty_number, "")
	var split_command := parse_command(command)

	for i in range(split_command.size()):
		var s = split_command[i]
		if s.begins_with("$"):
			var v := variables.get(s.substr(1), s)
			if v is Callable:
				s = str(v.call())
			else:
				s = str(v)
		split_command[i] = s

	if split_command.is_empty():
		return

	command_run.emit(tty_number, command)
	var error = await run_application(profile, tty_number, split_command[0], split_command.slice(1))
	return error

func parse_command(input: String) -> Array:
	var args: Array = []
	var current := ""

	var in_quotes := false
	var quote_char := ""
	var escape := false

	for i in input.length():
		var c := input[i]
		if escape:
			current += c
			escape = false
			continue
		if c == "\\":
			escape = true
			continue
		if in_quotes:
			if c == quote_char:
				in_quotes = false
			else:
				current += c
			continue
		if c == '"' or c == "'":
			in_quotes = true
			quote_char = c
			continue
		if c == " ":
			if current != "":
				args.append(current)
				current = ""
			continue
		current += c
	if current != "":
		args.append(current)
	for i in range(args.size()):
		var s = args[i]
		if s.begins_with("$"):
			var v := variables.get(s.substr(1), s)
			if v is Callable:
				s = str(v.call())
			else:
				s = str(v)
		args[i] = s
	return args

func run_application(profile, tty_number, application_id:String, params:Array):
	if application_id.contains("/"):
		var a = string_to_fsnode(application_id, ttys[tty_number])
		if a.real_path.begins_with("res://"):
			var command = load(ResourceUID.path_to_uid(a.real_path)).new()

			if command is TerminalApplication:

				command._profile = profile
				command._terminal = self
				command._tty_number = tty_number

				get_tree().current_scene.add_child(command)

				await command.run(
					self,
					params,
					tty_number,
					profile
				)

				return 0

	
	if AppRegistry.has(application_id):

		var command = load(AppRegistry[application_id]).new()

		if command is TerminalApplication:

			command._profile = profile
			command._terminal = self
			command._tty_number = tty_number

			get_tree().current_scene.add_child(command)

			await command.run(
				self,
				params,
				tty_number,
				profile
			)

			return 0
	
	var s = path_search(application_id)

	if s is String and FileAccess.file_exists(s):
		print(s)
		return 0

	else:
		# cutie patootie detector
		var cute := false
		var cutie_patootie := ["uwu", ":3", "owo", "0wo", "ow0"]

		for phrase in cutie_patootie:
			if application_id.to_lower() == phrase.to_lower():
				cute = true

		if cute:
			add_to_log(
				tty_number,
				"Application not found, you cutie patootie.",
				true,
				Color.RED
			)
			return 127
		else:
			add_to_log(
				tty_number,
				"Application not found",
				true,
				Color.RED
			)
			return 127

func add_to_log(tty_number: int, statement : String, use_color: bool = false, color: Color = Color()):
	ttys[tty_number].tty_log.append(statement)
	if !use_color:
		emit_signal("print_log", tty_number, statement, false, color)
	else:
		emit_signal("print_log", tty_number, statement, true, color)

func add_error(tty_number: int, statement : String):
	ttys[tty_number].tty_log.append(statement)
	emit_signal("print_log", tty_number, statement)

func clear(tty_number):
	ttys[tty_number].tty_log = []
	emit_signal("force_log", tty_number, [])

# Professional tiffany© jank function with the worst debuggability in the world.
func use_tty(tty_number:int, terminal_interface:Node, profile:String = "guest", password:String = "") -> Dictionary:

	if ttys.has(tty_number):

		var existing:TTYSession = ttys[tty_number]

		if existing.node == terminal_interface:
			if existing.logged_in:
				return {"tty": tty_number, "profile": existing.profile, "file": existing.current_directory}

		if !existing.node == terminal_interface:
			printerr("TTY ", tty_number, " already in use.")

			tty_number = get_next_free_tty()

	if !profiles.has(profile):
		return {"tty": tty_number, "profile": null, "file": fs.root.get_path()}
		
	if !authenticate(profile, password):
		var guest_session = _create_session(tty_number, terminal_interface, "guest", false)
		guest_session.active = false
		return {"tty": tty_number, "profile": null, "file": guest_session.current_directory}
		
	var session = _create_session(tty_number, terminal_interface, profile)
	
	if "tty_session" in terminal_interface:
		terminal_interface.tty_session = session
	print("TTY ", tty_number, " LOGGED IN AS ", profile)
	return {"tty": tty_number, "profile": profile, "file": session.current_directory}

func _create_session(tty_number:int, terminal_interface:Node, profile:String, logged_in: bool = true) -> TTYSession:

	var session := TTYSession.new()

	session.initialize(
		terminal_interface,
		profile,
		fs.root.get_path(),
		logged_in
	)
	print(get_fs_path(fs.root.get_children()[0]))
	session.environment.set_var(
		"camid",
		Callable(self, "get_cam_id")
	)

	session.environment.set_var(
		"PATH",
		[get_script().resource_path.get_base_dir().get_base_dir().path_join("assets/applications"),
			"user://usr/bin"]
	)

	ttys[tty_number] = session

	return session

func get_fs_path(filenode: FSNode):
	var path_array: Array = [filenode.fs_name]
	var i: int = 0
	while i == 0:
		if filenode.parent_node != null:
			path_array.append(filenode.parent_node.fs_name)
			filenode = filenode.parent_node
		else:
			i = 1
	path_array.reverse()
	if path_array == [fs.root.fs_name]:
		return fs.root.fs_name
	return "/".join(path_array).substr(1)

func authenticate(profile:String, password:String) -> bool:
	if !profiles.has(profile):
		return false
	var required_password = profiles[profile][0]
	if required_password.is_empty():
		return true
	return required_password == password

func get_next_free_tty() -> int:
	var id := 0
	while ttys.has(id):
		id += 1
	return id

func log_in(profile: String, password: String, tty_number: int, terminal_interface: Node):
	if !profiles.keys().has(profile):
		return null
	if profiles[profile][0] == password:
		return profile
	else:
		return null

func abandon_tty(tty_number: int, terminal_interface: Node):
	ttys.erase(tty_number)

func set_variable(variable, value):
	variables[variable] = value
	pass


func string_to_fsnode(string_path: String, session: TTYSession) -> FSNode:
	var current_dir: FSDirectoryNode
	# Check for / and . and shit
	if string_path.begins_with("/"):
		current_dir = fs.root
		string_path = string_path.substr(1)
	else:
		current_dir = get_node(session.current_directory)
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
			print("Did not find node")
			return null

		# Intermediate path components must be directories.
		if i < string_array.size() - 1:
			if not found_node is FSDirectoryNode:
				print("Files are in path")
				return null

			current_dir = found_node

		else:
			return found_node

	return current_dir
