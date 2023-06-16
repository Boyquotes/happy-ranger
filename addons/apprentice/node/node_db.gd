#============================================================
#    Node DB
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 12:56:42
# - version: 4.x
#============================================================
## 场景节点中的对象进行记录
##
##用于方便获取对应类型的节点。例如
##[codeblock]
### 获取所有 Area2D 类型的节点
##NodeDB.get_nodes_by_class(Area2D)
### 获取第一个名称为 player 的节点
##NodeDB.get_first_node_by_name("player")
##[/codeblock] 
##
class_name NodeDB
extends Node


## 新的节点
##[br]
##[br][code]node[/code]  新增的节点
##[br][code]type[/code]  节点类型。比如：[code]Node[/code]，[code]Node2D[/code]
##类值，这个值是类名是类值，比如 [code]type[/code] 信号参数的值为 [Node]，即 [code]type == Node[/code]，
## [code]type!="Node"[/code] 或者为自定义脚本类资源对象
signal newly_node(node)
## 移除掉的节点
##[br]
##[br][code]_class[/code]  移除的节点
##[br][code]return[/code]  节点类型
signal removed_node(node)


## 扫描的节点的根节点
@export var root : Node :
	set(v):
		assert(v != null, "root 属性不能设置为 null")
		if root != v:
			if root:
				# 断开上次的数据
				_remove_node_data(root)
			root = v
			_record_node_data(root)
@export var record_all_child : bool = true

# 这个类的继承链数据
var _extends_class_link_map : Dictionary = singleton_dict("NodeDB_memeber_script_extends_link_map")
# 类对应的节点列表
var _class_to_nodes_map : Dictionary = {}
# 名称对应的节点列表
var _name_to_nodes_map : Dictionary = {}
# 是否正在退出
var _program_is_exiting : bool = false


#============================================================
#  SetGet
#============================================================
##  获取这个对象的继承的类列表
func get_extends_class_objet_link_by_object(object: Object) -> Array:
	return get_value_or_set(_extends_class_link_map
	, object.get_script() if object.get_script() else object.get_class()
	, func():
		var list : Array = []
		if object.get_script():
			list.append_array(Array(get_extends_script_link(object.get_script())).map(func(path):
				return load(path)
			))
		list.append_array(Array(get_extends_base_link(object.get_class())).map(func(_class):
			return get_class_object(_class)
		))
		return list
	)


## 获取这个类的节点列表
##[br]
##[br][code]_class[/code]  这个值可以是类或类名字符串，如：[code]"Node"[/code] 或 [code]Node[/code]
func get_nodes_by_class(_class) -> Array[Node]:
	if _class is String or _class is StringName:
		_class = get_class_object(_class)
	var id = _get_id(_class)
	return _class_to_nodes_map.get(id, Array([], TYPE_OBJECT, "Node", null))


##  获取这个节点名称的节点列表
##[br]
##[br][code]node_name[/code]  节点名称
func get_nodes_by_name(node_name: StringName) -> Array[Node]:
	return _name_to_nodes_map.get(node_name, Array([], TYPE_OBJECT, "Node", null))


##  获取这个类的第一个节点
func get_first_node_by_class(_class) -> Node:
	var list = get_nodes_by_class(_class)
	if list.size() > 0:
		return list[0]
	return null


##  获取这个节点名的第一个节点
func get_first_node_by_name(node_name: StringName) -> Node:
	var list = get_nodes_by_name(node_name)
	if list.size() > 0:
		return list[0]
	return null


#============================================================
#  内置
#============================================================
func _ready():
	if root == null:
		root = self

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# 如果关闭程序，则不断开连接
		self._program_is_exiting = true


#============================================================
#  自定义
#============================================================
func _record_node_data(node: Node) -> void:
	if (not is_instance_valid(node) 
		or node.tree_exiting.is_connected(self._remove_node_data)
	):
		return
	
	# 连接信号
	node.tree_exiting.connect(self._remove_node_data.bind(node))
	if record_all_child:
		node.child_entered_tree.connect(self._record_node_data)
	
	# 这个名称的节点列表
	var name_to_node_list : Array = get_value_or_set(_name_to_nodes_map, node.name, func(): return Array([], TYPE_OBJECT, "Node", null))
	name_to_node_list.append(node)
	# 重命名时
	var last_list : Array = [name_to_node_list]
	node.renamed.connect(func():
		# 从之前的列表中移除
		last_list[0].erase(node)
		
		# 添加到这个列表中
		last_list[0] = get_value_or_set(self._name_to_nodes_map, node.name, func(): return Array([], TYPE_OBJECT, "Node", null))
		last_list[0].append(node)
	)
	
	# 这个类型的节点列表
	var _classes = get_extends_class_objet_link_by_object(node)
	for _class in _classes:
		var id = _get_id(_class)
		var class_to_node_list = get_value_or_set(_class_to_nodes_map, id, func(): return Array([], TYPE_OBJECT, "Node", null))
		class_to_node_list.append(node)
		self.newly_node.emit(node)
	
	# 获取下级子节点进行记录
	if record_all_child:
		if not node.is_inside_tree():
			await node.tree_entered
		for child in node.get_children():
			_record_node_data(child)


