#============================================================
#    Bt Node Util
#============================================================
# - datetime: 2023-02-05 15:53:25
#============================================================
## 行为树节点工具
class_name BTNodeUtil


##  添加节点
##[br]
##[br][code]node[/code]  添加的节点对象
##[br][code]name[/code]  节点名称
##[br][code]type[/code]  节点类型
##[br][code]parent_node[/code]  父节点
##[br][code]readable_name[/code]  是否以具有可读性的名称进行添加节点
static func add_node(node: Node, name: String, type: String, parent_node: Node, readable_name: bool) -> void:
	name = name.c_escape()
	if readable_name:
		node.name = (name 
			if name
			else type
		)
	parent_node.add_child(node, readable_name)
	if parent_node.owner:
		node.owner = parent_node.owner
	else:
		node.owner = parent_node


##  获取正在执行的节点
##[br]
##[br][code]root[/code]  根节点
static func get_running_nodes(root: Node) -> Array[Node]:
	
	var runnings : Array[Node] = []
	var add_running = func(node: Node):
		if node is BTNode:
			var running_node = node.get_child(node.task_idx)
			runnings.push_back(running_node)
			return true
		return false
	
	var scan_child = func(node: Node, callback: Callable):
		for child in node.get_children():
			if add_running.call(child):
				callback.call(child, callback)
	
	scan_child.call(root, scan_child)
	
	return runnings

