class_name PathSystem
extends Node2D

var _grid_path_8: PackedByteArray
var _path_nodes: Dictionary[int, Node2D] = {}

var path_linking: bool = false
var linking_paths : Array[Vector2i] = []
var line_end := Vector2i(-1, -1)

func _ready() -> void:
    _grid_path_8.resize(Settings.get_grid_number())


func _draw() -> void:
    if not OS.is_debug_build():
        return
    for id : int in _path_nodes:
        draw_node(_path_nodes[id].position, _path_nodes[id] is Source)
    var pts := PackedVector2Array()
    # linking lines
    if linking_paths.size() > 1:
        for grid_pos in linking_paths:
            pts.append(Settings.get_global_pos(grid_pos))
        draw_polyline(pts, Settings.debug_color, 2.0)


func _physics_process(delta: float) -> void:
    queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        debug_edit_path_node(event)
        return
    if (not path_linking) and event.is_action_pressed("select"):
        path_linking = true
        linking_paths.clear()
        line_end = Vector2i(-1, -1)
        extend_to(Settings.get_grid_pos(get_global_mouse_position()))
        get_viewport().set_input_as_handled()
        return
    if path_linking and event.is_action_released("select"):
        path_linking = false
        get_viewport().set_input_as_handled()
        return
    if event is InputEventMouseMotion and path_linking:
        extend_to(Settings.get_grid_pos(get_global_mouse_position()))
        get_viewport().set_input_as_handled()
        return


func debug_edit_path_node(event: InputEventMouseButton) -> void:
    if not OS.is_debug_build():
        return
    if event.is_action_pressed("select"):
        spawn_node(Settings.get_grid_pos(get_global_mouse_position()), true)
        get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("unselect"):
        spawn_node(Settings.get_grid_pos(get_global_mouse_position()), false)
        get_viewport().set_input_as_handled()
        return


func extend_to(target: Vector2i) -> void:
    if not walkable(target):
        return
    if line_end.x == -1:
        linking_paths.append(target)
        line_end = target
        return
    
    for grid in get_line_grids(line_end, target):
        if not walkable(grid):
            return
        var i = linking_paths.find(grid)
        if i != -1:
            linking_paths.resize(i + 1)
            line_end = grid
            continue
        linking_paths.append(grid)
        line_end = grid


func get_line_grids(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var out: Array[Vector2i] = []
    var cur := from
    while cur != to:
        var dx := to.x - cur.x
        var dy := to.y - cur.y
        if dx == 0:
            cur.y += signi(dy)
        elif dy == 0:
            cur.x += signi(dx)
        elif absi(dx) >= absi(dy):
            cur.x += signi(dx)
        else:
            cur.y += signi(dy)
        out.append(cur)
    return out


func walkable(target: Vector2i) -> bool:
    if not Settings.check_grid_pos(target):
        return false
    return true
    

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
        -1.0 if is_source else Settings.sink_width
    )
