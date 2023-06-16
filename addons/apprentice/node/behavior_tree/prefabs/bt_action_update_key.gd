#============================================================
#    Bt Action Update Key
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 20:51:48
# - version: 4.0
#============================================================
## 每帧执行资源，更新到 [BTRoot] 中的全局数据中，使用 [method BTRoot.get_global_value]
## 进行获取数据
class_name BTActionUpdateKey
extends BTActionLeaf


## 更新数据的对象列表
@export var targets : Array[BTResUpdateKey]:
	set(v):
		targets = v
		if not is_inside_tree():
			await tree_entered
		for target in targets:
			target.set_owner(self)


#(override)
func _do():
	for target in targets:
		if target:
			root.set_global_value(target.key, target.get_value())

