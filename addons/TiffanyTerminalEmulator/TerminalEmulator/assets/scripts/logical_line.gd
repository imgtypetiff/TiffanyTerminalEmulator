class_name TerminalLogicalLine
extends Object

# Array of Dictionaries: {"char": String, "color": Color, "highlight": Color}
var chars: Array[Dictionary] = []


func insert_char(index: int, character: String, color: Color, highlight: Color = Color(1,1,1,0)) -> void:
	chars.insert(index, {"char": character, "color": color, "highlight": highlight})


func delete_char(index: int) -> void:
	if index >= 0 and index < chars.size():
		chars.remove_at(index)
	else:
		push_error("Terminal: delete_char: invalid index.")


func get_text(start_index: int = 0, end_index: int = -1) -> String:
	if end_index == -1 or end_index > chars.size():
		end_index = chars.size()
	var text: String = ""
	for i in range(start_index, end_index):
		text += chars[i]['char']
	return text


func length() -> int:
	return chars.size()
