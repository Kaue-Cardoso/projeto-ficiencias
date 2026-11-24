extends Node2D

const BOTA = preload("res://Cenas/inimigo_bota.tscn")
const GAIOLA = preload("res://Cenas/inimigo gaiola.tscn")
const ONCA = preload("res://Cenas/inimigo_onca.tscn")
const CACADOR = preload("res://Cenas/inimigo_cacador.tscn")

@export var chao: Marker2D
@export var jogador: CharacterBody2D
@export var posicoes_gaiola: Array[Marker2D] = []
@export var intervalo_progressao := 10.0
@export var intervalo_surgimento := 0.65

var espera := 0.0


func _physics_process(delta: float) -> void:
	if not DadosJogo.partida_ativa:
		return

	espera = maxf(espera - delta, 0.0)
	var limite := 1 + floori(DadosJogo.tempo_partida / intervalo_progressao)
	if espera == 0.0 and get_child_count() < limite:
		gerar_inimigo()
		espera = intervalo_surgimento


func gerar_inimigo() -> void:
	var opcoes: Array[PackedScene] = [BOTA]
	var posicoes_livres := posicoes_gaiola.duplicate()
	var cacador_presente := false
	var onca_avisando := false

	for inimigo in get_children():
		var caminho := inimigo.scene_file_path
		if caminho == GAIOLA.resource_path:
			posicoes_livres.erase(inimigo.posicao)
		elif caminho == ONCA.resource_path:
			onca_avisando = onca_avisando or not inimigo.pode_dar_dano
		elif caminho == CACADOR.resource_path:
			cacador_presente = true

	if not posicoes_livres.is_empty():
		opcoes.append(GAIOLA)
	if not onca_avisando:
		opcoes.append(ONCA)
	if not cacador_presente:
		opcoes.append(CACADOR)

	var cena: PackedScene = opcoes.pick_random()
	var inimigo := cena.instantiate() as Node2D
	if cena == GAIOLA:
		var marcador: Marker2D = posicoes_livres.pick_random()
		inimigo.posicao = marcador
		inimigo.position = to_local(marcador.global_position)
	elif cena == ONCA:
		inimigo.chao = chao
	elif cena == CACADOR:
		inimigo.jogador = jogador
	add_child(inimigo)
