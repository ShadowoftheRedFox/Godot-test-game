class_name NoiseTerrainGenerator 

# clamp value from [-1,1] to [0, 1]
func evaluate(noise: Noise, point: Vector3) -> float:
	var noise_value: float = noise.get_noise_3d(point.x, point.y, point.z)
	noise_value = (noise_value + 1) / 2.0
	
	return noise_value

# cerate mesh from the given data
func apply_noise(noises: Array[NoiseComponent], mesh: Mesh, offset: Vector2) -> Mesh:	
	if noises.size() == 0:
		return mesh
	
	# setup
	var sTool: SurfaceTool = SurfaceTool.new()
	var dataTool: MeshDataTool = MeshDataTool.new()
	sTool.clear()
	sTool.create_from(mesh, 0)
	var array_mesh: ArrayMesh = sTool.commit()
	dataTool.clear()
	dataTool.create_from_surface(array_mesh, 0)
	var vertex_count: int = dataTool.get_vertex_count()
	
	# apply each noise
	for noise_component: NoiseComponent in noises: 
		var noise: FastNoiseLite = noise_component.texture.noise
		var strength: float = noise_component.strength
		noise.offset = Vector3(offset.x, 0, offset.y)
		for i: int in range(vertex_count):
			var vertex: Vector3 = dataTool.get_vertex(i)
			var value: float = evaluate(noise, vertex)
			vertex.y = value * strength
			if vertex.y < 0:
				print("negative!")
			dataTool.set_vertex(i, vertex)
	
	# cleanup
	array_mesh.clear_surfaces()
	dataTool.commit_to_surface(array_mesh)
	sTool.clear()
	sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	sTool.create_from(array_mesh, 0)
	sTool.generate_normals()
	return sTool.commit()
