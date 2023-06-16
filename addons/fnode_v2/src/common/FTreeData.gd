#============================================================
#  功能树中的数据
#============================================================
## 存储全部的 [FRoot] 节点中的数据
class_name FTreeData


var root : FNodeBase = null
var all_node : Array[FNodeBase] = []
var class_to_node_map : Dictionary = {}
var fname_to_node_map : Dictionary = {}



#============================================================
#  自定义
#============================================================
static func get_data() -> Dictionary:
	return DataUtil.singleton("META_FTREE_TREE_DATA_", func(): return {} )


static func instance(root: FNodeBase) -> FTreeData:
	if get_data().has(root):
		return get_data()[root] as FTreeData
	else:
		var tree_data := FTreeData.new()
		get_data()[root] = tree_data
		tree_data.root = root
		var all_child = FNodeScanner.scan_all_child_fnode(root)
		tree_data.all_node = all_child
		
		for fnode in all_child:
			if fnode is FNodeBase:
				tree_data.register_fnode(fnode)
		return tree_data

func register_fnode(fnode: FNodeBase):
	var fclass := fnode.get_script() as GDScript
	if not class_to_node_map.has(fclass):
		class_to_node_map[fclass] = []
	var list := class_to_node_map[fclass] as Array
	if not list.has(fnode):
		list.append(fnode)
		all_node.append(fnode)
	fnode.child_entered_tree.connect(func(node):
		if node is FNodeBase:
			register_fnode(node)
	)
	fnode.child_exiting_tree.connect(func(node):
		if node is FNodeBase:
			get_fnodes_by_class(node.get_script()).erase(node)
			all_node.erase(node)
	)
	
	# 添加节点映射
	var fname = str(fnode.name).to_lower().capitalize().replace(" ", "_")
	if not fname_to_node_map.has(fname):
		fname_to_node_map[fname] = []
	fname_to_node_map[fname].append(fnode)
	
	# 类映射
	while fclass != null:
		if not class_to_node_map.has(fclass):
			class_to_node_map[fclass] = []
		if not class_to_node_map[fclass].has(fnode):
			class_to_node_map[fclass].append(fnode)
		fclass = fclass.get_base_script()

func get_all_fnode() -> Array[FNodeBase]:
	return all_node

func get_first_fnode_by_class(fclass: Script) -> FNodeBase:
	var list = get_fnodes_by_class(fclass)
	return null if list.is_empty() else list[0] as FNodeBase

func get_fnodes_by_class(fclass: Script) -> Array:
	return class_to_node_map.get(fclass, []) as Array

##  获取整个 FInitTree 匹配的节点。获取 fclass 节点类 property 匹配的节点
func get_first_fnode_by_name(name: String) -> FNodeBase:
	# 获取这个类的节点列表
	var fnode_list = get_fnodes_by_name(name)
	return null if fnode_list.is_empty() else fnode_list[0] as FNodeBase

## 获取匹配这个名称的所有节点
func get_fnodes_by_name(name: String) -> Array:
	var list = []
	# 属性名转为类名格式
	var fname := name.to_lower().capitalize().replace(" ", "_")
	return fname_to_node_map.get(fname, []) as Array

