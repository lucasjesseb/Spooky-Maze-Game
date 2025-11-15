extends Node3D

var speed := 6.0
var cell_block_size := 4.0

@onready var grid_map: GridMap = $"../GridMap"

var maze_origin := Vector2(12, 14)
var world

var current_cell := Vector2i.ZERO
var target_cell := Vector2i.ZERO
var moving := false

var last_dir := Vector2i(0, -1)		# start facing “forward” (north)


func _ready() -> void:
	world = generate_maze_array(4, grid_map)
	current_cell = world_to_maze(global_position)
	target_cell = current_cell
	moving = false


func _process(delta: float) -> void:
	if not moving:
		var possible = get_forward_left_right(current_cell, last_dir)

		if possible.size() == 0:
			return	# stuck, shouldn't happen in a maze

		# pick a random non-backwards direction
		var chosen = possible[randi() % possible.size()]
		last_dir = chosen	# store new direction
		target_cell = current_cell + chosen
		moving = true

		# face the new direction visually
		var target_pos = cell_to_world(target_cell)
		look_at(target_pos, Vector3.UP)

	# move toward target cell
	var target_pos = cell_to_world(target_cell)
	var move_dir = (target_pos - global_position).normalized()
	global_position += move_dir * speed * delta

	# reached center of cell?
	if global_position.distance_to(target_pos) < 0.1:
		global_position = target_pos
		current_cell = target_cell
		moving = false


# ---------------------------
#	HELPERS
# ---------------------------

func get_forward_left_right(cell: Vector2i, dir: Vector2i) -> Array:
	var dirs = {}

	# Forward = same direction
	dirs.forward = dir

	# Right = rotate dir clockwise
	dirs.right = Vector2i(dir.y, -dir.x)

	# Left = rotate dir counter-clockwise
	dirs.left = Vector2i(-dir.y, dir.x)

	var available = []

	for key in dirs.keys():
		var d = dirs[key]
		var c = cell + d

		# bounds check
		if c.y < 0 or c.y >= world.size(): continue
		if c.x < 0 or c.x >= world[0].size(): continue

		# walkable?
		if world[c.y][c.x] == 0:
			available.append(d)

	return available


func world_to_maze(world_pos: Vector3) -> Vector2i:
	var x = int(floor(world_pos.x / cell_block_size)) + int(maze_origin.x)
	var z = int(floor(world_pos.z / cell_block_size)) + int(maze_origin.y)
	return Vector2i(x, z)


func cell_to_world(cell: Vector2i) -> Vector3:
	var wx = (cell.x - maze_origin.x) * cell_block_size + cell_block_size * 0.5
	var wz = (cell.y - maze_origin.y) * cell_block_size + cell_block_size * 0.5
	return Vector3(wx, global_position.y, wz)


func get_walkable_neighbors(cell: Vector2i) -> Array:
	var neighbors = []
	var directions = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for d in directions:
		var c = cell + d

		# Bounds check
		if c.y < 0 or c.y >= world.size():
			continue
		if c.x < 0 or c.x >= world[0].size():
			continue

		# 0 = open, 1 = wall
		if world[c.y][c.x] == 0:
			neighbors.append(c)

	return neighbors


func generate_maze_array(cell_block_size, grid_map):
	var used = grid_map.get_used_cells()

	var min_x = INF
	var min_z = INF
	var max_x = -INF
	var max_z = -INF

	for v in used:
		min_x = min(min_x, v.x)
		min_z = min(min_z, v.z)
		max_x = max(max_x, v.x)
		max_z = max(max_z, v.z)

	var width = int((max_x - min_x + 1) / cell_block_size)
	var height = int((max_z - min_z + 1) / cell_block_size)

	var maze = []
	for z in range(height):
		maze.append([])
		for x in range(width):
			maze[z].append(0)

	for z in range(height):
		for x in range(width):
			var blocked := false
			for i in range(cell_block_size):
				for j in range(cell_block_size):
					var world_x = min_x + x * cell_block_size + i
					var world_z = min_z + z * cell_block_size + j
					if grid_map.get_cell_item(Vector3(world_x, 0, world_z)) != grid_map.INVALID_CELL_ITEM:
						blocked = true
			maze[z][x] = (1 if blocked else 0)

	return maze
