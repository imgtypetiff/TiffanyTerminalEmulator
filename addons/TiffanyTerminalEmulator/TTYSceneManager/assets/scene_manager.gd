extends Node

var current_tty: int = 1

func _ready():
	Terminal.tty.connect(switch_tty.bind(current_tty))

func switch_tty(index: int) -> void:
	var ttys = Terminal.ttys
	
	if Terminal.ttys.keys().has(index):
		#print(Terminal.ttys[index].node)
		pass
	for n in Terminal.ttys.keys():
		if n != index:
			if "visible"  in Terminal.ttys[n].node:
				Terminal.ttys[n].node.hide()
			if Terminal.ttys[n].node is Control:
				Terminal.ttys[n].node.release_focus()
