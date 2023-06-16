#============================================================
#    Scene Item
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 11:33:21
# - version: 4.0
#============================================================
@tool
extends MarginContainer


signal select_changed(state: bool)
signal double_clicked
signal left_clicked
signal right_clicked


var __init_node__ = FuncUtil.inject_by_path_list(
	self, ["%texture_rect", "%border", "%path_label", "%editor_desc", "%sub_viewport"]
)
var texture_rect : TextureRect
var path_label : Label
var editor_desc : Label
var border : Panel
var sub_viewport : SubViewport

var _path : String :
	set(v):
		_path = v
		_scene = load(_path)
var _scene : PackedScene
var _selected : bool = false: set = set_selected


@onready var style := border["theme_override_styles/panel"] as StyleBoxFlat



#============================================================
#  SetGet
#============================================================
func set_file_path(path: String):
	self._path = path
	if not is_inside_tree(): await ready
	path_label.text = path.get_file()
	if FileAccess.file_exists(path):
		if path == "res://addons/scene_management/scene/scene_management.tscn":
			return
			
		TextureUtil.preview_scene(load(path), func(texture: ImageTexture):
			texture_rect.texture = texture
		)
		
	self.tooltip_text = path
	
	var desc = EditorUtil.get_packed_scene_root_property_value(_scene, "editor_description")
	editor_desc.text = desc if desc != null else ""

func get_file_path() -> String:
	return _path

## 根节点的类型
func get_root_node_type() -> StringName:
	return _scene.get_state().get_node_type(0)

func is_selected() -> bool:
	return _selected

func set_selected(v: bool) -> void:
	if _selected != v:
		_selected = v
		if style:
			style.bg_color = (EditorUtil.get_editor_setting_property("text_editor/theme/highlighting/completion_selected_color")
				if _selected 
				else Color(1, 1, 1, 0.0)
			)
		self.select_changed.emit(_selected)


#============================================================
#  内置
#============================================================
func _ready():
	# 边框显示相关
	border.visible = true
	hide_border()
	mouse_entered.connect(show_border)
	mouse_exited.connect(hide_border)
	
	_selected = false
	
	# 边距
	for dir in ["left", "top", "right", "bottom"]:
		self["theme_override_constants/margin_" + dir] = 8
	


func _gui_input(event):
	if InputUtil.is_double_click(event):
		self.double_clicked.emit()
	elif InputUtil.is_click_left(event):
		set_selected(not _selected)
		self.left_clicked.emit()
	elif InputUtil.is_click_right(event):
		self.right_clicked.emit()


#============================================================
#  内置
#============================================================
## 重新加载数据
func reload() -> void:
	set_file_path(_path)

## 显示边框
func show_border():
	# 强调颜色
	var accent_color = EditorUtil.get_editor_setting_property("interface/theme/accent_color")
	style["border_color"] = accent_color

## 隐藏边框
func hide_border() -> void:
	style["border_color"] = Color(1, 1, 1, 0)

