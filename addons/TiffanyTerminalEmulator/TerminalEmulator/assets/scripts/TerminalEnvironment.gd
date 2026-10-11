# terminal_environment.gd
class_name TerminalEnvironment
extends RefCounted

var variables: Dictionary = {}

func set_var(name:String, value) -> void:
	variables[name] = value

func has_var(name:String) -> bool:
	return variables.has(name)

func get_var(name:String):
	if !variables.has(name):
		return null

	var value = variables[name]

	if value is Callable:
		return value.call()

	return value

func erase_var(name:String):
	variables.erase(name)

func list_vars() -> Dictionary:
	var result := {}

	for key in variables:
		result[key] = get_var(key)

	return result
