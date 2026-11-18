extends TerminalApplication

func _init() -> void:
	app_name = "check"
	description = "checks your privilege"

func run(terminal: Terminal, parsed: Array, tty_number: int, profile: String) -> void:
	if terminal.accounts[profile].privilege_level == Terminal.privileges.ADMINISTRATOR:
		add_to_log("You have administrator privileges.")
	if terminal.accounts[profile].privilege_level == Terminal.privileges.NORMAL:
		add_to_log("You have regular privileges.")
	if terminal.accounts[profile].privilege_level == Terminal.privileges.RESTRICTED:
		add_to_log("You have restricted privileges.")
		return
	
