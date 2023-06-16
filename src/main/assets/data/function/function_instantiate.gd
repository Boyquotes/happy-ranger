#============================================================
#    Function Instantiate
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 23:26:15
# - version: 4.0
#============================================================
## 功能实例
class_name FunctionInstantiate


## 功能文件目录
const PATH = "res://src/main/assets/data/function_extend/"


var role : Object
var function


func _init(
	role: Object,
	function_or_object
):
	assert(role != null, "role 不能为 null")
	
	var instance : BaseFunction
	if function_or_object is String:
		instance = get_function_res(function_or_object)
	elif function_or_object is BaseFunction:
		instance = function_or_object
	else:
		assert(false, "错误的数据类型")
	
	instance.role = role
	self.role = role
	self.function = instance


##  获取功能资源
##[br]
##[br][code]function_name[/code]  功能名称
##[br][code]return[/code]  返回这个名称的功能的资源
static func get_function_res(function_name: String) -> BaseFunction:
	var path = PATH.path_join(function_name) + ".gd"
	assert(FileAccess.file_exists(path), "没有这个名称的功能")
	
	var script = load(path) as GDScript
	return script.new()


##  执行功能
##[br]
##[br][code]property_data[/code]  功能对象的数据。key 为属性，value 为设置的值，进行配置
##这要看你要使用的 Function 有哪些参数
##[br][code]target_object[/code]  目标对象
##[br][code]target_point[/code]  目标点
func execute(
	property_data : Dictionary,
	target_object: Object = null, 
	target_point : Vector2 = Vector2.INF,
) -> BaseFunction:
	var instance : BaseFunction = function
	
	# 设置属性
	for property in property_data:
		if (property in instance 
			and not property.begins_with("_")
			and property_data[property] != null
		):
			instance[property] = property_data[property] 
	
	# 配置参数
	instance.bind_role(role)
	if instance is BaseTargetPoint:
		instance.target_point = target_point
	elif instance is BaseTargetObject:
		instance.target_object = target_object
	elif instance is BaseTargetObjectOrPoint:
		instance.target_object = target_object
		instance.target_point = target_point
	
	# 执行功能
	instance.execute.call_deferred()
	return instance


