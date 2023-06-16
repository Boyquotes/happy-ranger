#============================================================
#    Role Util
#============================================================
# - datetime: 2022-12-31 15:06:24
#============================================================
class_name RoleUtil


enum Priority {
	AROUND,  ## 在信号执行之前
	BEFORE,  ## 在信号执行之后
	AFTER,
}

enum {
	WORLD = 1 << 0,
	ROLE = 1 << 1,
	WALL = 1 << 2,
	FLOOR = 1 << 3,
	MISSILE = 1 << 4,
}


#============================================================
#  SetGet
#============================================================
## 获取 Role 节点
static func get_role(node: Node) -> Role:
	const key = "RoleUtil_get_role_map"
	var map = DataUtil.singleton_dict_from_object(node, key)
	return DataUtil.get_value_or_set(map, node, func():
		if node is Role:
			map[node] = node
			return node
		return NodeUtil.find_parent_by_class(node, Role)
	)


##  获取这个类型的第一个节点
static func get_first_node_by_class(role: Role, _class) -> Node:
	var list = role.node_db.get_nodes_by_class(_class)
	if len(list) > 0:
		return list[0]
	return null


## 获取这个类型的节点
static func get_nodes_by_class(role: Role, _class) -> Array[Node]:
	return role.node_db.get_nodes_by_class(_class)


#============================================================
#  自定义
#============================================================
## 打印错误
static func error(role: Role, node: Node, message) -> void:
	push_error( role, " || ", node, " ", message)


static func is_enemy(role: Role, target) -> bool:
	if target:
		return role != target
	return false


static func is_enemy_body_area(role: Role, body_area: BodyArea) -> bool:
	return body_area and is_enemy(role, body_area.host)


static func is_player(role: Role) -> bool:
	return role == Global.player


static func is_player_body_area(body_area: BodyArea) -> bool:
	return body_area \
		and is_player(body_area.host) \
		and is_instance_valid(body_area.host)


## 射线添加当前节点所有子节点的对应的排除类的对象
##[br]
##[br][code]_class[/code]  排除的类型的节点
static func ray_add_execption(role: Role, ray: RayCast2D, _class):
	for coll in role.node_db.get_nodes_by_class(_class):
		ray.add_exception(coll)


##  处理目标身体区域
##[br]
##[br][code]role[/code]  角色
##[br][code]target_body_area[/code]  目标区域
##[br][code]callable[/code]  操作回调方法，这个方法和需要一个 [Role] 类型的参数接收目标身体区域的所属角色 
static func handle_target_body_area(role: Role, target_body_area: BodyArea, callable: Callable) -> void:
	if role != null and target_body_area != null:
		var target = target_body_area.host
		if is_instance_valid(target) and target != role:
			callable.call(target)
	else:
		ErrorLog.is_null(role, "role 为空！")
		ErrorLog.is_null(target_body_area, "target_body_area 为空！")


##  创建伤害区域
##[br]
##[br][code]host[/code]  宿主节点
##[br][code]collision_mask[/code]  检测节点的区域
##[br][code]callable[/code]  检测到目标的回调方法，这个方法需要两个参数：
##[br] - node 检测到的对象
##[br] - collision_object 检测到这个对象的碰撞形状，类型是 [CollisionShape2D] 或 [CollisionPolygon2D]
static func create_damage_area(host: Node2D, collision_mask: int, callable: Callable = Callable()) -> DamageArea:
	var damage_area = DamageArea.new()
	damage_area.host = host
	damage_area.collision_layer = 0
	damage_area.collision_mask = collision_mask
	if callable.is_valid():
		damage_area.detected_node.connect(callable)
	return damage_area




