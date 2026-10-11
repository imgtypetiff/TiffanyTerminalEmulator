extends Node

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://screenshots")

func take_screenshot() -> void:
	# Wait for the frame to finish drawing
	await RenderingServer.frame_post_draw
	
	# Get the image from the main viewport
	var img: Image = get_viewport().get_texture().get_image()
	
	# Save the image to the user data folder
	img.save_png("user://screenshot.png")
