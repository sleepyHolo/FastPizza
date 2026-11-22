class_name PathSystem
extends Node2D

var _grid_data: PackedByteArray
var _path_nodes: Dictionary[int, Node2D] = {}
var _astar: ManhattanAStar2D

var path_linking: bool = false
var linking_paths : Array[Vector2i] = []
var line_end := Vector2i(-1, -1)

var unselecting: bool = false

const LINK_DEF   := 0b1111
const LINK_POS_X := 0b0001
const LINK_POS_Y := 0b0010
const LINK_NEG_X := 0b0100
const LINK_NEG_Y := 0b1000

const TILE_DEF   := 0b110000
const IS_SOURCE  := 0b010000
const IS_SINK    := 0b100000

func _ready() -> void:
    _grid_data.resize(Settings.get_map_size())
    _astar = ManhattanAStar2D.new()
    build_astar()


func _draw() -> void:
    if not OS.is_debug_build():
        return
    for id : int in _path_nodes:
        draw_node(_path_nodes[id].position, _path_nodes[id] is Source)
    # build linked lines
    var pts := PackedVector2Array()
    for x in Settings.map_grid_size.x:
        for y in Settings.map_grid_size.y:
            var tmp := _grid_data.get(Settings.get_grid_index(Vector2i(x, y)))
            if tmp & LINK_POS_X:
                pts.append(Settings.get_global_pos(Vector2i(x, y)))
                pts.append(Settings.get_global_pos(Vector2i(x + 1, y)))
            if tmp & LINK_POS_Y:
                pts.append(Settings.get_global_pos(Vector2i(x, y)))
                pts.append(Settings.get_global_pos(Vector2i(x, y + 1)))
    if not pts.is_empty():
        draw_multiline(pts, Settings.debug_color, 6.0)
    # linking lines
    pts.clear()
    if linking_paths.size() > 1:
        for grid_pos in linking_paths:
            pts.append(Settings.get_global_pos(grid_pos))
        draw_polyline(pts, Settings.debug_color, 2.0)


func _physics_process(delta: float) -> void:
    if unselecting:
        remove_path(Settings.get_grid_pos(get_global_mouse_position()))
        # todo caculate used path
        if OS.is_debug_build():
            remove_node(Settings.get_grid_pos(get_global_mouse_position()))
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
        for i : int in linking_paths.size() - 1:
            var from: Vector2i = linking_paths.get(i)
            var to: Vector2i = linking_paths.get(i + 1)
            _grid_data[Settings.get_grid_index(from)] |= path_diff(from, to)
            _grid_data[Settings.get_grid_index(to)] |= path_diff(to, from)
        for grid : Vector2i in linking_paths:
            update_aster_around_grid(grid)
        # todo caculate used path
        linking_paths.clear()
        line_end = Vector2i(-1, -1)
        get_viewport().set_input_as_handled()
        return
    if event is InputEventMouseMotion and path_linking:
        extend_to(Settings.get_grid_pos(get_global_mouse_position()))
        get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("unselect"):
        unselecting = true
        get_viewport().set_input_as_handled()
        return
    if event.is_action_released("unselect"):
        unselecting = false
        get_viewport().set_input_as_handled()
        return


func build_astar() -> void:
    _astar.clear()
    for x in Settings.map_grid_size.x:
        for y in Settings.map_grid_size.y:
            _astar.add_point(
                Settings.get_grid_index(Vector2i(x, y)),
                Settings.get_grid_pos(Vector2i(x, y)),
            )
            # link -x and -y
            var data := _grid_data.get(Settings.get_grid_index(Vector2i(x, y)))
            if data & LINK_NEG_X:
                _astar.connect_points(
                    Settings.get_grid_index(Vector2i(x, y)),
                    Settings.get_grid_index(Vector2i(x - 1, y)),
                )
            if data & LINK_NEG_Y:
                _astar.connect_points(
                    Settings.get_grid_index(Vector2i(x, y)),
                    Settings.get_grid_index(Vector2i(x, y - 1)),
                )


func update_aster_around_grid(grid: Vector2i) -> void:
    update_aster_link(grid, Vector2i(1, 0))
    update_aster_link(grid, Vector2i(0, 1))
    update_aster_link(grid, Vector2i(-1, 0))
    update_aster_link(grid, Vector2i(0, -1))
        

func update_aster_link(grid: Vector2i, diff: Vector2i) -> void:
    var data := _grid_data.get(Settings.get_grid_index(grid))
    var magic := path_diff(diff, Vector2i.ZERO)
    var from := Settings.get_grid_index(grid)
    var to := Settings.get_grid_index(grid + diff)
    if (data & magic) and (not _astar.are_points_connected(from, to)):
        _astar.connect_points(from, to)
        return
    if not (data & magic) and _astar.are_points_connected(from, to):
        _astar.disconnect_points(from, to)
        return


func path_diff(from: Vector2i, to: Vector2i) -> int:
    var diff := to - from
    assert(diff.length_squared() == 1)
    if diff == Vector2i(1, 0):
        return LINK_POS_X
    if diff == Vector2i(0, 1):
        return LINK_POS_Y
    if diff == Vector2i(-1, 0):
        return LINK_NEG_X
    if diff == Vector2i(0, -1):
        return LINK_NEG_Y
    return 0


func remove_path(grid: Vector2i) -> void:
    var data := _grid_data.get(Settings.get_grid_index(grid))
    if data & LINK_DEF:
        _grid_data[Settings.get_grid_index(grid)] = (data >> 4) << 4
        _grid_data[Settings.get_grid_index(grid + Vector2i(-1, 0))] \
            &= ~LINK_POS_X
        _grid_data[Settings.get_grid_index(grid + Vector2i(0, -1))] \
            &= ~LINK_POS_Y
        _grid_data[Settings.get_grid_index(grid + Vector2i(1, 0))] \
            &= ~LINK_NEG_X
        _grid_data[Settings.get_grid_index(grid + Vector2i(0, 1))] \
            &= ~LINK_NEG_Y
        update_aster_around_grid(grid)


func remove_node(grid: Vector2i) -> void:
    var id := Settings.get_grid_index(grid)
    var data := _grid_data.get(id)
    if (data & TILE_DEF) == IS_SOURCE or (data & TILE_DEF) == IS_SINK:
        assert(_path_nodes.has(id))
        _grid_data[id] &= ~TILE_DEF
        remove_child(_path_nodes.get(id))
        _path_nodes.erase(id)
        remove_path(grid)


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
    if _grid_data.get(Settings.get_grid_index(target)) & TILE_DEF:
        return false
    return true
    

func spawn_node(grid_pos: Vector2i, is_source: bool) -> void:
    if not Settings.check_grid_pos(grid_pos):
        return
    var id := Settings.get_grid_index(grid_pos)
    if not _path_nodes.has(id):
        _grid_data[id] = (_grid_data[id] >> 6) << 6
        if is_source:
            _path_nodes[id] = Source.new(grid_pos)
            _grid_data[id] |= IS_SOURCE
            print("add a source at %s" % grid_pos)
        else:
            _path_nodes[id] = Sink.new(grid_pos)
            _grid_data[id] |= IS_SINK
            print("add a sink   at %s" % grid_pos)
        # todo add rototation 
        _grid_data[id] |= LINK_POS_X
        _grid_data[Settings.get_grid_index(grid_pos + Vector2i.RIGHT)] \
            |= LINK_NEG_X
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
