extends Node

const MUSICA_FINAL = preload("res://Hello My Fellos - Crossovers Ost - Snoogle's Music.mp3")
const CENAS_COM_MUSICA_FINAL = ["res://fase_5.tscn", "res://creditos.tscn"]

@onready var musica: AudioStreamPlayer2D = $Musica
@onready var musica_original: AudioStream = musica.stream


func _ready() -> void:
	get_tree().scene_changed.connect(atualizar_musica)
	atualizar_musica.call_deferred()


func atualizar_musica() -> void:
	var cena = get_tree().current_scene
	if cena == null:
		return

	var faixa = musica_original
	if cena.scene_file_path in CENAS_COM_MUSICA_FINAL:
		faixa = MUSICA_FINAL

	# Manter a reprodução ao passar da fase 5 para os créditos.
	if musica.stream == faixa:
		return

	musica.stream = faixa
	musica.play()
