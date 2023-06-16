#============================================================
#    Config Dropped Items
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-18 16:13:06
# - version: 4.0
#============================================================
## 角色会掉落物品
class_name ConfigDroppedItems
extends ConfigBehavior


@export var drop_level_min: int = 0
@export var drop_level_max: int = 4


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.died, func(data):
		Log.rich(["掉落物品"], "", Color.BLUE_VIOLET)
		var list = Datas.get_level_item( drop_level_min, drop_level_max )
		var item = list.pick_random()
		Datas.pop_goods_node([item], role.global_position)
	)

