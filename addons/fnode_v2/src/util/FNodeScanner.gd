#============================================================
#    F Node Scanner
#============================================================
# - datetime: 2022-09-13 13:40:19
#============================================================

class_name FNodeScanner


class Scanner:
	
	static func scan(node: Node, list: Array, condition: Callable):
		list.append_array(node.get_children().filter(condition))
		for child in node.get_children():
			scan(child, list, condition)


static func scan_all_child_fnode(parent: FNodeBase) -> Array[FNodeBase]:
	var list : Array[FNodeBase] = []
	Scanner.scan(parent, list, (func(node: Node):
		return node is FNodeBase
	))
	return list
