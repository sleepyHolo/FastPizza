extends Node2D

@export var cell_size := Vector2i(32, 32)   # 单个格子像素
@export var half_cells := Vector2i(40, 25)  # 原点向左右/上下各画多少格
@export var line_color := Color(1, 1, 1, 0.18)
@export var axis_color := Color(1, 0.6, 0.2, 0.7)

func _ready() -> void:
    z_index = -10
    z_as_relative = false

func _draw() -> void:
    var hx := float(half_cells.x * cell_size.x)
    var hy := float(half_cells.y * cell_size.y)

    var pts := PackedVector2Array()
    # 竖线
    for i in range(-half_cells.x, half_cells.x + 1):
        var x := float(i * cell_size.x)
        pts.append(Vector2(x, -hy))
        pts.append(Vector2(x,  hy))
    # 横线
    for j in range(-half_cells.y, half_cells.y + 1):
        var y := float(j * cell_size.y)
        pts.append(Vector2(-hx, y))
        pts.append(Vector2( hx, y))

    draw_multiline(pts, line_color)

    # 原点坐标轴，方便肉眼定位 (0,0)
    draw_line(Vector2(-hx, 0), Vector2(hx, 0), axis_color, 2.0, true)
    draw_line(Vector2(0, -hy), Vector2(0, hy), axis_color, 2.0, true)
