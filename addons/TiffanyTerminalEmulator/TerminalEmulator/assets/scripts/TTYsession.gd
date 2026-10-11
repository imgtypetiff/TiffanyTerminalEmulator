class_name TTYSession
extends RefCounted

var logged_in: bool
var node: Node
var profile: String
var active := false

var tty_log: Array = []

var current_directory := "/"

var environment := TerminalEnvironment.new()

func initialize(p_node:Node, p_profile:String, p_directory:String, log_in: bool):
	node = p_node
	profile = p_profile
	active = true
	current_directory = p_directory
	logged_in = log_in
