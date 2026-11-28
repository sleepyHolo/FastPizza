class_name Truck
extends PathFollow2D

@export
var speed: float = 200.0

var running: bool = false


func _draw() -> void:
    if OS.is_debug_build():
        # debug
        draw_circle(
            Vector2.ZERO,
            0.7 * Settings.source_radius,
            Settings.debug_color,
            true,
        )
        return


func _process(delta: float) -> void:
    if running:
        progress += speed * delta
