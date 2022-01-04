extends Control

var loader
var wait_frames
var time_max = 100 # msec
var current_scene

onready var scene_to_load = Globals.g_next_level

func show_error():
	print("Error While Loading")

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	if scene_to_load:
		goto_scene(scene_to_load)
	else:
		print("nothing to load...")
	
func goto_scene(path): # Game requests to switch to this scene.
	get_tree().change_scene(path)
	
	"""loader = ResourceLoader.load_interactive(path)
	if loader == null: # Check for errors.
		show_error()
		return
	set_process(true)"""

	#current_scene.queue_free() # Get rid of the old scene.

	# Start your "loading..." animation.
	get_node("animation").play("loading")

	wait_frames = 1
	
func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	# Wait for frames to let the "loading" animation show up.
	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # Error during loading.
			show_error()
			loader = null
			break
			
func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# Update your progress bar?
	$VBoxContainer/progress.value = progress

	# ...or update a progress animation?
	var length = get_node("animation").get_current_animation_length()

	# Call this on a paused animation. Use "true" as the second argument to
	# force the animation to update.
	get_node("animation").seek(progress * length, true)

func set_new_scene(scene_resource):
	current_scene.queue_free() # Get rid of the old scene.
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
