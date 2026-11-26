class_name Sink
extends PathNode

signal demand
signal delivery

var demand_int: int = 0


func _draw() -> void:
    draw_circle(
        Vector2.ZERO,
        Settings.sink_radius,
        Settings.debug_color,
        false,
        Settings.sink_width,
    )


func more_demand() -> void:
    pass
