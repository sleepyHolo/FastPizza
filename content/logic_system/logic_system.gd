class_name LogicSystem
extends System

@onready
var weekly_timer: Timer = $WeeklyTimer

var _read_only_grid_data


func _physics_process(delta: float) -> void:
    pass


func _on_weekly_timer_timeout() -> void:
    LogFormatter.info("timer test")


func _on_path_system_init(
    grid_data: PackedByteArray,
) -> void:
    _read_only_grid_data = grid_data


func _connect_signals(system: MapDef.System) -> void:
    if system is PathSystem:
        system.init.connect(_on_path_system_init)
        return
