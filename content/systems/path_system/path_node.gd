@abstract
class_name PathNode
extends Node2D


var grid_pos := Vector2i.ZERO:
    set(pos):
        grid_pos = pos
        position = Settings.get_global_pos(grid_pos)
        return
