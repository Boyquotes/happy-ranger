#============================================================
#    F Bridge
#============================================================
# - datetime: 2023-01-03 23:14:49
#============================================================
## 节点桥接器
class_name FBridge
extends FNode


var __FBridge_readied = (
	func():
		if self['__FBridge_readied']:
			return true
		await tree_entered
		self['__FBridge_readied'] = true
		
		# 向上查找
		var p : Node = get_parent()
		while true:
			if p is FNode or p == get_tree().current_scene:
				p = null
				break
			for child in p.get_children():
				if child is FNodeBase:
					p = child.root
					break
			if p is FRoot:
				break
			p = p.get_parent()
		
		if p is FRoot:
			self.root = p
			self.blackboard = p.blackboard
			self.actor = p.actor
			get_parent().remove_child.call_deferred(self)
			root.add_child.call_deferred(self)
			root.init_fnode(self)
		else:
			Log.warning([self, '子节点下没有 FRoot 节点'])
		
).call()

