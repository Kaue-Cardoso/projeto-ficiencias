extends "res://Scripts/inimigo_com_aviso.gd"

@export var tempo_total := 10.0

var posicao: Marker2D


func _ready() -> void:
	super._ready()
	await avisar(Color(1.0, 0.15, 0.20))
	await get_tree().create_timer(maxf(tempo_total - tempo_piscando, 0.0), false).timeout
	queue_free()
