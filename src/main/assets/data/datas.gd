#============================================================
#    Datas
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 15:03:32
# - version: 4.0
#============================================================
class_name Datas


const PATH = "res://src/main/assets/data"


static func get_item(item_name: String) -> BaseItemData:
	var path = PATH.path_join("/item_extend/" + item_name + ".tres")
	if FileAccess.file_exists(path):
		var res_item = ResourceLoader.load(path, "Resource")
		return res_item.duplicate(true)
	return null


## 获取所有物品
static func get_all_items() -> Array[BaseItemData]:
	return DataUtil.singleton("Datas_get_all_items", func():
		var list : Array[BaseItemData] = []
		var item : BaseItemData
		for name in [
			"big stick",
			"broken knife",
			"exquisite bayonet",
			"short and wide knife",
			"somewhat interesting knife",
			"sword with electric current",
			"wolf teeth stick",
			"wooden sword",
			"yaksha",
		]:
			item = ResourceLoader.load(PATH + "/item_extend/" + name + ".tres", "Resource")
			list.append(item)
			Log.info([item.get_data()])
		return list
	)


## 根据物品数据弹出物品节点列表
static func pop_goods_node(items: Array, to_position: Vector2):
	for item_data in items:
#		var item_node = NodeUtil.instance_class_scene(Item) as Item
		var item_node = NodeUtil.instance_class_scene(Goods)
		item_node.set_data(item_data.get_data())
		item_node.texture = item_data.texture 
		item_node.global_position = to_position
		NodeUtil.add_node(item_node, Engine.get_main_loop().current_scene)
		
		var angle = deg_to_rad(randfn(90, 45))
		var velocity = Vector2.LEFT.rotated( angle )
		var speed = randf_range(48, 72)
		item_node.apply_force(velocity * speed, 8)


## 获取这个功能的资源:
static func get_function(function_name: String) -> BaseFunction:
	var path = PATH.path_join("/function_extend/" + function_name) + ".tres"
	if FileAccess.file_exists(path):
		var res = ResourceLoader.load(path)
		return res.duplicate(true)
	return null


## 获取角色场景
static func get_role_scene(name: String) -> PackedScene:
	var path = "res://src/main/scene/role/player/%s/%s.tscn" % [name, name]
	return load(path)


## 获取等级列表
static func get_level_item(level: int, max_level: int = 100000) -> Array:
	var items = get_all_items()
	var list = items.filter(func(item): 
		return item.level >= level and item.level <= max_level)
	return list

