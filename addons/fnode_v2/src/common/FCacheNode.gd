#============================================================
#    F Cache Node
#============================================================
# - datetime: 2022-12-08 21:31:26
#============================================================
## [FNode] 缓存节点
##
##缓存获取 这个 FRoot 树中下的节点
##[br]示例注册节点：
##[codeblock]
##var register_node = [
##    FCacheNode.register(self, '%property_management'),
##    FCacheNode.register(self, '%skill_actuator'),
##    FCacheNode.register(self, 'state_machine'),
##]
##[/codeblock]
##[br]
##[br]获取节点，按照节点路径获取：
##[codeblock]
##FCacheNode.get_node(self, '%property_management')
##FCacheNode.get_node(self, 'state_machine')
##[/codeblock]
class_name FCacheNode


#============================================================
#  自定义
#============================================================
static func get_cache_data():
	return DataUtil.singleton("_FCacheNode_get_data", func(): return {} )


## 注册这个名称的节点到这个 FRoot 数据中，如果节点还未添加到场景中，则会在进入场景时进行获取添加
## 以 root 节点为准进行获取
static func register(fnode: FNodeBase, node_path: NodePath):
	FuncUtil.execute_or_enter_tree( fnode,
		func():
			var node = fnode.root.get_node_or_null(node_path)
			if node == null:
				printerr("  -> ", fnode.root, " 节点没有 ", node_path, " 路径的节点")
				return
			# 如果是root节点则直接赋值，如果不是则获取 root 节点
			var root := fnode.root as FNodeBase
			var data = get_cache_data()
			if data.has(root):
				data[root][node_path] = node
			else:
				data[root] = {}
				data[root][node_path] = node
				root.tree_exited.connect( func(): data.erase(root) )
	)


## 注册节点列表，以 root 节点为准进行获取
static func register_nodes(fnode: FNodeBase, node_names: PackedStringArray):
	for node_path in node_names:
		register(fnode, node_path)


## 获取这个这个 FNode 的这个名称的节点
static func get_node(fnode: FNodeBase, node_path: NodePath) -> Node:
	return get_cache_data().get(fnode.root, {}).get(node_path)


## 获取节点，如果没有节点，则进行注册节点并获取，以 root 节点为准进行获取
static func get_node_or_register(fnode: FNodeBase, node_path: NodePath) -> Node:
	var node = get_node(fnode, node_path)
	if node:
		return node
	else:
		register(fnode, node_path)
		return get_node(fnode, node_path)

