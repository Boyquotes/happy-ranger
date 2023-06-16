#============================================================
#    Plugin
#============================================================
# - datetime: 2022-10-01 07:51:21
#============================================================

##  底部收藏栏

@tool
extends EditorPlugin


const PANEL_SCENE = preload("src/panel/bottom_panel.tscn")
const PANEL_NAME = "Collection"


var bottom_panel : Control


#============================================================
#  内置
#============================================================
func _ready():
	bottom_panel = PANEL_SCENE.instantiate()
	bottom_panel.custom_minimum_size.y = 200
	add_control_to_bottom_panel(bottom_panel, PANEL_NAME)
	bottom_panel.reloaded.connect(func():
		if is_instance_valid(bottom_panel):
			remove_control_from_bottom_panel(bottom_panel)
		print("准备重新加载 %s 插件" % [EditorUtil.get_plugin_name(self)])
		EditorUtil.reload_plugin(self)
		print("加载完成")
	)
	bottom_panel.hide()
#	make_bottom_panel_item_visible(bottom_panel)


func _exit_tree():
	if is_instance_valid(bottom_panel):
		remove_control_from_bottom_panel(bottom_panel)

