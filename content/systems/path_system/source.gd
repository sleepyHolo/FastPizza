class_name Source
extends PathNode

var car_num: int = 0


func _draw() -> void:
    draw_circle(
        Vector2.ZERO,
        Settings.source_radius,
        Settings.debug_color,
        true,
    )
    draw_string(
        ThemeDB.fallback_font,
        Vector2.ZERO,
        "%s" % car_num,
    )


func _unhandled_input(event: InputEvent) -> void:
    if Settings.debugging and event.is_action_pressed("select"):
        if _check_input_grid():
            more_truck()
            get_viewport().set_input_as_handled()
    return


func more_truck() -> void:
    car_num += 1
    queue_redraw()
