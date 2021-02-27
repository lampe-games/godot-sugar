tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"SugarLayer",
		"CanvasLayer",
		preload("./source/SugarLayer.gd"),
		preload("./assets/icons/sugar_layer.svg")
	)
	add_custom_type(
		"SugarQuad3D",
		"MeshInstance",
		preload("./source/SugarQuad3D.gd"),
		preload("./assets/icons/sugar_quad_3d.svg")
	)


func _exit_tree():
	remove_custom_type("SugarQuad3D")
	remove_custom_type("SugarLayer")
