#============================================================
#    F Inject Property
#============================================================
# - datetime: 2022-09-15 23:22:30
#============================================================

##  注入属性。[FNode] 节点的属性，在自动注入属性时会排除这些属性，不进行注入。
class_name FInjectProperty


## 开启自动注入
var auto_inject : bool = true
## 排除的属性
var exclude_propertys : Array[String] = []
## 包含的属性（如果为空，则默认为全部的属性）
var include_propertys : Array[String] = []


#============================================================
#  SetGet
#============================================================
func get_include_propertys() -> Array:
	return include_propertys


func get_exclude_propertys() -> Array:
	return exclude_propertys


#============================================================
#  自定义
#============================================================
##  添加注入属性时排除的属性
func add_exclude_propertys(propertys) -> FInjectProperty:
	if propertys is String:
		exclude_propertys.append(propertys)
	elif propertys is Array:
		for property in propertys:
			add_exclude_propertys(property)
	return self


## 添加只进行注入的属性
func add_include_propertys(propertys) -> FInjectProperty:
	if propertys is String:
		include_propertys.append(propertys)
	elif propertys is Array:
		for property in propertys:
			add_include_propertys(property)
	return self


## 根据注册的属性设置属性
##[br]
##[br][code]fnode[/code]  设置的属性
##[br][code]property_to_node_path_map[/code]  节点路径对应的属性名
##[br][code]from_root_get_node[/code]  这个属性在 @onready 下使用，传入 [FRoot] 类型的节点，也就是 root 属性值
##将会从这个节点中获取 node_path 节点，如果为 null，则默认为 fnode 节点
static func set_property_by_register(
	fnode: FNodeBase, 
	property_to_node_path_map: Dictionary, 
	from_root_get_node: FNodeBase = null
):
	# 节点进入场景后执行
	FuncUtil.execute_or_enter_tree(
		fnode, 
		func():
			var node_path
			for property in property_to_node_path_map:
				node_path = property_to_node_path_map[property]
				if property in fnode:
					FuncUtil.execute_or_enter_tree(
						fnode, 
						func():
							var node = FCacheNode.get_node_or_register(fnode if from_root_get_node == null else from_root_get_node, node_path)
							if node != null:
								fnode.set(property, node)
					)
	)


## 设置对应节点名称的属性节点，在节点 enter_tree 时进行设置
##[br]
##[br][code]fnode[/code]  [FNode]节点
##[br][code]node_path_list[/code]  节点路径列表
##[br][code]node_path_by_parent[/code]  这个属性在 @onready 下使用，传入 [FRoot]
##类型的节点，也就是 root 属性值，将会从这个节点中获取 node_path 节点，如果不传入则默认为 fnode
##参数这个节点
static func set_property_by_node_name(
	fnode:FNodeBase, 
	node_path_list:PackedStringArray, 
	node_path_by_parent: FNodeBase = null
):
	var data = {}
	for node_path in node_path_list:
		data[node_path.trim_prefix("%")] = node_path.get_file()
	set_property_by_register(fnode, data, node_path_by_parent)

