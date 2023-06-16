#============================================================
#    Config Skill Pause Time
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-25 01:16:14
# - version: 4.0
#============================================================
## 技能停顿时间
##
## 施放一个技能后会全部技能暂时不能施放，需要停顿一点时间才能再次施放，防止连续施放技能
class_name ConfigSkillPauseTime
extends ConfigBehavior


@export var pause_time : float = 1.0


# 标记技能是否之前执行过
var _skill_finished := {}


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	# 施放技能时全能暂停施放时间
	var last_time = DataUtil.get_ref_data(pause_time)
	get_listener().listen_all_skill(func(skill_name: StringName, stage: int, data: Dictionary):
		if not enabled:
			return
		
		if stage == Const.Stages.EXECUTE:
			_skill_finished[skill_name] = true
			role.unable_cast.incr()
			last_time.value = pause_time
		elif stage == Const.Stages.AFTER:
			unpause(skill_name, last_time.value)
	)
	
	get_listener().listen_all_skill_ended(func(skill_name):
		unpause(skill_name, last_time.value)
	)


## 解除停顿
func unpause(skill_name: String, time: float) -> void:
	if _skill_finished[skill_name]:
		get_tree().create_timer(time).timeout.connect(func():
			_skill_finished[skill_name] = false
			role.unable_cast.decr()
		)

