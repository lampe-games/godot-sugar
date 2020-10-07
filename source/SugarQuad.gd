tool
extends MeshInstance

enum Effect { NONE, DARKEN, DEPTH, OUTLINE }

export (Effect) var effect = Effect.NONE setget _set_effect
export (Resource) var parameters = null


func _set_effect(a_effect):
	effect = a_effect
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
	property_list_changed_notify()
