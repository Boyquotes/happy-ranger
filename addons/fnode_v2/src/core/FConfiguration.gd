#============================================================
#    F Configuration
#============================================================
# - datetime: 2022-10-19 23:18:38
#============================================================
## [FNodeBase] 配置类
##
## 在 res://fnode_data 目录下创建继承这个节点的脚本，并重写下面方法，节点会在初始化前后调用这些类的方法
class_name FConfiguration


## 获取所有 [FConfiguration] 配置文件
static func get_all_configuration() -> Array:
	# 扫描所有配置文件
	const key = &"__meta_fnode_configuration_script_list"
	if not Engine.has_meta(key):
		var list = []
		const config_path = "res://fnode_data"
		var config_object_list = []
		if DirAccess.dir_exists_absolute(config_path):
			var config_file = []
			var scan_dir = func(path:String, callback:Callable, list: Array):
				var dir = DirAccess.open(path)
				if dir:
					# 添加文件
					list.append_array(Array(dir.get_files()).map( func(file):
						# 路径加上文件名
						return path.path_join(file) 
					) )
					# 继续递归扫描
					for d in dir.get_directories():
						callback.call(path.path_join(d), callback, list)
			# 扫描文件
			scan_dir.call(config_path, scan_dir, config_file)
			
			# 过滤出配置文件
			config_object_list = (config_file.filter(func(file:String): return file.get_extension() == 'gd' ) \
				.map(func(file:String): 
					var script = load(file)
					var object = script.new()
					if object is FConfiguration:
						return object
					if object != null and not object is RefCounted:
						object.free()
					return null
					)
				.filter(func(object): return object != null )
			)
		Engine.set_meta(key, config_object_list)
	
	# 获取所有配置文件对象
	var config_list = Engine.get_meta(key) as Array
	return config_list



#============================================================
#  重写
#============================================================
## 整个 [FRoot] 初始化前。重写这个方法用以执行操作。
## [br]
## [br]root [FRoot] 节点
func _init_before(root):
	pass


## 整个 [FRoot] 初始化后。重写这个方法用以执行操作。
## [br]
## [br]root [FRoot] 节点
func _init_after(root):
	pass
	

