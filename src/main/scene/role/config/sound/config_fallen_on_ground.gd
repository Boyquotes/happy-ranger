#============================================================
#    Config Fallen On Ground
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-09 22:24:59
# - version: 4.x
#============================================================
## 落在面上
class_name ConfigFallenOnGround
extends ConfigSound


var last = DataUtil.get_ref_data(false)


func _physics_process(delta):
	if role.is_on_floor_only():
		if (not last.value 
			and role.get_last_slide_collision() != null
			and role.get_last_slide_collision().get_collider() is TileMap
		):
			play()
		last.value = true
	else:
		last.value = false

