#============================================================
#    Plugin
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 12:41:09
# - version: 4.0
#============================================================
@tool
extends EditorPlugin


var SCENE_MANAGEMENT_SCENE = preload("scene/scene_management.tscn")


var main : SceneManagement
var float_dialog : Window = Window.new()

var floated : bool = false
var first_visible : bool = true


#============================================================
#  内置
#============================================================
func _ready():
	# 编辑器启动不到5秒时
#	if Time.get_ticks_msec() < 20000:
#		await Engine.get_main_loop().create_time(1).timeout
	
	# 主窗口
	main = SCENE_MANAGEMENT_SCENE.instantiate()
	main.floated.connect(_floated)
	main.hide()
	
	# 浮动窗口
	float_dialog.title = SceneManagement.PLUGIN_MAIN_NAME
	float_dialog.size = Vector2(500, 350)
	float_dialog.close_requested.connect(func():
		main.float_button.button_pressed = false
	)
	float_dialog.visible = false
	get_editor_interface() \
		.get_base_control() \
		.add_child(float_dialog)


func _exit_tree():
	float_dialog.queue_free()
	main.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if first_visible:
		get_editor_interface() \
			.get_editor_main_screen() \
			.add_child(main)
		first_visible = false
	
	if not floated:
		main.visible = visible


func _get_plugin_name():
	return SceneManagement.PLUGIN_MAIN_NAME


func _get_plugin_icon():
	return get_editor_interface() \
		.get_base_control() \
		.get_theme_icon("PackedScene", "EditorIcons")


#============================================================
#  连接信号
#============================================================
func _floated(state: bool):
	if floated != state:
		floated = state
		if floated:
			main.get_parent().remove_child(main)
			float_dialog.add_child(main)
			float_dialog.popup_centered()
			main.size.x = float_dialog.size.x - 2
			main.size.y = float_dialog.size.y
			
			main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			main.size_flags_vertical = Control.SIZE_EXPAND_FILL
			main.set_anchors_preset(Control.PRESET_FULL_RECT)
			
		else:
			float_dialog.hide()
			if main.float_button.button_pressed:
				main.float_button.button_pressed = false
			
			main.get_parent().remove_child(main)
			get_editor_interface() \
				.get_editor_main_screen() \
				.add_child(main)
			
			if main.is_inside_tree():
				EditorUtil.set_main_screen_editor(SceneManagement.PLUGIN_MAIN_NAME)
		
		

