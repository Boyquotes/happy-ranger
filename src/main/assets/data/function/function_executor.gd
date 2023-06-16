#============================================================
#    Func Executor
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 15:07:32
# - version: 4.0
#============================================================
## 功能执行器
class_name FunctionExecutor



##  执行
##[br]
##[br][code]function_or_object[/code]  功能名称或功能对象
##[br][code]property_data[/code]  功能对象的数据。key 为属性，value 为设置的值，进行配置
##这要看你要使用的 Function 有哪些参数
##[br][code]role[/code]  执行能的角色
##[br][code]target_object[/code]  目标对象
##[br][code]target_point[/code]  目标点
static func execute(
	function_or_object, 
	property_data : Dictionary,
	role: Object, 
	target_object: Object = null, 
	target_point : Vector2 = Vector2.INF,
) -> BaseFunction:
	var executor = FunctionInstantiate.new(role, function_or_object)
	return executor.execute(property_data, target_object, target_point)


