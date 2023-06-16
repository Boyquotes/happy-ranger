#============================================================
#    Config Animation
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 23:09:59
# - version: 4.x
#============================================================
## 配置飞行角色的动画
class_name ConfigFlyAnimation
extends ConfigCanvas


@export var animation : String = "walk"


#(override)
func _actor_ready():
	super._actor_ready()
	
	role.play(animation)
	get_listener().listen_all_state(func(previous, current, data):
		if current == Const.States.NORMAL:
			role.play(animation)
	)
	

