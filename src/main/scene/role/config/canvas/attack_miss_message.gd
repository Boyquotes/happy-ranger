#============================================================
#    Attack Miss Message
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-14 21:52:40
# - version: 4.0
#============================================================
## 攻击丢失消息
class_name ConfigAttackMissMessage
extends ConfigCanvas


const MessageList = [
	"小样让你躲过一劫",
	"焯！",
	"等下就给你再来一拳",
	"「怒火中烧」",
]


#(override)
func _actor_ready():
	super._actor_ready()
	
	var attack_target = DataUtil.get_ref_data(null)
	
	var damage_area = role.get_first_node_by_class(DamageArea) as DamageArea
	damage_area.detected_node.connect(func(node, collision_shape):
		if node is BodyArea:
			attack_target.value = node.host
		
	)
	
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if stage == Const.Stages.BEFORE:
			attack_target.value = null
		elif stage == Const.Stages.AFTER:
			if attack_target.value == null:
#				RoleMessage.create(role, MessageList.pick_random())
				pass
				role.talk(MessageList.pick_random())
		
	)
	

