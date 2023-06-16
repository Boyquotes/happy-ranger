#============================================================
#    Message Item
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-08 00:08:40
# - version: 4.x
#============================================================
extends Control


@export
var text: String = "" :
	set(v):
		text = v
		if label == null: await ready
		label.text = text


@onready 
var main = $main
@onready 
var label = %label


func execute(duration: float):
	main.position.x = self.size.x
	create_tween().tween_property(main, "position:x", 0.0, duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	
	self.custom_minimum_size.y = 0
	create_tween().tween_property(self, "custom_minimum_size:y", main.size.y, duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)

