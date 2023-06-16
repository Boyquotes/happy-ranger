#============================================================
#    Config Take Damage
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-16 21:53:56
# - version: 4.0
#============================================================
## 角色受到伤害时执行的功能
class_name ConfigTakeDamage
extends ConfigBehavior


## 僵硬时间
@export_range(0, 1, 0.001, "or_greater", "hide_slider") 
var stiffness_time : float = 1.0


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.took_damage, func(data: Dictionary):
		if (enabled 
			and stiffness_time > 0 
			and data.get(Const.DAMAGE, 0) > 0
		):
			role.make_uncontrol(stiffness_time, TimerExtension.TimeType.MAX)
		
	)

