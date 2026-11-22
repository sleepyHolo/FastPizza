class_name ManhattanAStar2D
extends AStar2D

func _compute_cost(from_id: int, to_id: int) -> float:
    return _estimate_cost(from_id, to_id)


func _estimate_cost(from_id: int, to_id: int) -> float:
    var from_pos = get_point_position(from_id)
    var to_pos = get_point_position(to_id)
    return abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
