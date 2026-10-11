extends FSNode
class_name FSFileNode

func read_text() -> String:
	if !FileAccess.file_exists(real_path):
		return ""

	var f = FileAccess.open(real_path, FileAccess.READ)
	return f.get_as_text()

func write_text(text:String):
	var f = FileAccess.open(real_path, FileAccess.WRITE)
	f.store_string(text)

func get_data() -> PackedByteArray:
	if !FileAccess.file_exists(real_path):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(real_path)
