extends StaticBody2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	#if Input.is_action_pressed("ui_accept"):
		#hideWall()

func hideWall():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Timer.start()

func showWall():
	show()
	$CollisionShape2D.set_deferred("disabled", false)

func _on_timer_timeout() -> void:
	showWall()
