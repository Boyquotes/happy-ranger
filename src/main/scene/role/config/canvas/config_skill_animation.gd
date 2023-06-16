#============================================================
#    Config Skill Animation
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 22:58:41
# - version: 4.x
#============================================================
## 技能播放动画
class_name ConfigSkillAnimation
extends ConfigCanvas


@export var animations : Array[ResSkillAnimation] = []


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen_all_skill(func(skill_name: StringName, stage, data):
		var list = animations \
			.filter(func(item): return item.get_skill_name() == skill_name and item.stage == stage ) \
			.map(func(item): return item.get_animation() )
		if list.size() > 0:
			role.play(list.pick_random())
		
	)

