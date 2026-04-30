class_name HealthBarComponent extends Sprite3D

@export var health_component: HealthComponent
@export var visual_body: MeshInstance3D
@export var height_offset: float = 0.5
@export var bar_size: Vector2i = Vector2i(256, 40)

var sub_viewport: SubViewport = SubViewport.new()
var bar: TextureProgressBar = TextureProgressBar.new()

func _ready() -> void:
	# if no health component, remove from scene
	if health_component == null:
		queue_free()
		return	
	
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	if visual_body != null:
		position_on_top()
	
	# add the progress bar
	add_child(sub_viewport)
	sub_viewport.add_child(bar)
	texture = sub_viewport.get_texture()
	
	# setup the parameters
	sub_viewport.size = bar_size
	sub_viewport.transparent_bg = true
	bar.size = bar_size
	bar.max_value = health_component.max_health
	bar.value = health_component.current_health
	
	# create the bar texture
	var under: GradientTexture1D = GradientTexture1D.new()
	var progress: GradientTexture1D = GradientTexture1D.new()
	
	under.gradient = Gradient.new()
	progress.gradient = Gradient.new()
	
	# remove in inverse order, because the array resizes
	# and set_color on an existing point doesn't seem to work
	under.gradient.remove_point(1)
	under.gradient.remove_point(0)
	under.gradient.add_point(0, Color(0,0,0,0.5))
	
	progress.gradient.remove_point(1)
	progress.gradient.remove_point(0)
	progress.gradient.add_point(0, Color.RED)
	progress.gradient.add_point(0.5, Color.YELLOW)
	progress.gradient.add_point(1, Color.GREEN)
	
	bar.texture_under = under
	bar.texture_progress = progress
	
	# connect the bar to the health event
	health_component.health_changed.connect(health_changed)

# get the top center of the visual body
func position_on_top() -> void:
	var aabb: AABB = visual_body.get_aabb()
	# center
	position = aabb.position + aabb.size * 0.5
	# offset on top
	position.y += height_offset
	
func health_changed(current_health: int, max_health: int) -> void:
	bar.value = current_health
	# show if not full health
	bar.visible = current_health != max_health
	print("Bar: %d / %d" % [current_health, max_health])
