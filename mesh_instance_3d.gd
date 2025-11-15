extends MeshInstance3D

@onready var area = $Area3D
@onready var sound = $AudioStreamPlayer3D

func _ready() -> void:
	print("Pellet ready, connecting!")
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print("Collided with:", body)

	if body.is_in_group("player"):
		print("Player detected!")

		if body.has_method("boost_speed"):
			print("Boosting player!")
			body.boost_speed()

		if sound:
			print("Playing sound")
			sound.play()

		visible = false
		area.monitoring = false
		area.monitorable = false

		if sound:
			await sound.finished

		queue_free()
