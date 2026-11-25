class_name Sink
extends Node2D

signal demand
signal delivery

var grid_pos: Vector2i
var demand_int: int = 0


func _init(grid_pos_: Vector2i) -> void:
    grid_pos = grid_pos_
    position = Settings.get_global_pos(grid_pos)


func more_demand() -> void:
    pass
