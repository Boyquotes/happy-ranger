#============================================================
#    Group Items
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 14:04:16
# - version: 4.0
#============================================================
@tool
class_name SceneManagementGroupItems
extends ItemList


signal selected(group: String)
signal ready_remove_group(state: Dictionary)


const ALL_ITEM = "[ALL]"


var _groups : Dictionary = {}
var _custom_item : Array = []
var _tr = TranslationUtil.load_traslation_file("res://addons/scene_management/assets/translation/tra.csv")

@onready var popup_menu : PopupMenu = %PopupMenu
@onready var add_custom_group_window = %add_custom_group_window
@onready var add_custom_groups : SceneManagementAddGroups = %add_custom_groups as SceneManagementAddGroups


#============================================================
#  内置
#============================================================
func _init():
	self.item_selected.connect(func(index): 
		self.selected.emit(get_item_text(index)) 
	)


func _ready():
	clear()
	add_item(ALL_ITEM)
	
	# 自定义分组
	var data = SceneManagement.get_data("group_items", {})
	var custom_items : Array = data.get("custom_items", [])
	for group_item in custom_items:
		add_group(group_item, true)
	data['custom_items'] = _custom_item
	add_custom_groups.init_groups(custom_items)
	add_custom_group_window.hide()
	add_custom_group_window.close_requested.connect(func(): add_custom_group_window.hide())
	
	# 翻译
	var lang = EditorUtil.get_editor_language()
	_tr.set_default_locale(lang)
	
	# 右键菜单
	popup_menu.clear()
	popup_menu.add_item(_tr.get_message("add_group"))
	popup_menu.add_separator()
	popup_menu.add_item(_tr.get_message("remove"))


func _gui_input(event):
	if InputUtil.is_click_right(event):
		popup_menu.popup(Rect2i(get_global_mouse_position(), Vector2i(0,0) ))



#============================================================
#  自定义
#============================================================
##  添加组别
##[br]
##[br][code]group[/code]  组名
##[br][code]custom[/code]  是否是定义添加的。没有这个组别的场景，组别列表中也会存在这个分组
func add_group(group: String, custom: bool = false):
	if group.strip_edges() != "":
		if not _groups.has(group):
			_groups[group] = null
			add_item(group)
		if custom:
			_custom_item.append(group)


func remove_group(group: String):
	if _groups.has(group) and not group in _custom_item:
		_groups.erase(group)
		for i in item_count:
			if get_item_text(i) == group:
				remove_item(i)
				break


#============================================================
#  连接信号
#============================================================
func _on_popup_menu_index_pressed(index):
	var menu_text : String = popup_menu.get_item_text(index)
	if menu_text == _tr.get_message("add_group"):
		add_custom_groups.clear()
		add_custom_group_window.popup_centered()
		
	elif menu_text == _tr.get_message("remove"):
		if not get_selected_items().is_empty():
			var idx = get_selected_items()[0]
			var group = get_item_text(idx)
			remove_group(group)
		


func _on_add_custom_groups_added(group):
	add_group(group)


func _on_add_custom_groups_removed(group):
	if add_custom_group_window.visible:
		var state : Dictionary = {
			"enable": false,
			"group": group,
		}
		self.ready_remove_group.emit(state)
		if state.enable:
			remove_group(group)