func _remove_node_data(node: Node) -> void:
	if (_program_is_exiting 
		or not is_instance_valid(node)
		or not node.tree_exiting.is_connected(self._remove_node_data)
		or not is_instance_valid(self) 
	):
		return
	
	# 断开连接
	node.tree_exiting.disconnect(self._remove_node_data)
	if node.child_entered_tree.is_connected(self._record_node_data):
		node.child_entered_tree.disconnect(self._record_node_data)
	
	# 这个名称的节点列表
	var name_to_node_list : Array = get_value_or_set(_name_to_nodes_map, node.name, func(): return Array([], TYPE_OBJECT, "Node", null))
	name_to_node_list.erase(node)
	
	# 从这个类型的节点列表移除
	var _classes = get_extends_class_objet_link_by_object(node)
	for _class in _classes:
		var id = _get_id(_class)
		var class_to_node_list = get_value_or_set(_class_to_nodes_map, id, func(): return Array([], TYPE_OBJECT, "Node", null))
		class_to_node_list.erase(node)
		self.removed_node.emit(node)
	
	# 移除子节点
	for child in node.get_children():
		_remove_node_data(child)



#============================================================
#  其他
#============================================================
func _get_id(data):
	return hash(data)

##  获取 [Dictionary] 类型的单例数据
func singleton_dict(meta_key: StringName, default: Dictionary = {}) -> Dictionary:
	if Engine.has_meta(meta_key):
		return Engine.get_meta(meta_key)
	else:
		Engine.set_meta(meta_key, default)
		return default


## 获取字典的值，如果没有，则获取并设置默认值
##[br]
##[br][code]dict[/code]  获取的字典
##[br][code]key[/code]  key 键
##[br][code]not_exists_set[/code]  没有则返回值设置这个值。这个回调方法返回要设置的数据
func get_value_or_set(dict: Dictionary, key, not_exists_set: Callable):
	if dict.has(key) and not typeof(dict[key]) == TYPE_NIL:
		return dict[key]
	else:
		dict[key] = not_exists_set.call()
		return dict[key]


##  获取扩展脚本链（扩展的所有脚本）
##[br]
##[br][code]script[/code]  Object 对象或脚本
##[br][code]return[/code]  返回继承的脚本路径列表
func get_extends_script_link(script: Script) -> Array:
	var list = []
	while script:
		if FileAccess.file_exists(script.resource_path):
			list.push_back(script.resource_path)
		script = script.get_base_script()
	return list


##  获取基础类型继承链类列表
##[br]
##[br][code]_class[/code]  基础类型类名。可以是：类名称，节点对象或脚本对象，获取到这个象的基类
##[br][code]return[/code]  返回基础的类名列表
func get_extends_base_link(_class) -> Array:
	if _class is String or _class is StringName:
		pass
	elif _class is Script:
		_class = _class.get_instance_base_type()
	elif _class is Object:
		_class = _class.get_class()
	else:
		assert(false, "错误的数据类型")
	
	var c = _class
	var list = []
	while c != "":
		list.append(c)
		c = ClassDB.get_parent_class(c)
	return list


##  获取这个类名的类对象。比如将 "Node" 字符串转为 [Node] 这种 [GDScriptNativeClass] 类型的数据
##[br]
##[br][code]_class_name[/code]  类名称
func get_class_object(_class_name: StringName):
	var name_to_class_map : Dictionary = singleton_dict("NodeDB_get_class_object")
	return get_value_or_set(name_to_class_map, _class_name, func():
		var script = GDScript.new()
		script.source_code = "var type = " + _class_name
		if script.reload() == OK:
			var obj = script.new()
			name_to_class_map[_class_name] = obj.type
			return name_to_class_map[_class_name]
		else:
			push_error("错误的类名：", _class_name)
		return null
	)

