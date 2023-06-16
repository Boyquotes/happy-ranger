#============================================================
#    Res Skill Animation
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-30 20:25:55
# - version: 4.0
#============================================================
# 播放动画的配置资源
class_name ResSkillAnimation
extends Resource


## 监听的技能名称
@export var skill_name: StringName
## 技能执行到这一阶段时开始播放动画
@export_enum("Ready", "Before", "Execute", "After", "Cooldown", "None")
var stage : int = 1
## 播放动画
@export var animation: StringName


var last_id : StringName

var role : Role :
	set(v):
		if role != v:
			role = v
			
			if last_id:
				role.listener.cancel(last_id)
			
			last_id = role.listener.listen_skill(skill_name, func(_stage, data):
				if stage == _stage:
					role.play(animation)
			)
			role.tree_exiting.connect(role.listener.cancel.bind(last_id), Object.CONNECT_ONE_SHOT)

func get_skill_name() -> StringName:
	return skill_name

func get_animation() -> StringName:
	return animation


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		pass
		

