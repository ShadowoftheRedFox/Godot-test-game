class_name NoiseTerrainGenerator 

# clamp value from [-1,1] to [0, 1]
func evaluate(noise: Noise, point: Vector3) -> float:
	var noise_value: float = noise.get_noise_3d(point.x, point.y, point.z)
	noise_value = (noise_value + 1) / 2.0
	
	return noise_value

# create manualy a square mesh, with elevation and stitch
func manual_mesh() -> Mesh:
	
	return null

# create mesh from the given data
func apply_noise(noises: TerrainNoise, mesh: Mesh, offset: Vector3) -> Mesh:
	if noises.textures.size() == 0:
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
	# we suppose the mesh is a square
	var size: int = int(sqrt(vertex_count))
	
	# apply each noise
	for j: int in noises.textures.size(): 
		var noise: FastNoiseLite = noises.textures[j].noise
		noise.offset.x = offset.x
		noise.offset.z = offset.z
		noise.frequency = noises.lacunarity ** j
		
		for i: int in range(vertex_count):
			var vertex: Vector3 = dataTool.get_vertex(i)
			var value: float = evaluate(noise, vertex)
			
			# TEST trying to stitch the seams of the chunk
			# we check if the current vertex is on an edge
			var is_on_front: bool = i % size == 0 
			var is_on_back: bool = i % size == size - 1
			var is_on_left: bool = i < size
			var is_on_right: bool = i + size >= vertex_count
			var is_on_side: bool = is_on_front or is_on_back or is_on_left or is_on_right
			
			vertex.y = value * (noises.persistance ** j) * noises.height
			#if is_on_side:
				#vertex.y += 1
			dataTool.set_vertex(i, vertex)
	
	# cleanup
	array_mesh.clear_surfaces()
	dataTool.commit_to_surface(array_mesh)
	sTool.clear()
	sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	sTool.create_from(array_mesh, 0)
	sTool.generate_normals()
	return sTool.commit()
