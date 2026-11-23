extends Node

var add_time: bool = true
var formatted_msg := "> %s [%-*s] %-*s: %s"
var level_fill: int = 5
var from_fill:  int = 20

var date: String = ""

func _log_out(
    print_func: Callable,
    level: StringName,
    from: StringName,
    msg: StringName,
) -> void:
    if add_time and date != Time.get_date_string_from_system():
        date = Time.get_date_string_from_system()
        info("Update date %s" % date, "LogFormatter")
    print_func.call(formatted_msg % [
        Time.get_time_string_from_system() if add_time else "",
        level_fill,
        level,
        from_fill,
        from,
        msg
    ])


func info(msg: StringName, from: StringName = "UNKNOWN") -> void:
    _log_out(print, "INFO", from, msg)
