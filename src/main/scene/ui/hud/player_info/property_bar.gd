#============================================================
#    Health Bar
#============================================================
# - datetime: 2023-02-25 16:57:37
#============================================================
@tool
class_name PropertyBar
extends HBoxContainer


# 模板
@export_node_path("TextureProgressBar")
var template_node : NodePath
@export_range(0, 10, 0.01, "or_greater")
var value : float = 1.0:
	set(v):
		value = v
		_update_health()
@export_range(0, 10, 0.01, "or_greater")
var max_value : float = 1.0 :
	set(v):
		max_value = v
		_update_health()


var _health_node_list : Array[TextureProgressBar] = []


func _ready():
	_update_health()


var _updated = false
## 更新显示
func _update_health():
	if _updated:
		return
	
	if not is_inside_tree(): await ready
	
	_updated = true
	await get_tree().process_frame
	_updated = false
	
	if template_node == ^"":
		printerr("没有设置 template_node 属性")
		push_error("没有设置 template_node 属性")
		return
	var template = get_node_or_null(template_node)
	if template == null:
		return
	
	var total = len(_health_node_list)
	var diff = max_value - total
	if diff > 0:
		for i in diff:
			var node = template.duplicate() as TextureProgressBar
			_health_node_list.append(node)
			add_child(node)
			node.visible = true
		
	else:
		for i in abs(diff):
			var node = _health_node_list[total - 1 - i] as Control
			if node:
				node.visible = false
	
	for child in _health_node_list:
		child.visible = true
	
	var temp = value
	for i in range(1, max_value+1):
		var node = _health_node_list[i-1] as TextureProgressBar
		node.value = temp
		temp -= 1.0
	

