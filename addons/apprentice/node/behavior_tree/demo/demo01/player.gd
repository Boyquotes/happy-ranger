#============================================================
#    Icon
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 00:19:59
# - version: 4.0
#============================================================
extends Sprite2D


@export var move_speed : float = 100.0


func attack():
	Log.info(["attack"])


func attack_exit():
	Log.info(["attack over"])


func move(direction):
	position += move_speed * direction * get_physics_process_delta_time()

