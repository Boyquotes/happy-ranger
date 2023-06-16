#============================================================
#    Global Player
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-29 13:52:14
# - version: 4.0
#============================================================
extends FNode


#(override)
func _actor_ready():
	super._actor_ready()
	Global.player = actor
	Log.prompt(["控制的角色：", actor])


