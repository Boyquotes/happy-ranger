#============================================================
#    Card Effect
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-05 22:53:12
# - version: 4.x
#============================================================
extends Control


var __init_node__ = FuncUtil.auto_inject(self)

var cards : Control
var color_rect : ColorRect
var control_effect_offset : ControlEffect_Offset
var control_effect_stretch : ControlEffect_Scale
var button : Button


func _ready():
	for card in cards.get_children():
		card.double_selected.connect(
			func(data):
				Log.info([ "选中了 ", data ])
				button.button_pressed = false
		)
	
	for card in cards.get_children():
		card.selected.connect(
			func(data):
				for child in cards.get_children():
					if child != card:
						child.set_selected(false)
		)


func exec(state: bool):
	get_tree().paused = state
	
	control_effect_offset.execute(state)
	control_effect_stretch.execute(state)
	if state:
		color_rect.color.a = 0
		create_tween().tween_property(color_rect, "color:a", 0.8, 0.5)
	else:
		create_tween().tween_property(color_rect, "color:a", 0.0, 0.3)

