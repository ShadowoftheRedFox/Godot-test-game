extends MarginContainer

@onready var texture_rect: TextureRect = $TextureRect

@export_group("Size & position", "position_")
## How stretched up the generated image will be
@export_range(0.0001, 1.0, 0.001, "or_greater") var position_scale: float = 0.02
@export var position_offset_x: float = 0.0
@export var position_offset_y: float = 0.0
@export var position_resolution: float = 0.3
@export_group("Noise", "noise_")
## How many layer of each noise there will be.
@export_range(1, 10) var noise_octaves: int = 1
@export_range(0.0001, 1.0) var noise_persistance: float = 0.02
@export_range(0.0001, 1.0) var noise_lacunarity: float = 0.02
@export var noise_seed: String = ""
@export var noise_gradient: Gradient = Gradient.new()

@onready var input_scale: SpinBox = %Scale
@onready var input_offset_x: SpinBox = %OffsetX
@onready var input_offset_y: SpinBox = %OffsetY
@onready var input_resolution: SpinBox = %Resolution
@onready var input_octaves: SpinBox = %Octaves
@onready var input_persistance: SpinBox = %Persistance
@onready var input_lacunarity: SpinBox = %Lacunarity
@onready var input_seed: LineEdit = %Seed

func _ready() -> void:
	# set default value to the given parameters
	input_scale.value = position_scale
	input_offset_x.value = position_offset_x
	input_offset_y.value = position_offset_y
	input_resolution.value = position_resolution
	input_octaves.value = noise_octaves
	input_persistance.value = noise_persistance
	input_lacunarity.value = noise_lacunarity
	input_seed.text = noise_seed
	
	# update on change
	input_scale.value_changed.connect(generate)
	input_offset_x.value_changed.connect(generate)
	input_offset_y.value_changed.connect(generate)
	input_resolution.value_changed.connect(generate)
	input_octaves.value_changed.connect(generate)
	input_persistance.value_changed.connect(generate)
	input_lacunarity.value_changed.connect(generate)
	input_seed.text_changed.connect(generate)
	
	generate()

func generate(_ignore: Variant = "") -> void:
	# get values from the inputs
	position_scale = input_scale.value
	position_offset_x = input_offset_x.value
	position_offset_y = input_offset_y.value
	position_resolution = input_resolution.value
	noise_octaves = int(input_octaves.value)
	noise_persistance = input_persistance.value
	noise_lacunarity = input_lacunarity.value
	noise_seed = input_seed.text 
	
	# get our size in int
	var w: int = max(1, int(texture_rect.size.x * position_resolution))
	var h: int = max(1, int(texture_rect.size.y * position_resolution))
	# prepare our array of height data
	var data: PackedFloat32Array = PackedFloat32Array()
	# prepare the array size for the bytes to come
	data.resize(w * h)
	# fill with 0 to start with
	data.fill(0.0)
	
	# create a new noise generator
	var noise: FastNoiseLite = FastNoiseLite.new()
	#texture.noise = noise
	
	# set type to perlin
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = noise_octaves
	noise.fractal_lacunarity = noise_lacunarity
	noise.fractal_gain = 0.5
	noise.fractal_weighted_strength = noise_persistance
	noise.frequency = 0.01
	noise.seed = noise_seed.hash()
	
	# loop for each pixels
	for y:int in range(h):
		for x:int in range(w):
			var sampleX: float = x / position_scale
			var sampleY: float = y / position_scale
			# clamp the sample between 0 and 1
			data.set(y*w+x, (noise.get_noise_2d(sampleX + position_offset_x, sampleY + position_offset_y) + 1.0) / 2.0)
	
	# read our created data array, and set the correct color depending on the gradient
	var color_data: PackedByteArray = PackedByteArray()
	color_data.resize(w*h*3)
	for i:int in range(data.size()):
		var color: Color = noise_gradient.sample(data.get(i))
		color_data.set(i*3, color.r8)
		color_data.set(i*3+1, color.g8)
		color_data.set(i*3+2, color.b8)
	
	# create a texture from an image from our data
	var image: Image = Image.create_from_data(w, h, false, Image.FORMAT_RGB8, color_data)
	texture_rect.texture = ImageTexture.create_from_image(image)
	
