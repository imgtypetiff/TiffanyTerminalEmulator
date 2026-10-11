extends TerminalApplication

func _init():
	app_name="Quit"
	description="Quits"
	
func run(terminal : Terminal, params: Array, tty_number: int, profile: String):
	add_to_log("Quitting...")
	get_tree().quit()
