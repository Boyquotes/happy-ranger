#============================================================
#    Config Take Damage Sound
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-08 21:42:02
# - version: 4.x
#============================================================
## 受到伤害时的声音
class_name ConfigTakeDamageSound
extends ConfigSound


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.took_damage, func(data: Dictionary):
		if data.get(Const.TYPE) == Const.DamageType.NORMAL:
			if sound_config.size() > 0:
				play()
	)
	

