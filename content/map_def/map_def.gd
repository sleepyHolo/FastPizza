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
