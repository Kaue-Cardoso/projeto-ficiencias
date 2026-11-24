extends "res://Scripts/inimigo_com_aviso.gd"

@export var tempo_queda := 3.0
@export var margem_lateral := 30.0


func _ready() -> void:
	super._ready()

	var tela := get_viewport_rect()
	var para_mundo := get_canvas_transform().affine_inverse()
	var limites_sprite := sprite.get_global_transform_with_canvas() * sprite.get_rect()
	var origem_tela := get_global_transform_with_canvas().origin
	var topo_sprite := limites_sprite.position.y - origem_tela.y
	var x := randf_range(tela.position.x + margem_lateral, tela.end.x - margem_lateral)
	global_position = para_mundo * Vector2(x, tela.position.y - topo_sprite + 2.0)
	var destino := para_mundo * Vector2(x, tela.end.y - topo_sprite + 2.0)

	await avisar(Color.WHITE)

	var queda := create_tween()
	queda.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	queda.tween_property(self, "global_position", destino, tempo_queda)
	await queda.finished
	queue_free()
