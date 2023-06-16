#============================================================
#    Add Groups
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 22:45:19
# - version: 4.0
#============================================================
@tool
class_name SceneManagementAddGroups
extends MarginContainer


signal added(group: String)
signal removed(group: String)


const ITEM = preload("add_group_item.tscn")


@onready var group_line_edit = %group_line_edit
@onready var group_items = %group_items


var _enabled_emit_added_signal : bool = true


#============================================================
#  SetGet
#============================================================
func get_groups() -> Array[String]:
	var list : Array[String] = []
	for child in group_items.get_children():
		list.append(child.get_label())
	return list


#============================================================
#  自定义
#============================================================
func init_groups(item_list: Array):
	for child in group_items.get_children():
		child.queue_free()
	_enabled_emit_added_signal = false
	for group in item_list:
		add_group(group)
	_enabled_emit_added_signal = true


func add_group(group: String):
	var item_node = ITEM.instantiate()
	group_items.add_child(item_node)
	item_node.set_label(group)
	item_node.removed.connect(func(): self.removed.emit(group) )
	if _enabled_emit_added_signal:
		self.added.emit(group)


func clear():
	for child in group_items.get_children():
		child.remove()


#============================================================
#  连接信号
#============================================================
func _on_add_items_pressed():
	if group_line_edit.text.strip_edges() == "":
		return
	add_group(group_line_edit.text)
	group_line_edit.text = ""


func _on_group_line_edit_text_submitted(new_text: String):
	if new_text.strip_edges() == "":
		return
	add_group(new_text)
	group_line_edit.text = ""
