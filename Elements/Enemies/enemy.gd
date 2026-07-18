extends CharacterBody2D
class_name Enemy

const TILE_SIZE := 64
const MOVE_SPEED := 500.0
const BEDROCK_PHYSIC_LAYER = 1
const DIRECTIONS := [
	Vector2.RIGHT,
	Vector2.LEFT,
	Vector2.UP,
	Vector2.DOWN,
]
var WALLS_OBJECT
var target_position: Vector2
var moving: bool = false

func _ready() -> void:
	WALLS_OBJECT = $"../Walls"

func _physics_process(delta: float) -> void:
	if moving:
		global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
		if global_position.distance_to(target_position) < 0.1:
			global_position = target_position
			moving = false
		return

func move() -> void:
	var direction := get_random_direction()
	$RayCast2D.target_position = direction * TILE_SIZE
	$RayCast2D.force_raycast_update()
	if !$RayCast2D.is_colliding():
		target_position = global_position + direction * TILE_SIZE
		moving = true
	else:
		if check_move_possible_all_directions():
			move()

func check_move_possible(direction: Vector2) -> bool:
	$RayCast2D.target_position = direction * TILE_SIZE
	$RayCast2D.force_raycast_update()
	return !$RayCast2D.is_colliding()

func check_move_possible_all_directions() -> bool:
	for direction in DIRECTIONS:
		if check_move_possible(direction):
			return true
	return false

func get_random_direction() -> Vector2:
	return DIRECTIONS.pick_random()

func _on_timer_timeout() -> void:
	move()
