#============================================================
#    Left Select Item
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 16:01:49
# - version: 4.0
#============================================================
## 左侧选择钮项
class_name SelectItem
extends Control


## 选中按钮
signal selected


var __init_node__ = FuncUtil.inject_by_unique(self, "_")

var _control_scale : ControlEffect_Scale
var _hide_button : ControlEffect_Scale
var _label : RichTextLabel
var _select_button : Button


#============================================================
#  SetGet
#============================================================
func set_label(text: String):
	FuncUtil.ready_call(self, func():
		_label.text = text
		_control_scale.execute(true)
	)


func get_button() -> Button:
	return %select_button


#============================================================
#  内置
#============================================================
func _ready():
	_select_button.pivot_offset = _select_button.size / 2.0


#============================================================
#  连接信号
#============================================================
func _on_select_button_pressed():
	_hide_button.execute(true)
	EffectUtil.fade_in_out(self, 0.1, 0)
	self.selected.emit()

