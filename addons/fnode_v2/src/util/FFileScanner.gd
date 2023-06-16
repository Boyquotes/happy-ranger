#============================================================
#    F File Scanner
#============================================================
# - datetime: 2022-10-28 16:10:51
#============================================================
class_name FFileScanner



static func scan(path: String) -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(path):
		return []
	
	var list : PackedStringArray = PackedStringArray()
	var all_dir = func(path:String, callback:Callable):
		var dir = DirAccess.open(path)
		list.append_array(Array(dir.get_files()) \
			.filter(func(file:String): return file.get_extension() == "gd" ) \
			.map( func(file:String): return path.path_join(file) )
		)
		for d in dir.get_directories():
			callback.call( path.path_join(d), callback )
	all_dir.call(path, all_dir)
	return list

