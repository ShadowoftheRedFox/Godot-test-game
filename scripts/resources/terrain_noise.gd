class_name TerrainNoise extends Resource

@export var textures: Array[NoiseTexture2D] = []
# the greater the index of the textures, the greater the frequency
@export_range(1, 10, 1, "or_greater", "prefer_slider") var lacunarity: int = 2
# the greater the index of the textures, the lesser the amplitude
@export_range(0.0, 1.0, 0.01) var persistance: float = 0.5
@export_range(1.0, 100.0) var height: float = 10.0
