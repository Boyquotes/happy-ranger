#============================================================
#    Config Signal Sound
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-09 21:53:58
# - version: 4.x
#============================================================
## 发出信号时就发出音
class_name ConfigSignalSound
extends ConfigSound


@export var target : Node
@export var signal_name: StringName


#(override)
func _actor_ready():
	super._actor_ready()
	assert(target, "错误的对象")
	assert(target.has_signal(signal_name), "错误的信号名，将不会播放声音")
	
	var _signal = Signal(target, signal_name)
	var method = SignalUtil.get_method_by_sginal_call_no_arg(_signal, play, self)
	get_listener().listen(_signal, method)
	

