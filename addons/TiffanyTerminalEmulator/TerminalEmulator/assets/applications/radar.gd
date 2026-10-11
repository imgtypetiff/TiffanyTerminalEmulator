extends TerminalApplication

func _init() -> void:
	app_name = "Radar"
	description = "Access to the ship's radar."

func run(terminal: Terminal, parsed: Array, tty_number: int, profile: String) -> void:
	print(Terminal.privileges.find_key(terminal.accounts[profile].privilege_level))
	if terminal.accounts[profile].privilege_level != Terminal.privileges.ADMINISTRATOR:
		add_error("ERROR: You need to be admin to run this command.")
		return
	
