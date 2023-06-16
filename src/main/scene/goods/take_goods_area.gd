#============================================================
#    Take Goods Area
#============================================================
# - datetime: 2023-02-26 19:04:48
#============================================================
class_name TakeGoodsArea
extends Area2D


signal took_item(data: Dictionary)


@export var host : Role


func _ready() -> void:
	if host == null:
		if get_parent() is Role:
			host = get_parent()
	if host == null:
		Log.error([ owner, "没有设置 host 属性！" ])
	
	AreaUtil.connect_entered(self, func(node: Node):
		if node is Goods:
			GameEvent.EnterItem.send(node)#.send_enter_item(node)
	)
	AreaUtil.connect_exited(self,func(node: Node):
		if node is Goods:
			GameEvent.ExitItem.send(node)#.send_exit_item(node)
	)


