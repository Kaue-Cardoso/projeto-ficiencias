extends Area2D

const MATERIAL_AVISO = preload("res://Cenas/aviso_inimigo.gdshader")
const INTERVALO_PISCA := 0.125

@export var tempo_piscando := 2.0

@onready var sprite: Sprite2D = $Sprite2D

var pode_dar_dano := false


func _ready() -> void:
	body_entered.connect(causar_dano)


func avisar(cor: Color) -> void:
	var aviso := ShaderMaterial.new()
	aviso.shader = MATERIAL_AVISO
	aviso.set_shader_parameter("cor_aviso", cor)
	var material_original := sprite.material
	sprite.material = aviso

	var efeito := create_tween()
	efeito.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	efeito.tween_method(atualizar_aviso.bind(aviso), 0.0, tempo_piscando, tempo_piscando)
	await efeito.finished
	sprite.material = material_original
	pode_dar_dano = true

	for corpo in get_overlapping_bodies():
		causar_dano(corpo)


func atualizar_aviso(tempo: float, aviso: ShaderMaterial) -> void:
	aviso.set_shader_parameter("pisca", int(tempo / INTERVALO_PISCA) % 2 == 0)


func causar_dano(corpo: Node2D) -> void:
	if pode_dar_dano and corpo.is_in_group("jogador") and corpo.has_method("receber_dano"):
		corpo.receber_dano(1)
