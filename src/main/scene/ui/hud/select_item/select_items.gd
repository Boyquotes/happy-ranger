#============================================================
#    Select Items
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 16:04:57
# - version: 4.0
#============================================================
## 选择项列表
class_name SelectItems
extends VBoxContainer


# 选中选项
signal selected(data)


## 物品数据对应的动画节点
var _data_to_node_map : Dictionary = {}


#============================================================
#  内置
#============================================================
func _ready():
	# 进入/离开商店
	GameEvent.ShowSelectItem.listen(func(data: Dictionary, callback: Callable = Callable()):
		execute(data, callback, true, data.get(Const.NAME, "物品数据名"))
	)
	GameEvent.HideSelectItem.listen(func(data, callback: Callable = Callable()):
		execute(data, callback, false)
	)
	# 进入/离开物品
	GameEvent.EnterItem.listen(func(goods: Goods):
		var message : String = goods.get_data().get(Const.NAME, "物品名")
		var click_callback : Callable = func():
			goods.queue_free()
			return true
		execute(goods, click_callback, true, message)
	)
	GameEvent.ExitItem.listen(func(goods: Goods):
		execute(goods, Callable(), false)
	)


#============================================================
#  自定义
#============================================================
## 执行操作选项，播放动画
##[br]
##[br][code]data[/code]  数据内容
##[br][code]click_callback[/code]  点击时的回调，这个回调需要返回一个 bool 值用以判断是否可以点击操作成功
##[br][code]state[/code]  弹出或收缩状态
##[br][code]message[/code]  按钮消息内容
func execute(data, click_callback: Callable = Callable(), state: bool = true, message : String = "其中一个选项...") -> void:
	var id = data
	if not state and not _data_to_node_map.has(id):
		return
	
	# 抽屉节点
	var drawer_node = DataUtil.get_value_or_set(_data_to_node_map, id, func():
		var drawer_node = DrawerControl.new()
		drawer_node.from_direction = DrawerControl.RIGHT
		add_child(drawer_node)
		
		var select_item := NodeUtil.instance_class_scene(SelectItem) as SelectItem
		select_item.set_label(message)
		select_item.size.y = 28
		select_item.selected.connect(func():
			self.selected.emit(data)
			var result = click_callback.call()
			assert(result is bool, "必需要返回一个 bool 类型的值")
			if result:
				# 点击后缩放消失
				create_tween() \
					.tween_property(drawer_node, "custom_minimum_size:y", 0, 0.1) \
					.finished.connect(func():
						drawer_node.queue_free()
						_data_to_node_map.erase(id) ,
					)
		)
		
		drawer_node.set_actor(select_item)
		return drawer_node
	) as DrawerControl
	
	if state:
		# 展出
		drawer_node.get_parent().move_child(drawer_node, -1)
		drawer_node.execute(true, 0.15)
		
	else:
		# 缩回
		drawer_node.execute(false, 0.15)

