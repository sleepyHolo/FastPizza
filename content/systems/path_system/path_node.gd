@abstract
class_name PathNode
extends Node2D


@export 
var relative_grid_pos := Vector2i.ZERO

var grid_pos := Vector2i.ZERO:
    set(pos):
        grid_pos = pos
        global_position = Settings.get_global_pos(grid_pos)
        return

@export
var node_link : PathNodeLink = PathNodeLink.LINK_POS_X

func _enter_tree() -> void:
    z_index = Settings.debug_z_index
    Settings.debugging_changed.connect(_on_settings_debugging_changed)
    _on_settings_debugging_changed(Settings.debugging)


func _exit_tree() -> void:
    Settings.debugging_changed.disconnect(_on_settings_debugging_changed)


func _on_settings_debugging_changed(_debugging: bool) -> void:
    visible = _debugging


func _check_input_grid() -> bool:
    var mouse_grid := Settings.get_grid_pos(get_global_mouse_position())
    return mouse_grid == grid_pos


enum PathNodeLink {
    LINK_POS_X = PathSystem.LINK_POS_X,
    LINK_POS_Y = PathSystem.LINK_POS_Y,
    LINK_NEG_X = PathSystem.LINK_NEG_X,
    LINK_NEG_Y = PathSystem.LINK_NEG_Y,
}
