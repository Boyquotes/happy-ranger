#============================================================
#    Config Jump
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-10 23:24:14
# - version: 4.x
#============================================================
class_name ConfigJump
extends ConfigSound


## 如果跳跃附带数据的跳跃类型为这个类型，则播放声音
##[br]比如主动跳跃和被动跳跃等区别，加以区分，否则全都播放就太乱了
@export var type : String = "" 


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.jumped, func(height, data: Dictionary):
		var type = data.get(Const.TYPE, "")
		if type == self.type:
			play()
	)
	
