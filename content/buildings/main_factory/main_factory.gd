class_name MainFactory
extends Node2D

@export
var sources: Array[Source] = []
@export
var size: Vector2i

var grid_lt: Vector2i
var grid_rb: Vector2i


func _enter_tree() -> void:
    z_index = Settings.debug_z_index
    Settings.debugging_changed.connect(_on_settings_debugging_changed)
    _on_settings_debugging_changed(Settings.debugging)


func _exit_tree() -> void:
    Settings.debugging_changed.disconnect(_on_settings_debugging_changed)


func _ready() -> void:
    move_to_center()
    move_sources()
    LogFormatter.info("init.", "MainFactory")


func _draw() -> void:
    var r := Rect2(
        -Settings.map_grid_size * (size + Vector2i.ONE),
        2 * Settings.map_grid_size * (size + Vector2i.ONE),
    )
    draw_rect(
        r,
        Settings.debug_color,
        false,
    )


func _on_settings_debugging_changed(_debugging: bool) -> void:
    visible = _debugging


func move_to_center() -> void:
    position = Settings.map_grid_size * Vector2i(Settings.map_size_max / 2.0)


func move_sources() -> void:
    var center_r := floori(Settings.map_size_max.x / 2.0)
    var center_b := floori(Settings.map_size_max.y / 2.0)
    for source : Source in sources:
        var x := (source.relative_grid_pos.x < 0) as int
        var y := (source.relative_grid_pos.y < 0) as int
        source.grid_pos = Vector2i(
            center_r + source.relative_grid_pos.x - x,
            center_b + source.relative_grid_pos.y - y,
        )
    grid_lt = Vector2i(center_r, center_b) - size - Vector2i.ONE
    grid_rb = Vector2i(center_r, center_b) + size
    return
