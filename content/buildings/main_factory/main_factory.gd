class_name MainFactory
extends Node2D

@export
var sources: Array[Source] = []


func _ready() -> void:
    move_to_center()
    move_sources()
    LogFormatter.info("init.", "MainFactory")


func move_to_center() -> void:
    position = Settings.map_grid_size * Settings.map_size_max / 2.0


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
    return
