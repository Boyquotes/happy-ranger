#============================================================
#    Item Texture Container
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-11 00:29:27
# - version: 4.0
#============================================================
## 物品图片容器
@tool
class_name ItemTextureContainer
extends MarginContainer


@export var texture : Texture:
	set(v): 
		texture = v
		FuncUtil.sync_property(func(): %image.texture = v)
@export var bg_color: Color = Color(0.113, 0.113, 0.113):
	set(v): 
		bg_color = v
		FuncUtil.sync_property(func(): %background["theme_override_styles/panel"]['bg_color'] = v)
@export var outer_border_color : Color = Color(0.6, 0.6, 0.6):
	set(v):
		outer_border_color = v
		FuncUtil.sync_property(func(): %outer_border["theme_override_styles/panel"]['border_color'] = v)
@export var inner_border_color : Color = Color(0.701, 0.701, 0.701):
	set(v):
		inner_border_color = v
		ControlUtil.set_style()
		FuncUtil.sync_property(func(): %inner_border["theme_override_styles/panel"]['border_color'] = v)

