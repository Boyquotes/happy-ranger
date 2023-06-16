#============================================================
#    Config Repel
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-16 00:30:55
# - version: 4.0
#============================================================
## 击退
class_name ConfigRepel
extends ConfigBehavior


@export_range(0, 1, 0.001)
var probability : float = 0.3:
	set(v):
		if probability != v:
			probability = v
			random_probability.update_probability(probability)


var random_probability := RandomMinimumProbability.new(probability)



#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.attacked, func(data: Dictionary):
		if not enabled:
			return
		
		if (data.get(Const.TYPE) == Const.DamageType.NORMAL 
			and random_probability.check()
		):
			var target = data.get(Const.TARGET) as Role
			if (is_instance_valid(target) 
				and target.get_property(Const.HEALTH, 0) > 0
			):
				var distance = 8
				var duration = 0.3
				
				var speed = distance / duration
				var dir = MathUtil.N.direction_x(role, target)
				var velocity = dir * speed * get_physics_process_delta_time()
				FuncUtil.execute_fragment_process(duration, func():
					target.velocity = velocity 
					target.move_and_slide()
				, Timer.TIMER_PROCESS_PHYSICS, target)
		
	)
