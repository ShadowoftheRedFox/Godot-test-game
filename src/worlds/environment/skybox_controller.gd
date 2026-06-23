#@tool # Make it run in editor (might need to close and reopen scene to work)
extends WorldEnvironment # We're modifying the sky material that is on a WorldEnvironment, so extend from there.

@onready var sun: DirectionalLight3D = %Sun
@onready var moon: Node3D = %Moon
#@export_tool_button("Create cube map") var create_action: Callable = self.img
## Lentgh of a day in second
@export_range(1, 24*60*60) var day_length: int = 600
var sun_angle_speed: float = 1.0
var moon_angle_speed: float = 1.0

func _ready() -> void:
	 # transform day_lentgh to randians per seconds
	sun_angle_speed = deg_to_rad(360.0 / day_length)
	# the moon takes 30 days to make a full loop
	moon_angle_speed = deg_to_rad((360.0 / 30) / day_length)

func _process(_delta: float) -> void:
	var sun_dir: Vector3 = sun.global_transform.basis.z; # This is our forward direction pointing towards the sun
	var moon_dir: Vector3 = moon.global_transform.basis.z; # This is our forward direction pointing towards the moon
	var moon_basis: Basis = moon.global_transform.basis
	
	var sky_material: ShaderMaterial = environment.sky.sky_material
	sky_material.set_shader_parameter('sun_dir', sun_dir); # Update sky material with sun direction
	sky_material.set_shader_parameter('moon_dir', moon_dir); # Update sky material with moon direction
	sky_material.set_shader_parameter('moon_world_to_object', moon_basis.inverse())# The world to object matrix is the inverse of the basis (which is object to world)
	
	#sun_angle_speed = deg_to_rad(360.0 / day_length)
	#moon_angle_speed = deg_to_rad(12.0 / day_length)
	sun.rotate_x(sun_angle_speed * _delta)
	moon.rotate_x(moon_angle_speed * _delta)

func img() -> void:
	var moonImage: Image = (load("res://src/worlds/environment/moon_color_cubemap.jpg") as CompressedTexture2D).get_image()
	var starImage: Image = (load("res://src/worlds/environment/star_color_cubemap.png") as CompressedTexture2D).get_image()
	var constellationImage: Image = (load("res://src/worlds/environment/star_constellation_cubemap.jpg") as CompressedTexture2D).get_image()
	const LAYERS: int = 6
	const SIZE: int = 1024
	const Z: Vector2i = Vector2i.ZERO
	
	var moonImages: Array[Image] = []
	var starImages: Array[Image] = []
	var constellationImages: Array[Image] = []
	
	for i: int in LAYERS:
		var r: Rect2i = Rect2i(SIZE * i, 0, SIZE, SIZE)
		
		var img1: Image = Image.create_empty(512, 512, true, Image.FORMAT_RGB8)
		img1.blit_rect(moonImage, Rect2i(512 * i, 0, 512, 512), Z)
		moonImages.push_back(img1)
		var img2: Image = Image.create_empty(SIZE, SIZE, true, Image.FORMAT_RGB8)
		img2.blit_rect(starImage, r, Z)
		starImages.push_back(img2)
		var img3: Image = Image.create_empty(SIZE, SIZE, true, Image.FORMAT_RGB8)
		img3.blit_rect(constellationImage, r, Z)
		constellationImages.push_back(img3)
	
	var moonCubeMap: Cubemap = Cubemap.new()
	moonCubeMap.create_from_images(moonImages)
	var starCubeMap: Cubemap = Cubemap.new()
	starCubeMap.create_from_images(starImages)
	var constellationCubeMap: Cubemap = Cubemap.new()
	constellationCubeMap.create_from_images(constellationImages)
	
	ResourceSaver.save(moonCubeMap, 'res://src/worlds/environment/cb_map/moonCubeMap.res', ResourceSaver.FLAG_COMPRESS)
	ResourceSaver.save(starCubeMap, 'res://src/worlds/environment/cb_map/starCubeMap.res', ResourceSaver.FLAG_COMPRESS)
	ResourceSaver.save(constellationCubeMap, 'res://src/worlds/environment/cb_map/constellationCubeMap.res', ResourceSaver.FLAG_COMPRESS)
	
