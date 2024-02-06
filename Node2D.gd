extends Node2D

func _ready():
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	var remaining_points : PackedVector2Array = $MeshInstance2D/Line2D.points
	var original_indices : PackedInt32Array = []
	for index in remaining_points.size():
		original_indices.append(index)
	
	var iteration_count : int = 0
	var indices : PackedInt32Array = []
	var current_index : int = 0
	while remaining_points.size() > 2:
		if iteration_count > 2000:
			print("runaway")
			print(remaining_points)
			break
		
		var index_a : int = current_index % remaining_points.size()
		var index_b : int = (current_index + 1) % remaining_points.size()
		var index_c : int = (current_index + 2) % remaining_points.size()
		
		var a : Vector2 = remaining_points[index_a]
		var b : Vector2 = remaining_points[index_b]
		var c : Vector2 = remaining_points[index_c]
		
		if is_clockwise(a, b, c):
			indices += PackedInt32Array([original_indices[index_a], original_indices[index_b], original_indices[index_c]])
			remaining_points.remove_at(index_b)
			original_indices.remove_at(index_b)
		
		current_index = index_b
		iteration_count += 1
	
	var colors = PackedColorArray([])
	for point in $MeshInstance2D/Line2D.points:
		colors.append(Color(randf(), randf(), randf()))
	
	
	#prepare mesh data
	var arrays : Array = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	
	arrays[Mesh.ARRAY_VERTEX] = $MeshInstance2D/Line2D.points
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_COLOR] = colors
	
	var mesh = ArrayMesh.new() #initialize mesh
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	$MeshInstance2D.mesh = mesh

func is_clockwise(a : Vector2, b : Vector2, c : Vector2) -> bool:
	return (a - b).cross(a -c) > 0
