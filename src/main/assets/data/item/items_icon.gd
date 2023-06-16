 #============================================================
#    Items Icon
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-15 22:59:22
# - version: 4.0
#============================================================
##  物品图标
class_name ItemIcons
extends Node2D


## 名称对应的节点
var _name_to_node_data : Dictionary = {}


#============================================================
#  自定义
#============================================================
static func get_instance() -> ItemIcons:
	return DataUtil.singleton("ItemIcons_SceneInstance", func():
		var path = ScriptUtil.get_object_script_path(ItemIcons).get_basename()
		var scene = load(path + ".tscn") as PackedScene
		var instance = scene.instantiate() as Node2D
		instance.visible = false
		NodeUtil.add_node(instance)
		
		var node_list = NodeUtil.get_all_child(instance, func(node): 
			return node is TextureRect 
		)
		for node in node_list:
			instance._name_to_node_data[node.name] = node 
		
		return instance
		
	)


static func _get_texture_rect(item_name: String) -> TextureRect:
	var instance = get_instance()
	if instance._name_to_node_data.has(item_name):
		return instance._name_to_node_data[item_name]
	return null


static func get_item_texture(item_name: String) -> Texture2D:
	var node = _get_texture_rect(item_name)
	if node:
		return node.texture
	printerr("没有 ", item_name, " 图片")
	return null

