class_name ParsedArgs
extends RefCounted

var positionals: Array[String] = []
var flags: Dictionary = {}
var options: Dictionary = {}
var raw: String = ""
var errors: Array[String] = []

func has_flag(name: String) -> bool:
	return flags.has(name)

func get_option(name: String) -> Variant:
	assert(
		options.has(name),
		"ParsedArgs: Option '%s' was not defined." % name
	)
	return options[name]
