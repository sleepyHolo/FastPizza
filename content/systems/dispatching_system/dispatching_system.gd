class_name DispatchingSystem
extends System

var _query_only_path_finder: PathSystem.PathFinder


func _on_path_system_init(
    _grid_data: PackedByteArray,
    _path_finder: PathSystem.PathFinder
) -> void:
    _query_only_path_finder = _path_finder


func _connect_signals(system: System) -> void:
    if system is PathSystem:
        system.init.connect(_on_path_system_init)
        return
