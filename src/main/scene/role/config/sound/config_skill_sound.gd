#============================================================
#    Config Skill Sound
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-09 00:13:59
# - version: 4.x
#============================================================
## 施放技能时播放声音
class_name ConfigSkillSound
extends ConfigSound


@export var skill_name: String
@export_enum("Ready", "Before", "Execute", "After", "Cooldown", "None")
var play_stage : int = 1
@export_enum("Ready", "Before", "Execute", "After", "Cooldown", "None")
var stop_stage : int = 3


#(override)
func _actor_ready():
	super._actor_ready()
	assert(skill_name, str(role) + "没有设置播放的技能的声音")
	
	get_listener().listen_skill(skill_name, func(stage, data):
		if stage == play_stage:
			play()
		elif stage == stop_stage:
			stop()
	)
