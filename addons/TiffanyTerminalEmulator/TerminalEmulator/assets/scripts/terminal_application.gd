extends Node
class_name TerminalApplication

var app_name := "Application"
var description := ""

# Set by Terminal before run()
var _terminal: Terminal
var _tty_number:int
var _profile:String

# Command definition
var schema := TerminalCommandSchema.new()

# Override in child applications
func setup_schema() -> void:
	pass

# Override in child applications
func run(terminal, parsed: Array, tty_number: int, profile: String) -> void:
	pass

# =====================================================
# Session Helpers
# =====================================================

func get_session() -> TTYSession:
	return _terminal.ttys[_tty_number]

func get_environment() -> TerminalEnvironment:
	return get_session().environment

func get_profile() -> String:
	return get_session().profile

func get_cwd() -> String:
	return get_session().current_directory

func set_cwd(path:String) -> void:
	get_session().current_directory = path

# =====================================================
# Logging
# =====================================================



func add_to_color_log(color: Color, ...statement: Array):
	_terminal.add_to_log(
		_tty_number,
		"".join(statement),
		true,
		color
	)

func add_to_log(...statement:Array) -> void:
	_terminal.add_to_log(
		_tty_number,
		"".join(statement)
	)

func add_error(...statement:Array) -> void:
	var msg := "".join(statement)

	add_to_color_log(
		Color.RED,
		msg
	)

# =====================================================
# Environment Helpers
# =====================================================

func set_env(name:String, value) -> void:
	get_environment().set_var(
		name,
		value
	)

func get_env(name:String):
	return get_environment().get_var(
		name
	)

func has_env(name:String) -> bool:
	return get_environment().has_var(
		name
	)

# =====================================================
# Permission Helpers
# =====================================================

func require_profile(profile_name:String) -> bool:

	if get_profile() != profile_name:

		add_error(
			"Permission denied."
		)

		return false

	return true

# =====================================================
# Convenience Helpers
# =====================================================

func get_terminal():
	return _terminal

func get_tty() -> int:
	return _tty_number

func get_arguments(
	parsed: ParsedArgs
) -> Array:

	return parsed.positionals

func finish() -> void:
	queue_free()
