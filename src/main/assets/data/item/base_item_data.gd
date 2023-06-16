#============================================================
#    Base Item Data
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 14:30:12
# - version: 4.0
#============================================================
## 基本数据
class_name BaseItemData
extends Resource


signal upgraded


## 物品类型
enum Type {
	UNKNOWN, ## 未知的
	WEAPON, ## 武器类
	ARMOR, ## 护甲
	CONSUMABLE, ## 消耗类
	DECORATIVE, ## 装饰类
}

## 图片
@export var texture : Texture2D 
## 类型
@export var item_type : Type = Type.UNKNOWN 
## 名称
@export var name : String 
## 描述
@export_multiline var description : String
## 是否显示这个状态，用于buff等地方
@export var showed : bool = true 

## 增加最大生命值
@export var health : int = 0 
## 生命值恢复数量
@export var health_recovery : float = 0 
## 恢复速度
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(health/s)")
var healing_rate : float = 0
## 攻击力
@export var attack : float = 0  
## 攻击速度（一秒几下）
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(number/s)") 
var attack_speed : float = 0
## 攻击范围（像素）
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(pixel)") 
var attack_range : int = 10
## 移动速度
@export var move_speed : int = 0
## 跳跃高度
@export var jump_height : int = 0
## 数量
@export var count : int = 1 
## 当前等级
@export var level : int = 0:
	set(v):
		v = clampi(v, 0, upgrades.size() - 1)
		if (level != v 
			and (get_role() != null or v > -1)
		):
			level = v
			if level > -1:
				for property_data in ScriptUtil.get_property_data_list(_current_upgrade_data.get_script()):
					var property = property_data["name"]
					_current_upgrade_data[property] = upgrades[level][property]
			
				self.upgraded.emit()
## 当前经验
@export var experience : int = 0 :
	set(v):
		experience = v
		if level > -1 and _role!=null:
			if experience >= upgrades[level].need_experience:
				level += 1
## 功能
@export var functions : Array[BaseFunction] 
## 每级升级增加数据
@export var upgrades : Array[UpgradeItemData] 


var _role : Node
var _current_upgrade_data : UpgradeItemData = UpgradeItemData.new()


#============================================================
#  内置
#============================================================
func _to_string():
	return JSON.stringify(get_data())


#============================================================
#  自定义
#============================================================
static func create(role: Node) -> BaseItemData:
	var item = BaseItemData.new()
	item.bind_role(role)
	return item


func get_role():
	return _role


func get_data() -> Dictionary:
	var data : Dictionary = {}
	var property : String
	for property_data in ScriptUtil.get_property_data_list(get_script()):
		property = property_data["name"]
		if property in self:
			data[property] = self[property]
	return data


func bind_role(role) -> void:
	self._role = role
	for upgrade_data in upgrades:
		upgrade_data.bind_role(role)
	for function in functions:
		function.bind_role(role)


func add_function(function: BaseFunction):
	functions.append(function)
	if function.role == null:
		function.bind_role(_role)
	

func add_experience(value):
	experience += value


func get_property(property: StringName):
	if property in self:
		var value = self[property]
		if value is float or value is int:
			if property in _current_upgrade_data:
				value += _current_upgrade_data[property]
			return value
		else:
			return value
	return null
