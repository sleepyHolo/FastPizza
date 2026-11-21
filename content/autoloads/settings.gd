extends Node

var map_size_max: Vector2i = Vector2i(128, 64)
var map_grid_size: Vector2i = Vector2i(64, 64)

var _map_grid_size_inv := Vector2(
    1.0 / map_grid_size.x, 
    1.0 / map_grid_size.y
    )

var debug_color := Color(0.8, 0.16, 0.16, 1.0)

var source_radius: float = 20.0
var sink_radius:   float = 16.0
var sink_width:    float = 4.0

func check_grid_pos(grid_pos: Vector2i) -> bool:
    return grid_pos.x >= 0 and grid_pos.x < map_size_max.x \
        and grid_pos.y >= 0 and grid_pos.y < map_size_max.y


func get_grid_number() -> int:
    return map_size_max.x * map_size_max.y


func get_grid_index(grid_pos: Vector2i) -> int:
    return grid_pos.x + grid_pos.y * map_size_max.x


func get_grid_pos(global_pos: Vector2) -> Vector2i:
    return Vector2i((global_pos * _map_grid_size_inv).floor())


func get_global_pos(grid_pos: Vector2i) -> Vector2:
    return (Vector2(grid_pos) + 0.5 * Vector2.ONE) * Vector2(map_grid_size)
