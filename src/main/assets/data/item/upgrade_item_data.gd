#============================================================
#    Upgrade Item Data
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-23 10:52:57
# - version: 4.0
#============================================================
class_name UpgradeItemData
extends Resource


## 所需经验值
@export var need_experience : int = 0 
## 描述
@export_multiline var description : String = ""
## 数量
@export var count : int = 0 
## 增加最大健康值
@export var health : int = 0 
## 健康值恢复值
@export var health_recovery : float = 0 
## 健康恢复速度
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(health/s)")
var healing_rate : float = 0
## 攻击
@export var attack : float = 0  
## 攻击速度（一秒几下）
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(number/s)") 
var attack_speed : float = 0
## 攻击范围（像素）
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(pixel)") 
var attack_range : int = 10
## 移动速度
@export var move_speed : int = 0
## 跳跃
@export var jump_height : int = 0


var role : Node


func bind_role(role: Node):
	self.role = role

