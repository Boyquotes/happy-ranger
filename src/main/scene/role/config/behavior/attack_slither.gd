#============================================================
#    Attack Slither
#============================================================
# - datetime: 2023-03-02 20:39:44
# - version: 4.x
#============================================================
# 攻击时会向前冲刺一点距离
class_name ConfigAttackSlither
extends ConfigBehavior


@export_range(0, 100, 0.01, "or_greater")
var distance : float = 32.0
@export var duration : float = 0.15



#(override)
func _set_enabled(value):
	enabled = value



#(override)
func _actor_ready():
	
	# 攻击技能准备施放前的移动向量
	var vector = DataUtil.get_ref_data(Vector2(0,0))
	get_listener().listen_skill_started(Const.ATTACK, func():
		vector.value = role.move_controller.get_last_move_vector()
	)
	
	# 如果攻击时按着向前移动，则会移动一点距离
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if enabled:
			if stage == Const.Stages.EXECUTE:
				if vector.value.x != 0:
					Log.debug()
					print("向前偏移滑行一小段距离")
					
					var velocity = Vector2(vector.value).normalized() * distance
					var attenuation = duration / distance / get_physics_process_delta_time()
					FuncUtil.apply_force(velocity, attenuation, 
						func(state: FuncApplyForceState):
							role.move_controller.move_vector(state.get_velocity())
					, role, duration)
		
	)
