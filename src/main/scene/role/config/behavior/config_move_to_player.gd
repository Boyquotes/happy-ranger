#============================================================
#    Config Move To Player
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-12 16:04:29
# - version: 4.x
#============================================================
## 移动到 Player 的位置
class_name ConfigMoveToPlayer
extends ConfigBehavior


var dir = DataUtil.get_ref_data(Vector2(0,0))


func _ready():
	set_physics_process(enabled)


#(override)
func _set_enabled(value):
	enabled = value
	set_physics_process(false)


#(override)
func _actor_ready():
	super._actor_ready()
	var timer = NodeUtil.create_timer(0.1, self, func():
		dir.value = MathUtil.N.direction_to(role, Global.player)
		dir.value.y = 0
	, true)


func _physics_process(delta):
	if enabled and MathUtil.N.distance_x(role, Global.player) > 4:
		role.move_direction(dir.value)

