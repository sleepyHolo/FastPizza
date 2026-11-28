class_name DispatchingSystem
extends System

var _query_only_path_finder: PathSystem.PathFinder

var no_path_idxs: Array[Vector2i]
# {(idx, color): path}
var cached_paths: Dictionary[Vector2i, TruckPath]


func _exit_tree() -> void:
    super()
    get_tree().node_added.disconnect(_on_scene_tree_node_added)


func _on_path_system_init(
    _grid_data: PackedByteArray,
    _path_finder: PathSystem.PathFinder
) -> void:
    _query_only_path_finder = _path_finder


func _on_map_def_ready() -> void:
    # build links
    get_tree().node_added.connect(_on_scene_tree_node_added)
    var nodes := get_tree().get_nodes_in_group(&"sources")
    nodes.append_array(get_tree().get_nodes_in_group(&"sinks"))
    for node : Node in nodes:
        _on_scene_tree_node_added(node)


func _on_scene_tree_node_added(node: Node) -> void:
    if node is Sink:
        (node as Sink).demand.connect(_on_sink_demand)
        return
    return


func _on_sink_demand(
    idx: int,
    color: int = 0,
) -> void:
    if not _query_only_path_finder.visitable(idx, color):
        no_path_idxs.append(Vector2i(idx, color))
        return
    call_truck(idx, color)


func _connect_signals(system: System) -> void:
    if system is PathSystem:
        system.init.connect(_on_path_system_init)
        return


func call_truck(idx: int, color: int = 0) -> void:
    var truck := Truck.new()
    truck.running = true
    get_truck_path(idx, color).add_child(truck)


func get_truck_path(idx: int, color: int = 0) -> TruckPath:
    if cached_paths.has(Vector2i(idx, color)):
        return cached_paths.get(Vector2i(idx, color))
    var path := TruckPath.new()
    path.path = _query_only_path_finder.query_vector(idx, color)
    path.rebuild_curve()
    add_child(path)
    return path


class TruckPath extends Path2D:
    
    var path: Array[Vector2i] = []
    
    func rebuild_curve(
    ) -> void:
        if curve == null:
            curve = Curve2D.new()
        curve.clear_points()
        for grid : Vector2i in path:
            curve.add_point(Settings.get_global_pos(grid))
        return
