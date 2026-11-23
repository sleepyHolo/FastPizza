extends Node

var add_time: bool = true
var formatted_msg := "> %s [%-*s] %-*s: %s"
var level_fill: int = 5
var from_fill:  int = 20

var tail_msg_indent: StringName = &"      "

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


func debug(
    msg: StringName,
    from: StringName = "UNKNOWN",
    ...args: Array
) -> void:
    _log_out(print, "DEBUG", from, msg)
    for arg : Variant in args:
        print(tail_msg_indent, arg)


func smart_info(
    msg: StringName,
    from: StringName = "UNKNOWN",
    ...debug_msgs: Array
) -> void:
    if not OS.is_debug_build():
        info(msg, from)
        return
    # debug
    var tmp: Array = [msg, from]
    tmp.append_array(debug_msgs)
    debug.callv(tmp)
