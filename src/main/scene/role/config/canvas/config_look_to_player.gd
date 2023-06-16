#============================================================
#    Config Look To Player
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-08 01:17:18
# - version: 4.x
#============================================================
## 自动更新方向，面向到 Player
class_name ConfigLookToPlayer
extends ConfigCanvas


#(override)
func _actor_ready():
	var timer = NodeUtil.create_timer(0.1, self, func():
		if role.get_state() == Const.States.NORMAL and Global.player:
			var dir = MathUtil.N.direction_to(role, Global.player)
			_update_direction(dir)
	, true)
	timer.one_shot = false
	
	get_listener().listen_state(Const.States.NORMAL, func(previous, data):
		var dir = MathUtil.N.direction_to(role, Global.player)
		_update_direction(dir)
	)


## 更新面向朝向
func _update_direction(direction: Vector2):
	if direction.x != 0:
		direction.x = sign(direction.x)
		direction.y = 1
		role.anim_canvas.set_flip(direction)

