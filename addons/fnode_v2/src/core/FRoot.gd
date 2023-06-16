#============================================================
#    F Root
#============================================================
# - datetime: 2022-09-13 13:37:29
#============================================================
@icon("../asset/icon/FStateBase.png")
class_name FRoot
extends FNodeBase


@export var actor : Node:
	set(v):
		if actor == null:
			actor = v
		else:
			push_error("已设置 actor 不能修改")

var blackboard := FBlackboard.new()


var __inited := {}
var root : FNodeBase = self
var readied : bool = false


#============================================================
#  内置
#============================================================
func _enter_tree() -> void:
	if self.actor == null:
		self.actor = get_parent()
		push_warning("没有设置 actor 属性，默认设置为父节点", get_parent())
		print_rich("[color=GOLD]", self, "没有设置 actor 属性，默认设置为父节点 ", get_parent(), "[/color]")
	
	# 初始化子节点
	var list = FNodeScanner.scan_all_child_fnode(self)
#	print("开始进行注册：")
	for node in list:
		init_fnode(node)
	
	# 注册节点
	FInitTree.register(self)
	
	if not readied:
		ready.connect( func(): readied = true, Object.CONNECT_ONE_SHOT )


#============================================================
#  自定义
#============================================================
func init_fnode(fnode):
	if fnode is FNodeBase:
		if not __inited.has(fnode):
			__inited[fnode] = null
			
			fnode.root = self
			fnode.blackboard = blackboard
			fnode.actor = actor
			fnode.child_entered_tree.connect(init_fnode)
			fnode._init_inject_property(fnode.__inject_property)
#			print("\t > ", fnode)
		

