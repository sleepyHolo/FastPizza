class_name Sink
extends Node2D

var grid_pos: Vector2i

func _init(grid_pos_: Vector2i) -> void:
    grid_pos = grid_pos_
    position = Settings.get_global_pos(grid_pos)
