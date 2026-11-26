class_name System
extends Node2D


func _enter_tree() -> void:
    var parent := get_parent()
    if parent != null:
        parent.ready.connect(_on_map_def_ready)


func _exit_tree() -> void:
    var parent := get_parent()
    if parent != null:
        parent.ready.disconnect(_on_map_def_ready)


func _connect_signals(_system: System) -> void:
    pass


func _on_map_def_ready() -> void:
    pass


func connect_signals(...systems: Array) -> void:
    for system in systems:
        if system is not System:
            continue
        _connect_signals(system)
