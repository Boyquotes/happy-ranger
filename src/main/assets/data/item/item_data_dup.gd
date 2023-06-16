#============================================================
#    Item Data
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-16 23:58:05
# - version: 4.0
#============================================================
extends Node


## 武器
const WEAPON : Array[Dictionary] = [
	{
		Const.NAME: "鸡肋的破烂小刀",
		Const.DESCRIPTION: "就像路边的花花草草一样，没人会多看两眼",
		Const.IMAGE: "knife_shabby",
	}, {
		Const.NAME: "有点意思的刀",
		Const.DESCRIPTION: "看起来还不错，可以用用",
		Const.IMAGE: "sword9",
	}, {
		Const.NAME: "短宽的刀",
		Const.DESCRIPTION: "比“有点意思的刀”宽了一点，看起来比较宽",
		Const.IMAGE: "sword10",
	}, {
		Const.NAME: "大棒",
		Const.DESCRIPTION: "胡萝卜加大棒，但是没有胡萝卜，只能给你一棒子",
		Const.IMAGE: "stick_big",
	}, {
		Const.NAME: "狼牙棒",
		Const.DESCRIPTION: "可以试试狼牙棒的感觉，一下变成洒水壶",
		Const.IMAGE: "wolf_tooth_stick_wood",
	}, {
		Const.NAME: "精致刺刀",
		Const.DESCRIPTION: "有点档次的武器，威力很大，但一般人不好掌握",
		Const.IMAGE: "sword11",
		Const.SKILL: ["贯穿", "突刺"],
	}, {
		Const.NAME: "带有电流的剑",
		Const.IMAGE: "lightning_sword",
		Const.DESCRIPTION: "",
		Const.SKILL: ["闪电穿击", "麻痹", "闪电链", "雷击"],
		
	}, {
		Const.NAME: "夜叉",
		Const.DESCRIPTION: "可掌握太阳运行轨迹的半神小神灵",
		Const.IMAGE: "yaksha",
		Const.PROPERTY: {
			Const.MOVE_SPEED: 30,
		},
		Const.SKILL: ["飞行", "发光", "变换"],
		Const.REFERENCE: ["https://baike.baidu.com/item/%E5%A4%9C%E5%8F%89/761"],
	}
]
 
## 药剂
const POTION : Array[Dictionary] = [
	{
		Const.NAME: "health potion",
		Const.DESCRIPTION: "红色小药剂",
		Const.IMAGE: "potion_small_red",
		Const.PROPERTY: {
			Const.HEALTH: 2,
		},
	}, {
		Const.NAME: "potion_green",
		Const.DESCRIPTION: "绿色小药剂",
		Const.IMAGE: "potion_small_green",
		Const.SKILL: ["health_recovery"],
	}, {
		Const.NAME: "potion_purple",
		Const.DESCRIPTION: "紫色小药剂",
		Const.IMAGE: "potion_small_purple",
		Const.SKILL: ["health_recovery"],
	}, 
]


const ORNAMENT : Array[Dictionary] = [
	{
		Const.NAME: "平平无奇的戒指",
		Const.DESCRIPTION: "",
		Const.IMAGE: "ring5",
	}, {
		Const.NAME: "破烂的碗",
		Const.DESCRIPTION: "",
		Const.IMAGE: "magic_bowl",
	}, {
		Const.NAME: "简简单单的一个皇冠",
		Const.DESCRIPTION: "低级小怪不敢攻击",
		Const.IMAGE: "pileum",
		Const.SKILL: ["尊贵"]
	}, 
	
]

const ARMOR : Array[Dictionary] = [] 
const CONSUMABLE : Array[Dictionary] = [] 
const MATERIAL : Array[Dictionary] = []



#============================================================
#  SetGet
#============================================================
static func _get_db() -> Dictionary:
	return DataUtil.singleton(&"ItemData_get_db", func():
		var item_data_class = ScriptUtil.get_script_class("ItemData")
		var data : Dictionary = {}
		for group_name in Const.ItemType.keys():
			assert(group_name in item_data_class, "没有 " + group_name + " 变量名称的物品数据在 ItemData 中")
			var group = item_data_class[group_name] as Array[Dictionary]
			FuncUtil.foreach(group, func(item: Dictionary, idx: int):
				var item_data := item.duplicate(true)
				assert(not data.has(item_data[Const.NAME]), "不能有重复名称的物品")
				# 更新记录数据
				item_data[Const.ID] = item_data[Const.NAME]
				item_data[Const.TYPE] = Const.ItemType[group_name]
				item_data[Const.TEXTURE] = ItemIcons.get_item_texture(item[Const.IMAGE])
				item_data.make_read_only()
				data[item_data[Const.ID]] = item_data
			)
		data.make_read_only()
		return data
	)


##  获取物品数据
##[br]
##[br][code]item_name[/code]  物品名称
##[br][code]return[/code]  返回物品数据
static func get_item(item_name: StringName) -> Dictionary:
	var data = Dictionary(_get_db().get(item_name, {})).duplicate(true)
	data[Const.LEVEL] = 1
	return data

