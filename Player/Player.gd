extends KinematicBody

export var speed = 10
export var sprint_speed = 20
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3

onready var head = $Head
onready var camera = $Head/Camera
onready var raycast = $Head/Camera/BulletCast

onready var Bullet = preload("res://Bullet/PhysicalBullet.tscn")

var velocity = Vector3()
var camera_x_rotation = 0
var head_basis = Vector3()
var direction = Vector3()

var shotTimerReady = true

func _ready():
	$Head/Camera/CanvasLayer/Control/ResumeButton.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
			camera.rotate_x(deg2rad(-x_delta))
			$Gun.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
			
	if Input.is_action_just_pressed("mouse_capture"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("mouse_release"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$Head/Camera/CanvasLayer/Control/ResumeButton.show()
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("shoot"):
		if shotTimerReady:
			shotTimerReady = false
			$ShotTimer.start()
			$GunShotSound.play()
			
			var b = Bullet.instance()
			owner.add_child(b)
			b.transform = $Gun/Muzzle.global_transform
			b.velocity = -b.transform.basis.z * b.muzzle_velocity

func _physics_process(delta):
	head_basis = head.get_global_transform().basis
	
	direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
	
	direction = direction.normalized()
	
	var move_speed = speed
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
		
	velocity = velocity.linear_interpolate(direction * move_speed, acceleration * delta)
	velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)


func _on_ShotTimer_timeout():
	shotTimerReady = true
	pass # Replace with function body.


func _on_ResumeButton_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$Head/Camera/CanvasLayer/Control/ResumeButton.hide()
	pass # Replace with function body.
