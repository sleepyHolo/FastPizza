class_name Truck
extends Node2D

func _draw() -> void:
    if OS.is_debug_build():
        # debug
        draw_circle(
            position,
            Settings.source_radius,
            Settings.debug_color,
            true,
        )
        return
