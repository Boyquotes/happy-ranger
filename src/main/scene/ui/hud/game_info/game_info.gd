#============================================================
#    Game Info
#============================================================
# - datetime: 2023-02-26 18:34:05
#============================================================
extends MarginContainer


@onready var time_elapsed : Label = %time_elapsed



func _on_time_elapsed_timer_timeout() -> void:
	time_elapsed.text = Time.get_time_string_from_unix_time(int(Time.get_ticks_msec() / 1000.0))
