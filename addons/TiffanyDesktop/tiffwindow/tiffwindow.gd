@icon("res://addons/TiffanyDesktop/tiffwindow/ControlNodeWindow.svg")
@tool # use this if you want your content poition updated in the editor
# but be carefull, dont forget to reload the project when changing @tool

extends Control
class_name tiffwindow

## Emitted when interacted. Event is the event that was triggered.
signal interacted(type: InteractionType)

signal current_window_changed(current_window: tiffwindow)

signal content_changed(content: Node)

enum InteractionType{
	Top,
	Bottom,
	Left,
	Right,
	BottomLeft,
	BottomRight,
	Expand,
	Minimize,
	Ignore_This,
}

enum PopupType{
	Custom,
}

static var selected_window: tiffwindow

## The location and size where the window wil popup
@export
var popup_rect:Rect2 = Rect2(Vector2.ZERO,Vector2.ZERO)

var _window_name: String

## The name of the Window at the top Bar
@export
var window_name:String  = "Window":
	set(v):
		if __is_ready:
			_window_name = v
			window_title_label.text = v
			window_name = v

## If true, instead of clamping to the viewport's size, it uses the parent's size.
@export
var desktop_mode: bool = false

## put your window content (preferably in a ScrollContainer) as a child of the Window Node. 
## This Variable will be set automaticaly.
var window_content:Control 

## The contents name.
var app_name: String

## Size before being expanded. See [method expand].
var expand_before_size: Vector2

## Position before being expanded. See [method expand].
var expand_before_position: Vector2

## Size before being minimized. See [method minimize].
var minimize_before_size: Vector2

## Position before being minimized. See [method minimize].
var minimize_before_position: Vector2

## true if window expanded.
var is_expanded: bool

## true if minimized
var is_minimized: bool
## True if in animation (expanding, minimizing) false if not.
var in_animation: bool = false

## Determines if the window stays in the viewport. Mostly here to make minimizing smooth. [br]
## Don't edit this unless you know what you're doing.
var stay_in_viewport: bool = true

## lancer_explosion.ogv requires to be set of else window breaks. See [method ensure_dependencies]
var lancer_explosion: VideoStreamTheora = preload("res://addons/TiffanyDesktop/tiffwindow/lancer_explosion.ogv")

## This is where the content will be placed.
@onready var content_placeholder: Control = $VBoxContainer/HBoxContainer2/CenterPanel/MarginContainer/ContentPlaceholder

@onready var window_title_label: Label = %WindowName

@onready var _option_bar: HBoxContainer = $VBoxContainer/MarginContainer/OptionsBar

## True during expanding animation.
var _expanding: bool

var __is_ready:bool = false

var update_content_placement_first_call = true

func _ready() -> void:
	if _window_name == null :
		_window_name = "NULL"
	var viewport:Viewport = self.get_viewport()
	viewport.size_changed.connect(_on_item_rect_changed)
	content_placeholder = $VBoxContainer/HBoxContainer2/CenterPanel/MarginContainer/ContentPlaceholder
	window_title_label = %WindowName
	ensure_dependencies()
	update_content_placement()
	if not Engine.is_editor_hint():
		push_warning("Please ignore the previous warning. Do NOT use set_deferred().")
	content_changed.connect(_run_content_API)

func __r_hellper_for_changing_variable_deferred():
	update_content_placement_first_call=true

func update_content_placement():
	if not update_content_placement_first_call:
		return
	#ensure to stay at same location
	popup_rect = self.get_rect()
	update_content_placement_first_call=false
	_update_content_placement_deferred()

func _update_content_placement_deferred():
	if not __is_ready and not Engine.is_editor_hint():
		return

	if content_placeholder == null:
		return

	var found: Control = null

	for child in get_children():
		if child == content_placeholder:
			continue
		if child.is_in_group("Window"):
			continue
		if child is Control:
			found = child
			break

	if found == null:
		return
	if window_content != found:
		window_content = found
		content_changed.emit(found)
	else:
		window_content = found

	# Runtime
	if not Engine.is_editor_hint():
		if window_content.get_parent() != content_placeholder:
			window_content.reparent(content_placeholder)

		# Let layout system control it
		window_content.position = Vector2.ZERO
		window_content.anchor_left = 0.0
		window_content.anchor_top = 0.0
		window_content.anchor_right = 1.0
		window_content.anchor_bottom = 1.0
		window_content.offset_left = 0
		window_content.offset_top = 0
		window_content.offset_right = 0
		window_content.offset_bottom = 0

		window_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		window_content.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Optional: content can define minimum size
		custom_minimum_size = window_content.get_combined_minimum_size() + Vector2(15, 45)
		$Content_dummy.hide()

	# Editor preview
	else:
		var target_pos = content_placeholder.global_position
		var target_size = content_placeholder.size
		if window_content.global_position != target_pos:
			window_content.global_position = target_pos
		if window_content.size != target_size:
			window_content.size = target_size

func _on_top_panel_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.Top)

func _on_border_left_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.Left)

func _on_border_right_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.Right)

func _on_border_bot_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.Bottom)

