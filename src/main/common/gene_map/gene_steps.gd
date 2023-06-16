#============================================================
#    Gene Steps
#============================================================
# - datetime: 2023-02-17 16:53:48
#============================================================
@tool
extends EditorScript


const TEMPLATE = {
	"normal" : "========",
	"dangerous": "######",
}
var template_keys = TEMPLATE.keys()
var template_width = {}


func get_step_type():
	if randf() <= 0.1:
		return template_keys[1]
	return template_keys[0]
 

func _init():
	# 一行最多容纳 5 个台阶，每个台阶8个瓦片：5x8=40，最大 40 个瓦片
	# 一块瓦片16x16像素，40x16=640。窗口最大宽度 640 像素
	# 按照 16:9 （1920 * 1080）同比缩放的大小，整个游戏的口大小为 640 x 360
	for key in TEMPLATE:
		template_width[key] = len(TEMPLATE[key])
	


func print_width(char: String, max_width: int, offset: int = 0):
	print("|", " ".repeat(offset), char, " ".repeat(max_width - (len(char)+offset)), "|")


func _run():
	var data_list : Array[Dictionary]= []
	var max_width : int = 40
	var height : int = 100
	for i in height:
		var type = get_step_type()
#		var offset = randi() % (max_width - template_width[type])
		var column = int((randi() % 40) / 4)
		var offset = min(column * 4, 40 - 8)
		data_list.append({
			"type": type,
			"offset": offset,
		})
	
	for data in data_list:
		print_width(TEMPLATE[data.type], max_width, data.offset )
		
	


