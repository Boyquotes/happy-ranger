#============================================================
#    Config Slime
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-16 22:02:04
# - version: 4.0
#============================================================
extends ConfigRole


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.died, func(data: Dictionary):
	
		role.jump(300, true)
		
	)
	
