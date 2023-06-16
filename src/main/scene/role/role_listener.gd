#============================================================
#    Role Listener
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-24 10:27:52
# - version: 4.0
#============================================================
## 角色信号监听器
class_name RoleListener
extends Listener


var role : CharacterBody2D


#============================================================
#  内置
#============================================================
func _enter_tree():
	if role == null:
		var p = get_parent()
		while not p is CharacterBody2D and p != null:
			p = p.get_parent()
		assert(p != null, "不是 Role 类型节点下的子节点")
		role = p


#============================================================
#  监听方法
#============================================================
##  监听 normal 线程的执行
##[br]
##[br][code]callable[/code]  回调方法，这个方法需要有一个 [float] 类型的参数接受每帧间隔时间值
##[br][code]priority[/code]  执行优先级，值越小优先级越高
func listen_normal_process(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.normal_process, callable, priority)


## 监听这个技能开始执行。这个回调方法没有参数
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]skill_name[/code]  监听的技能名称
##[br][code]callable[/code]  回调方法，这个方法没有参数
##[br][code]priority[/code]  执行优先级，值越小优先级越高
func listen_skill_started(skill_name: StringName, callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.started, func(_skill_name: StringName):
		if _skill_name == skill_name:
			callable.call()
	, priority, [skill_name])


## 监听这个技能开始执行。这个回调方法没有参数
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]callable[/code]  回调方法，这个方法需要有一个 skill_name 参数接收执行的方法名称
func listen_all_skill_started(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.started, callable, priority)


## 监听这个技能束执行。这个回调方法没有参数
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]skill_name[/code]  监听的技能名称
##[br][code]callable[/code]  回调方法，这个方法没有参数
func listen_skill_ended(skill_name: StringName, callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.ended, func(_skill_name: StringName):
		if _skill_name == skill_name:
			callable.call()
	, priority, [skill_name])


## 监听这个技能结束执行。这个回调方法没有参数
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]callable[/code]  回调方法，这个方法需要有一个 skill_name 参数接收执行的方法名称
func listen_all_skill_ended(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.ended, callable, priority)


##  监听这个技能每个执行阶段。用于实现对技能每个阶段的功能的处理
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]skill_name[/code]  方法名
##[br][code]callable[/code]  到达每个阶段的回调。这个方法需要有两个参数：
##[br] - stage 用于接收执行阶段的值
##[br] - skill_data 用于接收行的技能的数据
func listen_skill(skill_name: StringName, callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.stage_changed, func(_skill_name, stage, data):
		if skill_name == _skill_name:
			callable.call(stage, data)
	, priority, [skill_name])


##  监听所有技能的执行阶段。用于实现对技能每个阶段的功能的处理
##[br]
##[br][code]role[/code]  监听的对象
##[br][code]callable[/code]  到达每个阶段的回调。这个方法需要有两个参数，一个 stage 用于接收执行阶段的值，一
##个 skill_data 用于接收行的技能的数据
func listen_all_skill(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.skill_actuator.stage_changed, callable, priority)


##  监听这个状态
##[br]
##[br][code]role[/code]  监听的象
##[br][code]state_name[/code]  状态名
##[br][code]callable[/code]  回调方法。这个方法需要有两个参数
##[br] - previous 上一个状态
##[br] - data 切换到当前状态时的数据
##[br][code]priority[/code]  状态的优先级
func listen_state(state_name:StringName, callable:Callable, priority: Priority = Priority.DEFAULT):
	return listen(role.state_node.child_state_changed, func(previous, current, data):
		if current == state_name:
			callable.call(previous, data)
	, priority, [state_name])


## 监听状态的改变。这个回调方法需要三个参数：
##[br] - previous 上一个状态
##[br] - current 当前状态
##[br] - data 切换到当前状态时的数据
func listen_all_state(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	return listen(role.state_node.child_state_changed, callable, priority)


##  监听物品数据的改变
##[br][code]role[/code]  监听的角色对象
##[br][code]item_id[/code] 监听的物品ID
##[br][code]callable[/code] 这个回调方法需要三个参数：
##[br] - previous 接收物品数据发生改变时上一次的数据
##[br] - current 接收当前物品的数据
##[br]  其中当前数据为空字典时则是物品被移除，上一次数据为空数组时则是第一次新添加
func listen_item(item_id: String, callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	var data_id = DataUtil.generate_id([item_id, callable])
	listen(role.item_management.newly_added_data, func(iid, value):
		if iid == item_id:
			callable.call({}, value)
	, priority, [], data_id)
	listen(role.item_management.data_changed, func(iid, previous, current):
		if iid == item_id:
			callable.call(previous, current)
	, priority, [], data_id)
	listen(role.item_management.removed_data, func(iid, value):
		if iid == item_id:
			callable.call(value, {})
	, priority, [], data_id)
	return data_id


##  监听所有物品数据的改变
##[br][code]role[/code]  监听的角色对象
##[br][code]callable[/code] 这个回调方法需要三个参数：
##[br] - item_id 物品唯一ID
##[br] - previous 接收物品数据发生改变时上一次的数据
##[br] - current 接收当前物品的数据
##[br]  其中当前数据为空字典时则是物品被移除，上一次数据为空数组时则是第一次新添加
func listen_all_item(callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	var id = DataUtil.generate_id([callable])
	listen(role.item_management.newly_added_data, func(id, value):
		callable.call(id, {}, value)
	, priority, [], id)
	listen(role.item_management.data_changed, func(id, previous, current):
		callable.call(id, previous, current)
	, priority, [], id)
	listen(role.item_management.removed_data, func(id, value):
		callable.call(id, value, {})
	, priority, [], id)
	return id


##  监听属性改变
##[br]
##[br][code]role[/code]  监听的角色对象
##[br][code]property[/code]  属性名
##[br][code]callable[/code]  回调方法，这个方法需要接收两个参数：
##[br] - previous 接收改变前的参数
##[br] - current 当前参数值
func listen_property(property: String, callable: Callable, priority: Priority = Priority.DEFAULT) -> String:
	var id = DataUtil.generate_id([property, callable])
	listen(role.property_management.property_changed, func(prop, previous, current):
		if prop == property:
			callable.call(previous, current)
	, priority, [], id)
	listen(role.property_management.newly_added_property, func(prop, value):
		if prop == property:
			callable.call(null, value)
	, priority, [], id)
	listen(role.property_management.removed_property, func(prop, value):
		if prop == property:
			callable.call(value, null)
	, priority, [], id)
	return id


##  监听跳跃方法
##[br]
##[br][code]role[/code]  监听的角色对象
##[br][code]callable[/code]  回调方法。这个方法需要有2个参数：
##[br] - height 角色跳跃的高度
##[br] - data 附加的其他数据
func listen_jump(callable: Callable) -> String:
	return listen(role.jumped, callable)


