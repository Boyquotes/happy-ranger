#============================================================
#    Game Event
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-22 15:36:03
# - version: 4.0
#============================================================
## 游戏全局事件
extends Node


class BaseEventObject:
	var _id
	var _params_desc : Array
	
	func _init(id, params_desc: Array = []):
		_id = id
		_params_desc = params_desc
	
	func _send(params: Array):
		assert(_params_desc.size() == params.size(), "参数数量不一致！")
		Event.send(_id, params)
	
	func listen(callback: Callable):
		Event.listen(_id, callback)
	

class OneParamEvent extends BaseEventObject:
	func send(arg1):
		_send([arg1])

class TwoParamEvent extends BaseEventObject:
	func send(arg1, arg2):
		_send([arg1, arg2])

class ThreeParamEvent extends BaseEventObject:
	func send(arg1, arg2, arg3):
		_send([arg1, arg2, arg3])

class FourParamEvent extends BaseEventObject:
	func send(arg1, arg2, arg3, arg4):
		_send([arg1, arg2, arg3, arg4])

class FiveParamEvent extends BaseEventObject:
	func send(arg1, arg2, arg3, arg4, arg5):
		_send([arg1, arg2, arg3, arg4, arg5])


var BuyItem := OneParamEvent.new("Buyitem", ["item_data"])
var ShowSelectItem := TwoParamEvent.new("ShowSelectItem", ["item_data", "click_callback"])
var HideSelectItem := OneParamEvent.new("HideSelectItem", ["item_data"])
var EnterShopItem := TwoParamEvent.new("EnterShopItem", ["item_data", "click_callback"])
var ExitShopItem := OneParamEvent.new("ExitShopItem", ["item_data"])
var EnterItem := OneParamEvent.new("EnterItem", ["item_node"])
var ExitItem := OneParamEvent.new("ExitItem", ["item_node"])
var KillRole := TwoParamEvent.new("KillRole", ["role", "target"])
var TopMessage := TwoParamEvent.new("TopMessage", ["texture", "message"])

