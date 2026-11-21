extends Camera2D

var _screen_pos: Vector2
var _camera_pos: Vector2
var _camera_zoom: float = 1.0

var camera_log_zoom: int = 0:
    set(value):
        camera_log_zoom = clampi(
            value, 
            CAMERA_LOG_ZOOM_MIN, 
            CAMERA_LOG_ZOOM_MAX
            )
        _camera_zoom = pow(CAMERA_ZOOM_FACTOR, camera_log_zoom)
        return

const CAMERA_LOG_ZOOM_MAX: int   = 10
const CAMERA_LOG_ZOOM_MIN: int   = -10
const CAMERA_ZOOM_FACTOR:  float = 1.1
const CAMERA_ZOOM_SPEED:   float = 2.0

func _physics_process(delta: float) -> void:
    move_camera()
    zoom_camera(delta)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            camera_log_zoom += event.factor
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            camera_log_zoom -= event.factor


func move_camera() -> void:
    if Input.is_action_just_pressed("grab_move"):
        _screen_pos = get_viewport().get_mouse_position()
        _camera_pos = position
        return
    if Input.is_action_pressed("grab_move"):
        var screen_offset = _screen_pos - get_viewport().get_mouse_position()
        position = _camera_pos + screen_offset / zoom.x


func zoom_camera(delta: float) -> void:
    zoom = Vector2.ONE * move_toward(
        zoom.x,
        _camera_zoom,
        CAMERA_ZOOM_SPEED * delta * zoom.x
        )
