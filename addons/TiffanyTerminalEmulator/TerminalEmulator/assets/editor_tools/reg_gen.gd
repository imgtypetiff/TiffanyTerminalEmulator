@tool
extends EditorScript
var REGISTRIES_FOLDER := get_root_folder().path_join("registries")
var FONT_PATH := get_root_folder().path_join("assets/fonts")
var APPS_PATH := get_root_folder().path_join("assets/applications/")
var APP_OUTPUT_PATH := get_root_folder().path_join("registries/app_registry.gd")
var FONT_OUTPUT_PATH := get_root_folder().path_join("registries/font_registry.gd")
var CACHE_PATH := get_root_folder().path_join("cache")

func get_root_folder() -> String:
	var folder_path: String = get_script().resource_path.get_base_dir().get_base_dir().get_base_dir()
	return folder_path

const VALID_EXTENSIONS := [
	"tscn",
	"tres",
	"res",
	"gd",
	"png",
	"ogg",
	"wav",
	"mp3",
	"ttf",
	"svg",
]

var directories: Array = []
var files: Array = []
var file_names = []

func _run():
	print("hi")
	DirAccess.make_dir_recursive_absolute(get_root_folder().path_join("registries"))
	scan_for_files(APP_OUTPUT_PATH,APPS_PATH,"")
	scan_for_files(FONT_OUTPUT_PATH,FONT_PATH,"")

func scan_for_files(PLACE_TO_SAVE: String, PLACE_TO_SCAN: String, type: String, include_extension: bool = false):
	files = []
	directories = []
	var lines := []
	lines.append("extends Node")
	lines.append("const APPLICATIONS := {")
	dir_contents(PLACE_TO_SCAN)
	for dir in directories:
		if dir.begins_with("."):
			pass
		elif dir.ends_with(".cache"):
			pass
		else:
			dir_contents(dir + "/")
	var cache_file: String = CACHE_PATH.path_join(PLACE_TO_SAVE.get_file().get_basename() + ".cache.log")
	if FileAccess.file_exists(cache_file):
		var file = FileAccess.get_file_as_string(cache_file)
		if Array(file.split("\n")) == files:
			return
	for file in files:
		var pure_file = file.get_file().get_basename()
		if ResourceLoader.exists(file):
			if include_extension:
				pure_file += "." + file.get_file().get_extension()
			if file.is_empty():
				var line = '\t"%s": "%s",' % [pure_file, path_to_uid(file)]
				lines.append(line)
			elif file.ends_with(type):
				var line = '\t"%s": "%s",' % [pure_file, path_to_uid(file)]
				lines.append(line)
	lines.append("}")
	write(lines,PLACE_TO_SAVE)
	write(files, CACHE_PATH.path_join(PLACE_TO_SAVE.get_file().get_basename() + ".cache.log"))

func path_to_uid(path) -> String:
	# 1. Get the integer representation of the UID
	var uid_int: int = ResourceLoader.get_resource_uid(path)

	# 2. Convert the integer into a readable string (e.g., "uid://...")
	var uid_string: String = ResourceUID.id_to_text(uid_int)
	return uid_string

func dir_contents(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if !file_name.begins_with("."):
					directories.append(path.path_join(file_name))
					# print(path.path_join(file_name))
			else:
				if !file_name.begins_with("."):
					files.append(path.path_join(file_name))
					print(path_to_uid(path.path_join(file_name)))
					# print(path.path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func write(lines, path):
	var gun = FileAccess.open(path, FileAccess.WRITE)
	if gun == null:
		push_error("Failed to open output file: " + APP_OUTPUT_PATH)
		return
	#print(path)
	#print("\n".join(lines))
	gun.store_string("\n".join(lines))
	gun.close()
