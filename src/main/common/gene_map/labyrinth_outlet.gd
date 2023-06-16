#============================================================
#    Labyrinth Outlet
#============================================================
# - datetime: 2023-02-22 17:32:44
#============================================================
## 迷宫出口
@tool
extends EditorScript


func _run():
	var string = """
00100000000000000000000000
00100000000000011111011100
00111111000000010001000100
00000011000100010001111100
00110011111110010000010000
00111111000011110000011110
00000000000000000000000100
"""
	var map = string.strip_edges().split("\n")
	var rect = Rect2i(0, 0, len(map[0] if map.size() > 0 else 0), map.size())
	var start = Vector2i(2,0)
	
	# 搜索迷宫
	var points = FuncUtil.path_move(start, MathUtil.get_four_directionsi(), func(coord: Vector2i):
		if not rect.has_point(coord):
			return false 
		if coord.x < 0 or coord.y < 0:
			return false
		return map[coord.y][coord.x] != '0'
	)
	var edge_points := {}
	for next_pos in points:
		if MathUtil.is_rect_edge(next_pos, rect):
			edge_points[next_pos] = null
	
	print(edge_points.keys())

