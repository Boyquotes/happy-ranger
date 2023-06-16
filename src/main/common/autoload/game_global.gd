#============================================================
#    Game Global
#============================================================
# - datetime: 2023-01-02 12:00:24
#============================================================
extends Node


## player 发生改变
signal player_changed(previous, player)


## 核心 Player。当前控制的 Player
var player : Role :
	set(v):
		if player != v:
			_last_player = player
			player = v
			self.player_changed.emit(_last_player, player)


var _last_player: Role
var _player_set: Dictionary = {}


#============================================================
#  SetGet
#============================================================
func is_player(role) -> bool:
	return role is Role and role == player

func is_player_by_area(area: Area2D) -> bool:
	return area is BodyArea and is_player(area.host)

func get_player() -> Role:
	return player

func get_last_player() -> Role:
	return player

func get_players() -> Array:
	return Array(_player_set.keys(), TYPE_OBJECT, "Role", Role)

func get_closest_player(target: Node2D) -> Role:
	return MathUtil.N.get_closest_node(target, get_players())


#============================================================
#  内置
#============================================================
func _enter_tree() -> void:
	# 购买物品，给当前节点添加
	GameEvent.BuyItem.listen(func(data: Dictionary):
		if player:
			player.add_item(data)
		else:
			Log.warning(["没有 player 对象"])
		
		Log.debug()
		prints("购买物品：", data)
	)


#============================================================
#  自定义
#============================================================
func register_player(role: Node) -> void:
	_player_set[role] = null
	role.tree_entered.connect(func(): _player_set[role] = null )
	role.tree_exiting.connect(func(): _player_set.erase(role) )

