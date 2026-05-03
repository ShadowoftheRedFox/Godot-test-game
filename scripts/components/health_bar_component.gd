class_name HealthBarComponent extends Sprite3D

@export var health_component: HealthComponent
@export var visual_body: MeshInstance3D
@export var height_offset: float = 0.8
@export var bar_size: Vector2i = Vector2i(256, 40)
@export var oof: TextureRect

var sub_viewport: SubViewport = SubViewport.new()
var bar: ProgressBar = ProgressBar.new()
var progress_gradient: Gradient = Gradient.new()

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
	
	# create the bar texture gradient
	progress_gradient.add_point(0, Color.RED)
	progress_gradient.add_point(0.5, Color.YELLOW)
	progress_gradient.add_point(1, Color.GREEN)
	progress_gradient.remove_point(0)
	progress_gradient.remove_point(0)
	
	# create the bar style
	var under: StyleBoxFlat = StyleBoxFlat.new()
	under.bg_color = Color(0, 0, 0, 0.5)
	# will be changed at the next health changed
	var over: StyleBoxFlat = StyleBoxFlat.new()
	bar.show_percentage = false
	
	bar.add_theme_stylebox_override("background", under)
	bar.add_theme_stylebox_override("fill", over)
	
	# connect the bar to the health event
	health_component.health_changed.connect(health_changed)
	# resend the current heath to reset
	health_changed(health_component.current_health, health_component.max_health)

# get the top center of the visual body
func position_on_top() -> void:
	var aabb: AABB = visual_body.get_aabb()
	# center
	position = aabb.position + aabb.size * 0.5
	# offset on top
	position.y += height_offset
	
func health_changed(current_health: int, max_health: int) -> void:
	var current_color: Color = progress_gradient.sample(float(health_component.current_health) / float(health_component.max_health))
	(bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = current_color
	
	bar.value = current_health
	# show if not full health
	bar.visible = current_health != max_health
