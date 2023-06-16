#============================================================
#    Scene Management
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 11:38:27
# - version: 4.0
#============================================================
## 场景管理
@tool
class_name SceneManagement
extends MarginContainer


## 是否浮动
signal floated(state: bool)


## 插件上的名称
const PLUGIN_MAIN_NAME = "SceneManage"
## 数据KEY
const CONFIG_DATA_META_KEY = "SceneManagement_config_data"
## 配置数据的文件路径
const CONFIG_FILE_PATH = "res://.godot/scene_management/config_data.gdata"
## 场景管理节点单例
const NODE_SINGLETON = "scene_management_singleton"


var __init_node__ = FuncUtil.inject_by_path_list(
	self, 
	["%group_items", "%scene_items", "%add_groups", "%right_menu", "%group_dialog"
		, "%rescan", "%prompt_message", "%float_button", "%background_panel", "%preview_viewport"
	]
)
var group_items : SceneManagementGroupItems
var scene_items :  SceneManagementSceneItems
var add_groups : SceneManagementAddGroups
var group_dialog : ConfirmationDialog
var right_menu : PopupMenu
var rescan : Button
var prompt_message : Label
var float_button : Button
var background_panel : Panel
var preview_viewport : SubViewportContainer

var _config_data : Dictionary = get_config_data()
var _last_item_data : SceneManagementSceneItems.SceneItemData
var _tr = TranslationUtil.load_traslation_file("res://addons/scene_management/assets/translation/tra.csv")


#============================================================
#  SetGet
#============================================================
## 获取配置数据
static func get_config_data() -> Dictionary:
	return DataUtil.singleton(CONFIG_DATA_META_KEY, func(): 
		FileUtil.if_not_exists_make_dir(CONFIG_FILE_PATH.get_base_dir())
		if FileUtil.file_exists(CONFIG_FILE_PATH):
			return FileUtil.read_as_bytes_to_var(CONFIG_FILE_PATH)
		return {} 
	)

## 保存配置数据
static func save_config_data() -> void:
	var data = get_config_data()
	FileUtil.if_not_exists_make_dir(CONFIG_FILE_PATH.get_base_dir())
	if FileUtil.write_as_bytes(CONFIG_FILE_PATH, data):
		print("[ SceneManagement ] 已保存数据 ", CONFIG_FILE_PATH)

## 获取配置数据某个子配置
static func get_data(key: StringName, default: Dictionary) -> Dictionary:
	var data = get_config_data()
	if data.has(key) and typeof(data[key]) != TYPE_NIL:
		return data[key]
	else:
		data[key] = default
		return default

## 重新设置数据
static func reset_data(key: StringName, data: Dictionary):
	get_config_data()[key] = data

static func get_meta_data() -> SceneManagement:
	return Engine.get_meta(NODE_SINGLETON)



#============================================================
#  内置
#============================================================
func _enter_tree():
	background_panel = %background_panel
	if get_parent() is Window:
		background_panel.self_modulate.a = 0.9
	else:
		background_panel.self_modulate.a = 0.1
	
	Engine.set_meta(NODE_SINGLETON, self)


func _ready():
	if get_parent() is SubViewport:
		return
	
	group_dialog.hide()
	prompt_message.visible = (scene_items.get_item_count() == 0)
	
	# 刷新图标
	rescan.icon = EditorUtil.get_editor_theme_icon("Reload")
	rescan.theme_changed.connect(func():
		rescan.icon = EditorUtil.get_editor_theme_icon("Reload")
	)
	
	# 菜单
	_init_menu()


func _exit_tree():
	if Engine.is_editor_hint() and not get_parent() is SubViewport:
		save_config_data()


#============================================================
#  自定义
#============================================================
func _init_menu() -> void:
	# 加载翻译 CSV 文件
	var lang = EditorUtil.get_editor_language()
	_tr.set_default_locale(lang)
	
	# 添加右键菜单项
	right_menu.clear()
	for i in [_tr.get_message("group"), "---", _tr.get_message("remove")]:
		if i.left(1) != "-": 
			right_menu.add_item(i)
		else:
			# 开头是 “-” 时则是分隔符
			right_menu.add_separator()
	
	# 点击菜单
	right_menu.index_pressed.connect(func(index):
		var menu_name : String = right_menu.get_item_text(index)
		
		if menu_name == _tr.get_message("group"):
			var groups : Array = scene_items.get_group_by_path(_last_item_data.path)
			add_groups.init_groups( groups )
			group_dialog.popup_centered()
		
		elif menu_name == _tr.get_message("remove"):
			if _last_item_data:
				for item in scene_items.get_selected_item_list():
					scene_items.remove_item(item.get_file_path())
		
	)



#============================================================
#  连接信号
#============================================================
func _on_group_items_selected(group: String):
	if group == SceneManagementGroupItems.ALL_ITEM:
		for data in scene_items.get_all_data():
			data['node'].visible = true
	else:
		for data in scene_items.get_all_data():
			data['node'].visible = data['group'].has(group)


func _on_add_groups_added(group: String):
	for selected_item in scene_items.get_selected_item_list():
		scene_items.add_group(selected_item.get_file_path(), group)
	group_items.add_group(group)


func _on_add_groups_removed(group: String):
	for selected_item in scene_items.get_selected_item_list():
		scene_items.remove_group(selected_item.get_file_path(), group)
	if not scene_items.has_group_item(group):
		group_items.remove_group(group)


func _on_scene_items_newly_added_item(path: String, item):
	var path_groups : Array = scene_items.get_group_by_path(path)
	for group in path_groups:
		group_items.add_group(group)
	
	if not group_items.get_selected_items().is_empty():
		var idx = group_items.get_selected_items()[0]
		if idx > 0:
			var selected_group = group_items.get_item_text(idx)
			scene_items.add_group(path, selected_group)
	
	prompt_message.visible = false


func _on_scene_items_removed_item(path: String):
	var path_groups : Array = scene_items.get_group_by_path(path)
	await Engine.get_main_loop().process_frame
	for group in path_groups:
		if not scene_items.has_group_item(group):
			group_items.remove_group(group)
	prompt_message.visible = (scene_items.get_item_count() == 0)


func _on_scene_items_right_click(path: String):
	_last_item_data = SceneManagementSceneItems.to_class_data(scene_items.get_data(path))
	right_menu.popup(Rect2i(get_global_mouse_position(), Vector2(0, 0)))


func _on_rescan_pressed():
	for item in scene_items.get_all_item_node():
		item.reload()
	

func _on_float_toggled(button_pressed):
	self.floated.emit(button_pressed)


func _on_group_items_ready_remove_group(state: Dictionary):
	var group = state.group
	if not scene_items.has_group_item(group):
		state.enable = true

