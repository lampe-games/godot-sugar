tool
extends CanvasLayer

enum Effect { NONE, BLURR, PIXELATE, GRAYSCALE, SEPIA, GRAIN, PALETTE }

export (Effect) var effect = Effect.NONE setget _set_effect
export (bool) var randomize_parameters = false setget _set_randomize_parameters
export (Resource) var parameters = null

var _overlay_node = null
var _ready_already = false


func _ready():
	_ready_already = true
	if effect == Effect.NONE or parameters == null:
		return
	_setup_overlay()


func _set_effect(a_effect):
	effect = a_effect
	if not Engine.is_editor_hint() or not _ready_already:
		return
	if effect == Effect.BLURR:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/blurr.shader")
		_setup_overlay()
	elif effect == Effect.PIXELATE:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/pixelate.shader")
		_setup_overlay()
	elif effect == Effect.GRAYSCALE:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/grayscale.shader")
		_setup_overlay()
	elif effect == Effect.SEPIA:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/sepia.shader")
		_setup_overlay()
	elif effect == Effect.GRAIN:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/grain.shader")
		var noise_texture = NoiseTexture.new()
		noise_texture.noise = OpenSimplexNoise.new()
		noise_texture.noise.period = 0.1
		noise_texture.noise.persistence = 0.0
		parameters.set_shader_param('grain_texture', noise_texture)
		var gradient_texture = GradientTexture.new()
		gradient_texture.gradient = Gradient.new()
		parameters.set_shader_param('grain_gradient_texture', gradient_texture)
		_setup_overlay()
	elif effect == Effect.PALETTE:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/2d/palette.shader")
		var gradient_texture = preload("res://addons/godot-sugar/assets/palettes/black_n_white.tres")
		parameters.set_shader_param('palette_texture', gradient_texture)
		var pattern_texture = preload("res://addons/godot-sugar/assets/bayer_dither_pattern_8x8.png")
		parameters.set_shader_param('dither_pattern_texture', pattern_texture)
		_setup_overlay()
	else:
		parameters = null
		_remove_overlay()
	property_list_changed_notify()


func _set_randomize_parameters(_value):
	if effect != Effect.PALETTE or parameters == null:
		return
	var palette_colors_num = parameters.get_shader_param('palette_colors')
	var gradient_texture = GradientTexture.new()
	gradient_texture.gradient = Gradient.new()
	for _i in range(palette_colors_num - 2):
		gradient_texture.gradient.add_point(1.0, Color.black)
	var rng = RandomNumberGenerator.new()
	rng.seed = OS.get_ticks_msec()
	var random_colors = []
	for _i in range(palette_colors_num):
		random_colors.append(
			Color(rng.randf_range(0.0, 1.0), rng.randf_range(0.0, 1.0), rng.randf_range(0.0, 1.0))
		)
	if rng.seed % 2 == 0:
		random_colors[0] = Color.black
		random_colors[1] = Color.white
	for i in range(palette_colors_num):
		gradient_texture.gradient.set_offset(i, i * 1.0 / float(palette_colors_num - 1))
		gradient_texture.gradient.set_color(i, random_colors[i])
	parameters.set_shader_param('palette_texture', gradient_texture)
	property_list_changed_notify()


func _setup_overlay():
	if _overlay_node == null:
		_overlay_node = ColorRect.new()
		_overlay_node.anchor_right = 1.0
		_overlay_node.anchor_bottom = 1.0
		_overlay_node.mouse_filter = _overlay_node.MOUSE_FILTER_IGNORE
		add_child(_overlay_node)
	_overlay_node.material = parameters


func _remove_overlay():
	if _overlay_node != null:
		_overlay_node.queue_free()
		remove_child(_overlay_node)
		_overlay_node = null
