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
    draw_string(
        ThemeDB.fallback_font,
        Vector2.ZERO,
        "%s" % demand_int,
    )


func _unhandled_input(event: InputEvent) -> void:
    if Settings.debugging and event.is_action_pressed("select"):
        if _check_input_grid():
            more_demand()
            get_viewport().set_input_as_handled()
    return


func more_demand() -> void:
    demand_int += 1
    queue_redraw()
