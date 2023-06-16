#============================================================
#    Config Behavior Group
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-16 23:53:25
# - version: 4.0
#============================================================
## 当前节点开启关闭时，所有 [ConfigBehavior] 节点的 [member enabled] 属性
class_name ConfigBehaviorGroup
extends ConfigBehavior


var __init_update_child_enabled__ = (func():
	(func():
		child_entered_tree.connect(_update_node_enabled)
	).call_deferred()
).call()


#(override)
func _set_enabled(value):
	enabled = value
	
	if not is_inside_tree(): 
		await self.ready
	
	for child in get_children():
		_update_node_enabled(child)


# 更新节点 enabled 属性
func _update_node_enabled(node: Node):
	if node is ConfigBehavior:
		node.enabled = enabled

