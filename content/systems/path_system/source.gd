class_name Source
extends PathNode


func _draw() -> void:
    draw_circle(
        Vector2.ZERO,
        Settings.source_radius,
        Settings.debug_color,
        true,
    )
