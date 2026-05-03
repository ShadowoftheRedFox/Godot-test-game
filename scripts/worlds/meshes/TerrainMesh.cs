using Godot;

public class TerrainMesh
{
	public Mesh mesh;
	public int LOD;
	public int size;

	public TerrainMesh(Mesh mesh, int LOD, int size)
	{
		this.mesh = mesh;
		this.LOD = LOD;
		this.size = size;
	}

	public void ConstructMesh()
	{
		// TODO apply LOD
		Vector3[] vertices = new Vector3[size * size];
		int[] triangles = new int[(size - 1) * (size - 1) * 6];
		int triangleIndex = 0;

		for (int y = 0; y < size; y++)
		{
			for (int x = 0; x < size; x++)
			{
				Vector2 percent = new Vector2(x, y) / (size - 1); // how far we are to be completed
				int i = x + y * size; // index of the current vertex
				Vector3 pointOnPlane = new Vector3(percent.X - .5f, 0, percent.Y - .5f);
				vertices[i] = pointOnPlane;

				// do not add triangles when on the edge of the mesh
				if (x != size - 1 && y != size - 1)
				{
					triangles[triangleIndex] = i;
					triangles[triangleIndex + 1] = i + size + 1;
					triangles[triangleIndex + 2] = i + size;

					triangles[triangleIndex + 3] = i;
					triangles[triangleIndex + 4] = i + 1;
					triangles[triangleIndex + 5] = i + size + 1;

					triangleIndex += 6;
				}
			}
		}
	}
}
