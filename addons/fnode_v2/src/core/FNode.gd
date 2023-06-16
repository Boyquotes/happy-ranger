#============================================================
#    F Node
#============================================================
# - datetime: 2022-09-13 13:37:42
#============================================================
## 功能节点类。[FNode] 节点继承的关键类。
class_name FNode
extends FNodeBase


var root : FRoot:
	set(v):
		root = v
		if root.readied:
			# 如果根节点已经准备好，则直接调用
			_root_ready()
			_actor_ready()
		
		else:
			if root.actor:
				if not root.actor.ready.is_connected(_actor_ready):
					root.actor.ready.connect(_actor_ready, Object.CONNECT_ONE_SHOT)
				else:
					_actor_ready()
			else:
				root.ready.connect(func():
					await Engine.get_main_loop().process_frame
					_actor_ready()
				, Object.CONNECT_ONE_SHOT)
			

var blackboard : FBlackboard
var actor : Node


## 根节点 ready 完成
func _root_ready():
	pass


## 宿主节点 ready 完成
func _actor_ready():
	pass

