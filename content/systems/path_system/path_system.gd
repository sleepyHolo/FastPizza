class_name PathSystem
extends System

signal init

var _grid_data: PackedByteArray
var _path_nodes: Dictionary[int, PathNode] = {}

var path_linking: bool = false
var linking_paths : Array[Vector2i] = []
var line_end := Vector2i(-1, -1)

var unselecting: bool = false

var path_finder: PathFinder

const LINK_DEF   := 0b1111
const LINK_POS_X := 0b0001
const LINK_POS_Y := 0b0010
const LINK_NEG_X := 0b0100
const LINK_NEG_Y := 0b1000

const TILE_DEF   := 0b110000
const IS_SOURCE  := 0b010000
const IS_SINK    := 0b100000


func _exit_tree() -> void:
    super()
    get_tree().node_added.disconnect(_on_scene_tree_node_added)


func _ready() -> void:
    _grid_data.resize(Settings.get_map_size())
    path_finder = PathFinder.new()
    path_finder.init_build(
        _grid_data,
        2,
    )


func _draw() -> void:
    if not OS.is_debug_build():
        return
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


func _process(delta: float) -> void:
    path_finder.update()


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
        commit_path()
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


func _on_map_def_ready() -> void:
    # build links
    get_tree().node_added.connect(_on_scene_tree_node_added)
    var nodes := get_tree().get_nodes_in_group(&"sources")
    nodes.append_array(get_tree().get_nodes_in_group(&"sinks"))
    for node : Node in nodes:
        _on_scene_tree_node_added(node)
    
    init.emit(
        _grid_data,
        path_finder,
    )


func _on_scene_tree_node_added(node: Node) -> void:
    if node is not PathNode:
        return
    node = node as PathNode
    var link := node.node_link as int
    _grid_data[Settings.get_grid_index(node.grid_pos)] |= link
    if link & 0b11:
        _grid_data[Settings.get_grid_index(node.grid_pos + link_to(link))] \
            |= (link << 2)
    else:
        _grid_data[Settings.get_grid_index(node.grid_pos + link_to(link))] \
            |= (link >> 2)
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


func link_to(link: int) -> Vector2i:
    if link == LINK_POS_X:
        return Vector2i(1, 0)
    if link == LINK_POS_Y:
        return Vector2i(0, 1)
    if link == LINK_NEG_X:
        return Vector2i(-1, 0)
    if link == LINK_NEG_Y:
        return Vector2i(0, -1)
    return Vector2i.ZERO


func commit_path() -> void:
    if linking_paths.size() < 2:
        linking_paths.clear()
        return
    for i : int in linking_paths.size() - 1:
        var from: Vector2i = linking_paths.get(i)
        var to: Vector2i = linking_paths.get(i + 1)
        _grid_data[Settings.get_grid_index(from)] |= path_diff(from, to)
        _grid_data[Settings.get_grid_index(to)] |= path_diff(to, from)
    linking_paths.clear()
    # todo caculate used path
    path_finder.rebuild()


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
        path_finder.rebuild()


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
    

func spawn_node(
    grid_pos: Vector2i, 
    is_source: bool,
    source_color: int = 0,
) -> void:
    if not Settings.check_grid_pos(grid_pos):
        return
    var id := Settings.get_grid_index(grid_pos)
    if not _path_nodes.has(id):
        _grid_data[id] = (_grid_data[id] >> 6) << 6
        if is_source:
            _path_nodes[id] = Source.new()
            _grid_data[id] |= IS_SOURCE
            path_finder.add_source(id, source_color)
        else:
            _path_nodes[id] = Sink.new()
            _grid_data[id] |= IS_SINK
        _path_nodes[id].grid_pos = grid_pos
        add_child(_path_nodes[id])
        path_finder.rebuild()
        LogFormatter.debug(
            "add a %s at %s" % ["source" if is_source else "sink", grid_pos],
            "PathSystem",
        )
    return


