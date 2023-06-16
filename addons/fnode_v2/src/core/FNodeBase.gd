#============================================================
#    F Node Base
#============================================================
# - datetime: 2022-09-13 13:36:44
#============================================================
## [FNode] 的基础类
@icon("../asset/icon/FNodeBase.png")
class_name FNodeBase
extends Node


var __inject_property : FInjectProperty = FInjectProperty.new()


##  获取注入属性数据
func get_inject_property() -> FInjectProperty:
	return __inject_property


##  注入属性方法
func _init_inject_property(inject_property: FInjectProperty):
	pass

