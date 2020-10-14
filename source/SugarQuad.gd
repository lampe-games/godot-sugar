tool
extends MeshInstance

enum Effect { NONE, DARKEN, DEPTH, OUTLINE, PALETTE }

export (Effect) var effect = Effect.NONE setget _set_effect
export (bool) var randomize_parameters = false setget _set_randomize_parameters
export (Resource) var parameters = null

var _ready_already = false


func _ready():
	_ready_already = true
	if effect == Effect.NONE or parameters == null:
		return
	material_override = parameters


func _set_effect(a_effect):
	effect = a_effect
	if not Engine.is_editor_hint() or not _ready_already:
		return
	if effect == Effect.NONE:
		parameters = null
		material_override = null
	if effect == Effect.DARKEN:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/3d/darken.shader")
		material_override = parameters
	if effect == Effect.DEPTH:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/3d/depth.shader")
		material_override = parameters
	if effect == Effect.OUTLINE:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/3d/outline.shader")
		material_override = parameters
	if effect == Effect.PALETTE:
		parameters = ShaderMaterial.new()
		parameters.shader = preload("res://addons/godot-sugar/source/shaders/3d/palette.shader")
		var gradient_texture = preload("res://addons/godot-sugar/assets/palettes/black_n_white_2c.tres")
		parameters.set_shader_param('palette_texture', gradient_texture)
		var pattern_texture = preload("res://addons/godot-sugar/assets/bayer_dither_pattern_8x8.png")
		parameters.set_shader_param('dither_pattern_texture', pattern_texture)
		material_override = parameters
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
