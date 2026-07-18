extends CharacterBody2D

const TILE_SIZE := 64
const MOVE_SPEED := 500.0
const BEDROCK_PHYSIC_LAYER = 1
const TIME_HIDE_WALL = 1.0
var WALLS_OBJECT
var target_position: Vector2
var moving: bool = false
var hidden_tiles := {}
var inputLock: bool = false

func _ready():
	target_position = global_position
	WALLS_OBJECT = $"../Walls"

func _physics_process(delta):
	if inputLock:
		inputLock = false
		return
	
	if Input.is_action_just_pressed("ui_accept") and $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider == WALLS_OBJECT:
			var collision_point = $RayCast2D.get_collision_point() - $RayCast2D.get_collision_normal() * TILE_SIZE / 2
			var cell = WALLS_OBJECT.local_to_map(WALLS_OBJECT.to_local(collision_point))
			hide_tile(cell, TIME_HIDE_WALL)
	
	if moving:
		global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
		if global_position.distance_to(target_position) < 0.1:
			global_position = target_position
			moving = false
		return
	
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if direction == Vector2.ZERO:
		return

	if abs(direction.x) > abs(direction.y):
		direction.y = 0
	else:
		direction.x = 0
	direction = direction.normalized()

	$RayCast2D.target_position = direction * TILE_SIZE
	$RayCast2D.force_raycast_update()
	if !$RayCast2D.is_colliding():
		target_position = global_position + direction * TILE_SIZE
		moving = true

func hide_tile(cell: Vector2i, duration: float):
	if hidden_tiles.has(cell):
		return
	if WALLS_OBJECT.get_cell_tile_data(cell).get_collision_polygons_count(BEDROCK_PHYSIC_LAYER) >= 1:
		return
	
	hidden_tiles[cell] = {
		"source_id": WALLS_OBJECT.get_cell_source_id(cell),
		"atlas_coords": WALLS_OBJECT.get_cell_atlas_coords(cell),
		"alternative": WALLS_OBJECT.get_cell_alternative_tile(cell)
	}

	WALLS_OBJECT.erase_cell(cell)

	await get_tree().create_timer(duration).timeout

	if hidden_tiles.has(cell):
		var tile = hidden_tiles[cell]
		inputLock = true
		WALLS_OBJECT.set_cell(
			cell,
			tile.source_id,
			tile.atlas_coords,
			tile.alternative
		)
		hidden_tiles.erase(cell)
		$Area2D.monitoring = false
		$Area2D.monitoring = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	lose()

func _on_area_2d_area_entered(area: Area2D) -> void:
	lose()

func lose() -> void:
	print("LOSE")
	$"../Label".show()
