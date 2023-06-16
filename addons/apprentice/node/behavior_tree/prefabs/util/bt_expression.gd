#============================================================
#    Bt Expression
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-09 19:04:42
# - version: 4.0
#============================================================
class_name BTExpressionUtil


const CodeTemplate = """
extends Node

var host : Node
var input_params = []

{variable}


func execute(params: Array):
	assert(input_params.size() == params.size(), "执行参数不一致")
{code}

"""



static func parse(
	expression: String, 
	host: Node,
	variables: PackedStringArray = PackedStringArray(),
) -> Node:
	# 生成脚本
	var script = GDScript.new()
	var code = expression \
		.strip_edges() \
		.indent("    ") \
		+ "\n"
	var variable_str = "\n".join(Array(variables)
		.map(func(item): 
			return "var %s " % item 
	))
	script.source_code = CodeTemplate.format({
		"variable": variable_str,
		"code": code,
	}).replace("\t", "    ") + "\n"
	script.reload()
	
	# 生成对象
	var node = script.new()
	node.input_params = variables
	node.host = host
	
	return node