func _on_corner_bot_right_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.BottomRight)

func _on_corner_bot_left_gui_input(event: InputEvent) -> void:
	_handle_resize(event, InteractionType.BottomLeft)

func _on_item_rect_changed() -> void:
	if stay_in_viewport:
		if not self.get_viewport():
			return 
		if not Engine.is_editor_hint():
			_handle_size()
	if size != get_viewport_rect().size && is_expanded:
		is_expanded = false
	update_content_placement()

func _handle_resize(event: InputEvent, type: InteractionType):
	if is_expanded:
		return
	if event is InputEventMouseMotion and event.button_mask == 1:
		match type:
			InteractionType.Left:
				size.x -= event.relative.x
				position.x += event.relative.x
			InteractionType.Right:
				size.x += event.relative.x
			InteractionType.Bottom:
				size.y += event.relative.y
			InteractionType.BottomLeft:
				size.x -= event.relative.x
				position.x += event.relative.x
				size.y += event.relative.y
			InteractionType.BottomRight:
				size.x += event.relative.x
				size.y += event.relative.y
			InteractionType.Top:
				position += event.relative
		interacted.emit(type)
		update_content_placement()

func _handle_size() -> void:
	var clam = get_viewport_rect()
	if get_tree().current_scene != self && desktop_mode:
		if get_parent() is Control && !_expanding:
			clam = get_parent()
	self.position.x = clamp(self.position.x, 0 , clam.size.x - self.size.x)
	self.position.y = clamp(self.position.y, 0 , clam.size.y - self.size.y)
	var tmpx: float = clamp(self.size.x, 0 , clam.size.x )
	var tmpy: float = clamp(self.size.y, 0 , clam.size.y )
	
	self.size = Vector2(tmpx, tmpy)

func _on_child_order_changed() -> void:
	_update_content_placement_deferred()

func close() -> void:
	self.queue_free()

func _process(_delta):
	update_content_placement()
	if Engine.is_editor_hint():
		_update_content_placement_deferred()
	if in_animation:
		update_content_placement()

func _run_content_API(_content: Control):
	if window_content != null:
		if window_content.has_method("_trigger_callback_tiffwindow_api"):
			window_content.call("_trigger_callback_tiffwindow_api", self)

func expand() -> void:
	interacted.emit(InteractionType.Expand)
	if !visible:
		self.process_mode=Node.PROCESS_MODE_PAUSABLE
		var expand_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		expand_tween.parallel().tween_property(self, "scale", Vector2(1,1),1)
		await expand_tween.finished
		self.show()
	if !is_expanded:
		_expanding = true
		expand_before_position = self.position
		expand_before_size = self.size
		in_animation = true
		var expand_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		expand_tween.parallel().tween_property(self, "size", get_viewport_rect().size, 1)
		expand_tween.parallel().tween_property(self,"position", Vector2(0,0),1)
		await expand_tween.finished
		in_animation = false
		is_expanded = true
		_expanding = false
		return
	if is_expanded:
		in_animation = true
		var expand_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		expand_tween.parallel().tween_property(self, "size", expand_before_size, 1)
		expand_tween.parallel().tween_property(self,"position", expand_before_position,1)
		await expand_tween.finished
		in_animation = false
		is_expanded = false
		return

func minimize() -> void:
	interacted.emit(InteractionType.Minimize)
	stay_in_viewport = false
	var minimize_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	minimize_before_position = position
	minimize_before_size = size
	minimize_tween.parallel().tween_property(self, "scale", Vector2(0.01,0.01),1)
	minimize_tween.parallel().tween_property(self, "global_position", global_position + Vector2(size.x/2,size.y/2),1)
	await minimize_tween.finished
	var explosion = VideoStreamPlayer.new()
	explosion.stream = lancer_explosion
	explosion.top_level= true
	add_child(explosion)
	explosion.play()
	explosion.scale = Vector2(0.35,0.35)
	explosion.global_position = self.global_position
	await explosion.finished
	explosion.queue_free()
	self.hide()
	if !is_expanded:
		stay_in_viewport = true
	is_minimized = true
	self.process_mode=Node.PROCESS_MODE_DISABLED

func unminimize():
	self.show()
	self.process_mode= Node.PROCESS_MODE_INHERIT
	var minimize_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	minimize_tween.parallel().tween_property(self, "scale", Vector2(1,1),1)
	minimize_tween.parallel().tween_property(self, "position", minimize_before_position,1)
	is_minimized = false

func set_current_window(_event = null):
	selected_window = self

	if desktop_mode:
		get_parent().move_child(self, -1)

	current_window_changed.emit(self)

func ensure_dependencies():
	if lancer_explosion == null:
		printerr("lancer_explosion.ogv not found, deleting window.")
		queue_free()
	if !self.is_connected("interacted",  set_current_window):
		interacted.connect(set_current_window)
	__is_ready = true
	show()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked = get_viewport().gui_get_hovered_control()
		if is_ancestor_of(clicked):
			set_current_window()

func add_option_button() -> MenuButton:
	var button: MenuButton = MenuButton.new()
	_option_bar.add_child(button)
	print("hi again")
	return button
