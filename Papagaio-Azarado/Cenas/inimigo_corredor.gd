extends "res://Scripts/inimigo_com_aviso.gd"

@export var chao: Marker2D
@export var tempo_corrida := 2.0
@export var margem_direita := 5.0


func _ready() -> void:
	super._ready()

	var tela := get_viewport_rect()
	var para_mundo := get_canvas_transform().affine_inverse()
	var limites_sprite := sprite.get_global_transform_with_canvas() * sprite.get_rect()
	var metade_largura := limites_sprite.size.x / 2.0
	var metade_altura := sprite.get_rect().size.y * absf(sprite.global_scale.y) / 2.0

	var inicio := para_mundo * Vector2(tela.end.x - metade_largura - margem_direita, 0)
	var fim := para_mundo * Vector2(tela.position.x - metade_largura - 2.0, 0)
	global_position = Vector2(inicio.x, chao.global_position.y - metade_altura)

	await avisar(Color(0.20, 1.0, 0.30))

	var corrida := create_tween()
	corrida.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	corrida.tween_property(self, "global_position:x", fim.x, tempo_corrida)
	await corrida.finished
	queue_free()
