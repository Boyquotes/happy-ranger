#============================================================
#    Player Info
#============================================================
# - datetime: 2023-02-26 18:33:05
#============================================================
## 角色信息
##
## 处理当前 UI 上显示的角色的数据
extends MarginContainer


@onready var health_bar = %health_bar as PropertyBar
@onready var weapons = %weapons


var _id_list : Dictionary = {}
# 生命发生改变时
var _update_health : Callable = func(previous, current):
	health_bar.max_value = Global.player.get_property(Const.HEALTH_MAX, 0)
	health_bar.value = Global.player.get_property(Const.HEALTH, 0)


#============================================================
#  SetGet
#============================================================
## 获取没有占用品栏的item容器
func get_empty_item_container():
	for item_container in weapons.get_children():
		if not item_container.has_data():
			return item_container
	return null


#============================================================
#  内置
#============================================================
func _init():
	# 角色发生改变时
	Global.player_changed.connect(func(previous: Role, player: Role):
		cancel_listen(previous)
		if is_instance_valid(player):
			if not player.is_inside_tree(): await player.ready
			listen(player)
	)
	


#============================================================
#  自定义
#============================================================
func register_id(id) -> void:
	_id_list[id] = null


##  取消监听 Player
func cancel_listen(player: Role) -> void:
	if is_instance_valid(player):
		for id in _id_list:
			player.listener.disconnect_listen(id)

##  监听 Player 数据
func listen(player: Role) -> void:
	if is_instance_valid(player):
		var listener : RoleListener = player.role_listener
		register_id(listener.listen_property( Const.HEALTH_MAX, _update_health ))
		register_id(listener.listen_property( Const.HEALTH, _update_health ))
		
		register_id(listener.listen_all_item(func(item_id, previous: Dictionary, data: Dictionary):
			# 物品是武器类型时
			if data.get(Const.TYPE) == Const.ItemType.WEAPON:
				if previous.is_empty():
					# 如果上次数据是空的，则是新物品
					var item_container = get_empty_item_container()
					if item_container:
						item_container.set_data(data)
					
				else:
					# 物品数据发生改变
					pass
					
			
		))
		
		health_bar.max_value = player.get_property(Const.HEALTH_MAX, 1)
		health_bar.value = player.get_property(Const.HEALTH, 1)
		

