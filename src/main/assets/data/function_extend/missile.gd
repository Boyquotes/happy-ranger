#============================================================
#    Missile
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 15:38:17
# - version: 4.0
#============================================================
## 投射物
class_name MissileFunction
extends CreatorFunction


## 创建的投射物数据。可以进行修改数据以进行数据控制
signal created_missile_data(state: Dictionary)


## 移动向量
@export var velocity : Vector2


#(override)
func _execute():
	self.created.connect(func(node: Node):
		if duration == 0:
			node.queue_free()
			push_warning("duration 属性值为 0，创建的节点将会被立即删除")
		
		elif duration > 0:
			Engine.get_main_loop().create_timer(duration).timeout.connect(node.queue_free)
		
		if not node.is_queued_for_deletion():
			var data : Dictionary = {
				"node": node,
				"velocity": velocity,
			}
			
			var callback : Callable
			if node is CharacterBody2D:
				callback = func(): 
					node.velocity = data.velocity
					node.move_and_slide()
				
			elif node is PhysicsBody2D:
				callback = func(): 
					node.move_and_collide(data.velocity) 
				
			elif node is CanvasItem:
				var delta : float = Engine.get_main_loop().root.get_physics_process_delta_time()
				callback = func(): 
					node.position += data.velocity * delta 
			
			else:
				assert(false, "错误的场景根节点类型，必须是 CanvasItem 的子类型的节点")
			
			execute_duration_process(duration, callback)
			
			self.created_missile_data.emit(data)
		
	, Object.CONNECT_ONE_SHOT)
	
	super._execute()
