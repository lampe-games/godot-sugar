tool
extends CanvasLayer

enum Effect { NONE, BLURR, PIXELATE, GRAYSCALE, SEPIA }

export (Effect) var effect = Effect.NONE setget _set_effect
export (Resource) var parameters = null

var _overlay_node = null
var _ready_already = false


func _ready():
	_ready_already = true
	if effect == Effect.NONE or parameters == null:
		return
	_setup_overlay()

func _set_effect(a_effect):
	print('_set_effect')
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
	else:
		parameters = null
		_remove_overlay()
	property_list_changed_notify()

func _setup_overlay():
	if _overlay_node == null:
		_overlay_node = ColorRect.new()
		_overlay_node.anchor_right = 1.0
		_overlay_node.anchor_bottom = 1.0
		add_child(_overlay_node)
		# TODO: ignore mouse
	_overlay_node.material = parameters

func _remove_overlay():
	if _overlay_node != null:
		_overlay_node.queue_free()
		remove_child(_overlay_node)
		_overlay_node = null
