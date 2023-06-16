#============================================================
#    Init Tree
#============================================================
# - datetime: 2022-09-13 14:41:11
#============================================================
## FNode 初始化树
##
## 操作获取关于 [FRoot] 中相关的子节点的数据信息

class_name FInitTree


#============================================================
#  SetGet
#============================================================
##  获取所有 [FRoot]
static func get_all_root() -> Array[FNodeBase]:
	var data := FTreeData.get_data().duplicate(true)
	data.erase("id")
	return data.values().map(func(data: FTreeData): return data.root)


##  注入节点的属性
static func inject_property(froot: FNodeBase, fnode: FNodeBase):
	
	# 匿名方法 - 能否注入这个属性
	var p_inject = fnode.get_inject_property()
	var is_can_inject = func(p:String):
		if fnode.get(p) != null:
			return false
		if p_inject.get_include_propertys().size() == 0:
			return not p_inject.get_exclude_propertys().has(p)
		else:
			return p_inject.get_include_propertys().has(p) and not p_inject.get_exclude_propertys().has(p)
	
	# 获取注入的属性
	var fclass = fnode.get_script() as GDScript
	var propertys = fclass.get_script_property_list() \
		.filter( func(data): return data['type'] == TYPE_OBJECT and fnode.get(data['name']) == null ) \
		.map( func(data): return data['name'] )
	
	# 开始注入
	var tree_data = FTreeData.instance(froot)
	for property in propertys:
		if is_can_inject.call(property):
			# 根据属性名跟节点名进行注入测试
			var inject_fnode : FNodeBase = tree_data.get_first_fnode_by_name(property)
			if inject_fnode != null:
				fnode.set(property, inject_fnode)
				print(">>> ", fnode, " 的 ", property, " 属性已自动注入 ", inject_fnode, " 节点")


##  注册 [FRoot] 节点，以进行记录整个 FNode 中的信息
static func register(froot: FNodeBase):
	var config_list = FConfiguration.get_all_configuration()
	
	# 开始注入前配置
	for config in config_list:
		config._init_before(froot)
	
	var all_fnode = FTreeData.instance(froot).get_all_fnode()
	for fnode in all_fnode:
		# 开始注入
		if fnode.get_inject_property().auto_inject:
			inject_property(froot, fnode)
	
	# 注入后配置
	for config in config_list:
		config._init_after(froot)


