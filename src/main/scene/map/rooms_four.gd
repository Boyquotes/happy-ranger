#============================================================
#    Base Map
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-09 20:47:45
# - version: 4.0
#============================================================
@tool
extends BaseMap


@export var map_size : Vector2i = Vector2i(8, 6)


var sub_map_data = {
	# 对应地图的行列，下面的 range(数字) 的数值为地图每行的格子的地图
	DataUtil.as_set_hash([Vector2i.LEFT, Vector2i.RIGHT]): 
		range(13).map(func(item): return Vector2i(item, 0)),
		
	DataUtil.as_set_hash([Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]): 
		range(4).map(func(item): return Vector2i(item, 1)),
		
	DataUtil.as_set_hash([Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]): 
		range(3).map(func(item): return Vector2i(item, 2)),
		
	DataUtil.as_set_hash([Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]): 
		range(4).map(func(item): return Vector2i(item, 3)),
	
}

# 下面两个向量相加为地图房间坐标的偏移值
var room_block_size : Vector2i = Vector2i(16, 13)
var separation : Vector2i = Vector2i(5, 5)

var maps_data : MapGenerateUtil.RoomBlockMapData
var generate_map : BaseMap



#============================================================
#  SetGet
#============================================================
func _get_room_coords(directions: Array) -> Array:
	var id = DataUtil.as_set_hash(directions)
	return sub_map_data.get(id, [])


##  获取空白的坐标列表
func get_space_coords() -> Array[Vector2i]:
	var rect = Rect2i(0, 0, 17, 14)
	var center = rect.get_center()
	
	var list : Array[Vector2i] = []
	FuncUtil.path_move(rect.get_center(), MathUtil.get_four_directionsi(), func(coords: Vector2i):
		list.append(coords)
	)
	return list



#============================================================
#  内置
#============================================================
func _enter_tree():
	if Engine.is_editor_hint():
		return
	
	# 地图单元格数据
	maps_data = MapGenerateUtil.cut_map_room(self, room_block_size, separation, 2)


func _ready():
	if Engine.is_editor_hint():
		return
	
	if generate_map != null:
		for child in generate_map.get_children():
			child.queue_free()
	
	generate_map = BaseMap.new()
	generate_map.name = "generate_map"
	generate_map.tile_set = self.tile_set
	self.add_child(generate_map, true)
	# 颜色调暗，突出角色和物品
	var dark : float = 0.7
	generate_map.modulate = Color(dark, dark, dark)
	
	generate_map.clear()
	_generate()
	InterractiveGenerator.handle(generate_map) # 替换地图数据


## 生成地图
func _generate():
	
	# 生成数据
	var random_rooms = RandomRooms.new()
	random_rooms.size = Vector2i(5, 4)
	random_rooms.generate(1, 4)
	
	# 路径
	var down_rooms : Dictionary = {}
	var rooms_data : Dictionary = random_rooms.rooms_data.duplicate()
	for row in random_rooms.get_rows().slice(0, random_rooms.size.y - 1): # 末尾行不处理
		# 必定可以移动到下方的房间列
		var inters = random_rooms.get_intersections(row, row+1)
		var column = inters.pick_random()
		rooms_data[row]["down"] = column
		
		# 如果当前列之前是“向下到达的房间”，则上方也要开口
		if down_rooms.has(Vector2i(column, row)):
			down_rooms[Vector2i(column, row)] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		else:
			down_rooms[Vector2i(column, row)] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
		
		# 这个位置到上面位置的可通行方向
		down_rooms[Vector2i(column, row + 1)] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]
	
	# 生成房间
	var generate_map_data : Dictionary = {}
	# 上下通行的房间
	var rows = {}
	var row_to_dirs_data = {}
	for coords in down_rooms:
		if not rows.has(coords.y):
			row_to_dirs_data = {}
			rows[coords.y] = null
		
		var dirs = down_rooms[coords]
		var rooms_coords_list : Array
		if row_to_dirs_data.has(dirs) and not row_to_dirs_data[dirs]:
			rooms_coords_list = row_to_dirs_data[dirs]
		else:
			rooms_coords_list = _get_room_coords(dirs).duplicate()
			row_to_dirs_data[dirs] = rooms_coords_list
		
		var idx = randi() % rooms_coords_list.size()
		generate_map_data[coords] = rooms_coords_list[idx]
		rooms_coords_list.remove_at(idx)
	
	for row in random_rooms.get_rows():
		var coords_list = random_rooms.get_coords_by_row(row)
		# 左右双向的房间
		for coords in coords_list:
			if not generate_map_data.has(coords):
				var rooms_coords_list = _get_room_coords([Vector2i.LEFT, Vector2i.RIGHT])
				generate_map_data[coords] = rooms_coords_list.pick_random()
	
	# 添加到场景中
	generate_map.global_position = Vector2(0, 0)
	
	# 显示字符串样式的地图
	random_rooms.display()
	
	# 复制到 TileMap 中 
	var room_size = maps_data.room_block_size
	for row in random_rooms.get_rows():
		var coords_list = random_rooms.get_coords_by_row(row)
		for coords in coords_list:
			var room_coords = generate_map_data[coords]
			TileMapUtil.copy_cell_to(
				self, Rect2i(room_coords * (maps_data.room_block_size + maps_data.separation), room_size),
				generate_map, Rect2i(coords * (room_size + Vector2i.ONE), room_size)
			)
			TileMapUtil.set_cell(generate_map, coords* (room_size + Vector2i.ONE), 0)
	
	# 对其他没有生成的进行填充。TODO：进行设计，有些地方进行断开。
	var map_rect : Rect2i = Rect2i(Vector2i(0,0), random_rooms.size - Vector2i.ONE)
	FuncUtil.for_recti(map_rect, func(coords):
		if not generate_map_data.has(coords):
			var rooms_coords_list = _get_room_coords([Vector2i.LEFT, Vector2i.RIGHT])
			var room_coords = rooms_coords_list.pick_random()
			TileMapUtil.copy_cell_to(
				self, Rect2i(room_coords * (maps_data.room_block_size + maps_data.separation), room_size),
				generate_map, Rect2i(coords * (room_size + Vector2i.ONE), room_size)
			)
			TileMapUtil.set_cell(generate_map, coords * (room_size + Vector2i.ONE), 0)
	)
	
	# 边缘边框
	var marge : int = 1
	var thickness : int = 5
	var rect = map_rect
	rect.size = (room_size + Vector2i.ONE) * (rect.size + Vector2i.ONE) - Vector2i.ONE
	for i in range(marge, marge + thickness):
		FuncUtil.for_rect_around(rect, func(coords):
			TileMapUtil.set_cell(generate_map, coords, 1, Vector2i(randi_range(1, 4), 0))
		, i)
	
