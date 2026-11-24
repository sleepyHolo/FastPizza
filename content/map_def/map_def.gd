class_name MapDef
extends Node2D

@export var systems : Array[System] = []


func _ready() -> void:
    if systems.is_empty():
        _build_systems_from_childen()
    for system : System in systems:
        system.connect_signals.callv(systems)


func _build_systems_from_childen() -> void:
    systems.clear()
    for child : Node in get_children():
        if not is_instance_of(child, System):
            continue
        systems.append(child)
    LogFormatter.info("systems built from childen", "MapDef")


class System extends Node2D:
    
    func _enter_tree() -> void:
        var parent := get_parent()
        if parent != null:
            parent.ready.connect(_on_map_def_ready)
    
    
    func _connect_signals(_system: System) -> void:
        pass
    
    
    func _on_map_def_ready() -> void:
        pass
    
    
    func connect_signals(...systems: Array) -> void:
        for system in systems:
            if system is not System:
                continue
            _connect_signals(system)
