# editor_script_00.gd
@tool
extends EditorScript


func _run():
	pass
	
	var hset = HashSet.new([1, 2, 3, 4, 5])
	
	for item in hset:
		print(item)
	
	print( hset.union(HashSet.new([1, 2, 3, 9])) )
	print( hset.intersection(HashSet.new([1, 2, 3, 9])) )
	print( hset.difference(HashSet.new([1, 2, 3, 9])) )
	print( hset.complementary(HashSet.new([1, 2])) )
	print( hset.subtraction(HashSet.new([1, 2, 3, 9])) )
	
	

