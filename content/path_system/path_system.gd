class_name PathSystem
extends Node2D

var _grid_path_8: PackedByteArray
var _path_nodes: Dictionary[int, Node2D] = {}

func _ready() -> void:
    _grid_path_8.resize(Settings.get_grid_number())


func _draw() -> void:
    if not OS.is_debug_build():
        return
    for id : int in _path_nodes:
        draw_node(_path_nodes[id].position, _path_nodes[id] is Source)


func _physics_process(delta: float) -> void:
    queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventMouseButton:
        return
    if event.double_click:
        debug_edit_path_node(event)


func debug_edit_path_node(event: InputEventMouseButton) -> void:
    if not OS.is_debug_build():
        return
    if event.button_index == MOUSE_BUTTON_LEFT:
        spawn_node(Settings.get_grid_pos(get_global_mouse_position()), true)
    elif event.button_index == MOUSE_BUTTON_RIGHT:
        spawn_node(Settings.get_grid_pos(get_global_mouse_position()), false)


func spawn_node(grid_pos: Vector2i, is_source: bool) -> void:
    if not Settings.check_grid_pos(grid_pos):
        return
    var id := Settings.get_grid_index(grid_pos)
    if not _path_nodes.has(id):
        if is_source:
            _path_nodes[id] = Source.new(grid_pos)
            print("add a source at %s" % grid_pos)
        else:
            _path_nodes[id] = Sink.new(grid_pos)
            print("add a sink   at %s" % grid_pos)
        add_child(_path_nodes[id])
        # todo log


func draw_node(global_pos: Vector2, is_source: bool) -> void:
    draw_circle(
        global_pos,
        Settings.source_radius if is_source else Settings.sink_radius,
        Settings.debug_color,
        is_source,
        Settings.sink_width
    )
