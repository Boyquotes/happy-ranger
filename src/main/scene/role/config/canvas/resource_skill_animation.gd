#============================================================
#    Resource Skill Animation
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 23:05:50
# - version: 4.x
#============================================================
class_name SkillAnimationConfig
extends Resource


@export var skill_name: String
@export_enum("Ready", "Before", "Execute", "After", "Cooldown", "None")
var play_stage : int = 1
@export var play_animation: String = ""


var last_id : StringName

var role : Role :
	set(v):
		if role != v:
			role = v
			
			if last_id:
				role.listener.cancel(last_id)
			
			last_id = role.listener.listen_skill(skill_name, func(stage, data):
				if stage == play_stage:
					if play_animation:
						role.play(play_animation)
			)
			role.tree_exiting.connect(role.listener.cancel.bind(last_id), Object.CONNECT_ONE_SHOT)


