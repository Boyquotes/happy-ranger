#============================================================
#    Config Sound
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-09 21:46:06
# - version: 4.x
#============================================================
##  配置声音
class_name ConfigSound
extends ConfigRole


## 随机播放其中一首声音
@export var random_play : bool = true
## 声音列表
@export var sound_config : Array[SoundConfig] = []


#(override)
func _actor_ready():
	super._actor_ready()
	ErrorLog.is_zero(sound_config.size(), " ".join([self, "|", role, "没有添加声音"]))
	
	for config in sound_config:
		if (is_instance_valid(config) 
			and config.get_audio_player()
			and not config.get_audio_player().is_inside_tree()
		):
			config.add_to(role)


##  播放声音
##[br]
##[br][code]from_position[/code]  从这个位置开始播放，如果小于 0，则按照设置的属性值播放
##[br][code]audio_stream[/code]  设置播放的声音
func play(from_position: float = -1):
	if sound_config.size() > 0:
		if random_play:
			sound_config.pick_random().play()
		else:
			for config in sound_config:
				config.play(from_position)


## 停止
func stop():
	for config in sound_config:
		config.stop()

