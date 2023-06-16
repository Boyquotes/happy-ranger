#============================================================
#    Creator
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 15:27:27
# - version: 4.0
#============================================================
class_name CreatorFunction
extends BaseTargetObjectOrPoint


## 已创建节点
signal created(node: Node)


## 创建的节点的场景
@export var scene : PackedScene
## 创建到的位置
@export var create_position: Vector2
## 创建的节点的旋转弧度
@export var rotation : float = 0.0


#(override)
func _execute():
	var callback : Callable = func():
		var inst = scene.instantiate()
		Engine.get_main_loop().current_scene.add_child(inst)
		if inst is CanvasItem:
			inst.global_rotation = rotation
			inst.global_position = create_position 
		self.created.emit(inst)
	
	execute_once(
		callback
		, 0
		, self.emit_finish
	)