class PathFinder extends RefCounted:
    
    var _read_only_grid_data: PackedByteArray
    var colored_sources: Array[SourceDef] = []
    
    # visiting_queue: (grid_idx, color)
    var visiting_index := PackedInt32Array()
    var visiting_color := PackedByteArray()
    var rebuilding: bool = false
    
    # ring buffer
    var head: int = 0
    var peak: int = 0
    var usage: int = 0
    var time_usage_us: int = 0
    
    
    func _init() -> void:
        visiting_index.resize(Settings.ring_buffer_size)
        visiting_color.resize(Settings.ring_buffer_size)
    
    
    func _reset_buff() -> void:
        head = 0
        peak = 0
        usage = 0
        time_usage_us = 0
    
    
    func _write(index: int, color: int) -> void:
        var write_idx := (head + usage) % Settings.ring_buffer_size
        visiting_index[write_idx] = index
        visiting_color[write_idx] = color
        usage += 1
        if usage > peak:
            peak = usage
    
    
    func _read() -> Vector2i:
        if usage <= 0:
            return Vector2i(-1, -1)
        var read_idx = head % Settings.ring_buffer_size
        var out := Vector2i(
            visiting_index[read_idx],
            visiting_color[read_idx],
        )
        head += 1
        usage -= 1
        return out
    
    
    func get_linked_points(idx: int) -> Array[int]:
        var x := idx % Settings.map_size_max.x
        var y := floori(float(idx) / Settings.map_size_max.x)
        var data := _read_only_grid_data.get(idx)
        var out : Array[int] = []
        if data & LINK_POS_X:
            out.append(Settings.get_grid_index(Vector2i(x + 1, y)))
        if data & LINK_POS_Y:
            out.append(Settings.get_grid_index(Vector2i(x, y + 1)))
        if data & LINK_NEG_X:
            out.append(Settings.get_grid_index(Vector2i(x - 1, y)))
        if data & LINK_NEG_Y:
            out.append(Settings.get_grid_index(Vector2i(x, y - 1)))
        return out
    
    
    func init_build(grid_data: PackedByteArray, color_num: int) -> void:
        _read_only_grid_data = grid_data
        colored_sources.clear()
        for i in color_num:
            var tmp := SourceDef.new()
            tmp.color_idx = i
            colored_sources.append(tmp)
        rebuild()
    
    
    func rebuild() -> void:
        LogFormatter.info("rebuilding...", "PS.PathFinder")
        rebuilding = true
        _reset_buff()
        for source_def : SourceDef in colored_sources:
            source_def.reset()
            for source in source_def.sources:
                _write(source, source_def.color_idx)
        return
    
    
    func update(caculate_limit: int = INT32_MAX) -> void:
        if not rebuilding:
            return
        var step := 0
        var tmp_time_start := Time.get_ticks_usec()
        while usage > 0 and step < caculate_limit:
            var cur := _read()
            for idx : int in get_linked_points(cur.x):
                if idx == Settings.DIRTY_DATA_INDEX:
                    continue
                if colored_sources.get(cur.y).parent.has(idx):
                    continue
                colored_sources.get(cur.y).parent[idx] = cur.x
                _write(idx, cur.y)
                step += 1
        time_usage_us += Time.get_ticks_usec() - tmp_time_start
        if usage == 0:
            rebuilding = false
            LogFormatter.smart_info(
                "rebuild ended.",
                "PS.PathFinder",
                "time usage       : %s us" % time_usage_us,
                "buffer peak usage: %s" % peak,
            )
        return
    
    
    func add_source(idx: int, color: int) -> void:
        colored_sources.get(color).add_source(idx)    
    
    
    func remove_source(idx: int, color: int) -> void:
        colored_sources.get(color).remove_source(idx)
    
    
    func _visited(grid: int, source_color: int) -> bool:
        return colored_sources.get(source_color).visited(grid)
    
    
    func visitable(sink: int, source_color: int) -> bool:
        if _visited(sink, source_color):
            return true
        if rebuilding:
            # todo use a better? way
            update()
            return _visited(sink, source_color)
        return false
    
    
    func query(
        sink: int,
        source_color: int,
        reverse: bool = true,
    ) -> Array[int]:
        if not visitable(sink, source_color):
            return []
        var tmp: Array[int] = []
        var cur := sink
        while colored_sources[source_color].parent[cur] != SourceDef.SOURCE:
            tmp.append(cur)
            cur = colored_sources[source_color].parent[cur]
        if reverse:
            tmp.reverse()
        return tmp
    
    
    func query_vector(
        sink: int,
        source_color: int,
        reverse: bool = true,
    ) -> Array[Vector2i]:
        var tmp: Array[Vector2i] = []
        for idx : int in query(sink, source_color, reverse):
            tmp.append(Vector2i(
                idx % Settings.map_size_max.x,
                floori(float(idx) / Settings.map_size_max.x),
            ))
        return tmp


class SourceDef extends RefCounted:
    
    const SOURCE := -1
    
    var color_idx: int
    var parent: Dictionary[int, int] = {}
    var sources := PackedInt32Array()
    
    
    func add_source(idx: int) -> void:
        if sources.has(idx):
            return
        sources.append(idx)    
    
    
    func remove_source(idx: int) -> void:
        if not sources.has(idx):
            return
        sources.erase(idx)
    
    
    func reset() -> void:
        parent.clear()
        for source : int in sources:
            parent[source] = SOURCE
    
    
    func visited(idx: int) -> bool:
        return parent.has(idx)
