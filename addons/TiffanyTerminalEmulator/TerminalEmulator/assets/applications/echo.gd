extends TerminalApplication

func _init():
	app_name="Echo"
	description="Write arguments to the standard output"

func run(terminal : Terminal, params: Array, tty_number: int, profile: String):
	add_to_log(" ".join(params))
