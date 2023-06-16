#============================================================
#    Create Items
#============================================================
# - datetime: 2023-03-01 23:35:12
# - version: 4.x
#============================================================
## 在点击位置创建几个物品
class_name CreateItems
extends Node2D


@export
var enabled : bool = true


func _unhandled_input(event: InputEvent) -> void:
	if InputUtil.is_click_left(event):
		if enabled:
			pass
#			# 爆炸性创建物品
#			GoodsFactory.create_explosive_item(
#				func(): return get_global_mouse_position(),
#				func(): return randf_range(5, 8),
#				func(): return randf_range(24, 32),
#				func(): return ItemDataBase.get_random().duplicate(true),
#				func(node): 
#					var t = randf_range(0, 0.3)
#					await get_tree().create_timer( t ).timeout
#					get_tree().current_scene.add_child(node)
#			)

