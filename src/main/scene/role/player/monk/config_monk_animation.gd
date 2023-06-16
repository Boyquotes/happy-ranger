#============================================================
#    Config Animation
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-08 01:43:18
# - version: 4.x
#============================================================
extends ConfigRole


#(override)
func _actor_ready():
	super._actor_ready()
	
	role.anim_canvas.played.connect(
		func(animation: StringName):
			if animation == &"walk":
				role.anim_canvas.get_target().offset.y = -1
			else:
				role.anim_canvas.get_target().offset.y = -2
		
	)
	

