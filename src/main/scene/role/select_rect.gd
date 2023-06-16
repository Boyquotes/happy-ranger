#============================================================
#    Select Rect
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-16 09:15:23
# - version: 4.0
#============================================================

class_name SelectRoleRect
extends ReferenceRect


signal selected


func _gui_input(event):
	if InputUtil.is_click_left(event):
		self.selected.emit()
		


