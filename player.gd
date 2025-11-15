extends CharacterBody3D

@onready var neck: Node3D = $neck
@onready var camera_3d: Camera3D = $neck/Camera3D

var speed := 5.0
var base_speed := 5.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity := 0.003
var camera_pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_pitch = clamp(
			camera_pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
		neck.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func boost_speed(amount := 3.0, duration := 5.0):
	speed += amount
	print("Boost applied! New speed:", speed)

	await get_tree().create_timer(duration).timeout

	speed -= amount
	print("Boost ended. Speed reset:", speed)
