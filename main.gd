#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-28 19:28:42
# - version: 4.0
#============================================================
extends Node2D


#var es = load("res://src/main/v1/editor_script_00.gd")

const MONK = preload("res://src/main/scene/role/player/monk/monk.tscn")
const PLAYER_CONTROL = preload("res://src/main/scene/role/player_control.tscn")


var __init_node = FuncUtil.inject_by_unique(self)
var rooms_four : BaseMap


#============================================================
#  内置
#============================================================
func _ready():
	_init_player()
	_init_map_cell()


#============================================================
#  自定义
#============================================================
func _init_player():
	var generate_map = rooms_four.generate_map
	
	var rect = Rect2i(Vector2i(0,0), rooms_four.room_block_size)
	rect = rect.grow(-1)
	var ground_list = []
	FuncUtil.for_recti(rect, func(coords):
		if (TileMapUtil.has_cell_data(generate_map, coords, [0])
			and not TileMapUtil.has_cell_data(generate_map, coords + Vector2i.UP, [0])
		):
			ground_list.append(coords + Vector2i.UP)
	)
	
	# 添加 Player
	var player = MONK.instantiate()
	player.global_position = ground_list.pick_random() * generate_map.tile_set.tile_size + Vector2i(8, 8)
	add_child(player)
	Global.player = player
	
	# 添加角色控制节点
	var froot = FRoot.new()
	var player_control = PLAYER_CONTROL.instantiate()
	froot.add_child(player_control, true)
	player.add_child(froot, true)
	player.z_index = 10
	
	# 镜头
	var camera = Camera2D.new()
	camera.zoom = Vector2(1.5, 1.5)
	camera.position_smoothing_enabled = true
	player.add_child(camera)
	
	# 限制镜头视野范围
	var limit = CameraLimit.new()
	limit.camera = camera
	limit.tilemap = generate_map
	var m = Rect2i().grow(-2 * generate_map.tile_set.tile_size.x)
	m.position += generate_map.tile_set.tile_size * 2 - Vector2i(0, 16)
	limit.margin = m


## 初始化地图单元格数据
func _init_map_cell():
	pass
	
	return
	
	
	var generate_map = rooms_four.generate_map
	var tile_size : Vector2i = generate_map.tile_set.tile_size
	
	# 扫描地面
	var used_cells : Array[Vector2i] = TileMapUtil.get_used_cells(generate_map, [
		Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(3, 1),
		Vector2i(4, 0),
	], [0], [1])
	var cell_list = TileMapUtil.scan_ground(generate_map, [], used_cells)
	for coords in cell_list:
		if randf() < 0.1:
			# 添加宝箱
			var chest = NodeUtil.instance_class_scene(Chest) as Chest
			chest.global_position = (
				(coords + Vector2i.UP) * tile_size
				+ tile_size / 2
				+ Vector2i(0, int(tile_size.y / 2.0))
			)
			for i in randi_range(3, 5):
				var item_data = Datas.get_all_items().pick_random()
				assert(item_data != null)
				chest.add_item(item_data)
			add_child.call_deferred(chest)


