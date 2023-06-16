#============================================================
#    Card
#============================================================
# - datetime: 2023-02-26 21:25:23
#============================================================
class_name Card
extends MarginContainer


signal selected(data: Dictionary)
signal double_selected(data: Dictionary)


@onready var coin_label: Label = %coin_label
@onready var item_name_label: Label = %item_name_label
@onready var control_click_border = $board/ControlClickBorder


var _data : Dictionary


func set_data(data: Dictionary):
	item_name_label.text = str( data.get("name", "[ Item Name ]") )
	coin_label.text = str( data.get("coin", 0) )
	_data = data


func set_selected(v: bool):
	control_click_border.visible = v
	if control_click_border.visible:
		selected.emit(_data)


func _on_control_click_border_visibility_changed():
	set_selected(control_click_border.visible)


func _on_board_gui_input(event):
	if InputUtil.is_double_click(event):
		double_selected.emit(_data)
