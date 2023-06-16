#============================================================
#    Consts
#============================================================
# - datetime: 2023-01-02 16:44:27
#============================================================
## 常量
class_name Const


## 唯一值
const ID = "id"
## 名称
const NAME = "name"
## 描述
const DESCRIPTION = "desc"
## 效果
const EFFECT = "effect"
## 技能
const SKILL = "skill"
## 陷阱
const TRAP = "trap"

## 生命值
const HEALTH = "health"
## 最大生命值
const HEALTH_MAX = "health_max"
## 攻击伤害
const DAMAGE = "damage"
## 实际造成的伤害
const REAL_DAMAGE = "real_damage"
## 目标生命值
const TARGET_HEALTH = "target_health"
## 攻击力
const ATTACK = &"attack"
## 攻击速度（速度 100 为 1 秒一下）
const ATTACK_SPEED = "attack_speed"
## 移动速度
const MOVE_SPEED = "move_speed"
## 跳跃高度
const JUMP_HEIGHT = "jump_height"
## 攻击来源
const SOURCE = "source"
## 攻击目标
const TARGET = "target"
## 播放动画
const ANIMATION = "animation"
## 是否可被控制
const UNABLE_CONTROL = "unable_control"
## 能否施放技能
const UNABLE_CAST = "unable_cast"
## 图片
const IMAGE = "image"
## 贴图
const TEXTURE = "texture"
## 类型
const TYPE = "type"
## 属性
const PROPERTY = "property"
## 数量
const COUNT = "count"
## 时间
const TIME = "time"
## 所属组
const GROUP = "group"
## 目标位置
const TARGET_POS = "target_position"
## 攻击距离
const ATTACK_DISTANCE = "attack_distance"
## 级别
const LEVEL = "level"
## 参考
const REFERENCE = "reference"
## 概率
const PROBABILITY = "probability"
## 经验
const EXPERIENCE = "experience"
## 特点
const FEATURE = "feature"
## 材料
const MATERIAL = "material"
## 场景
const SCENE = "scene"
## 脚本
const SCRIPT = "script"
## 事件
const EVENT = "event"
## 节点
const NODE = "node"
## 回调方法
const CALLABLE = "callable"
## 信号
const SIGNAL = "signal"
## 数据
const DATA = "data"

##不能攻击
const UNABLE_ATTACK = "unable_attack"


## 状态
const States = {
	NORMAL = &"normal",
	SKILL = &"skill",
	UNCONTROL = &"uncontrol",
}

## 技能执行阶段
enum Stages {
	READY,
	BEFORE,
	EXECUTE,
	AFTER,
	COOLDOWN,
}


## 碰撞体层级
const PhysicsLayer = {
	WORLD = 1 << 0,
	ROLE = 1 << 1,
	WALL = 1 << 2,
	FLOOR = 1 << 3,
	MISSILE = 1 << 4,
	SHOP = 1 << 5,
	STAIRS = 1 << 6,
	ENVIRONMENT = 1 << 7,
	ITEM = 1 << 8,
}


## 伤害类型
const DamageType = {
	## 普通伤害
	NORMAL = &"normal",
	## 暴击伤害
	CRITICAL_BLOW = &"critical_blow", 
}


## 物品类型
const ItemType = {
	# 武器
	WEAPON = &"weapon",
	# 装饰品
	ORNAMENT = &"ornament",
	# 护甲
	ARMOR = &"armor",
	# 药剂
	POTION = &"potion",
	# 消耗品
	CONSUMABLE = &"consumable",
	# 材料
	MATERIAL = &"material",
}


# 地图瓦片层级
enum TileCellLayer {
	BASE,	# 基本砖块
	DECORATION,		# 装饰的瓦片
	INTERACTIVE,	# 替换为可交互的
	BACKGROUND,		# 背景瓦片
	GENERATE,	# 替换为自动生产出对象的东西
}
