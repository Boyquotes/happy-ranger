#============================================================
#    Operating Panel
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-05 21:43:04
# - version: 4.x
#============================================================
class_name OperatingPanel
extends Control


@onready var control_effect_stretch = $ControlEffect_Stretch
@onready var control_effect_offset = $ControlEffect_Offset


#============================================================
#  自定义
#============================================================
func popup():
	control_effect_offset.execute(true)
	control_effect_stretch.execute(true)


func packup():
	control_effect_offset.execute(false)
	control_effect_stretch.execute(false)

