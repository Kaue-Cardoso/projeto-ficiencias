
extends Control

@onready var painel = $CenterContainer/PanelContainer/VBoxContainer
@onready var paineldentro = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer


@onready var label_pontos: Label = paineldentro.get_node("LabelPontos")
@onready var label_tempo: Label = paineldentro.get_node("LabelTempo")
@onready var campo_nome: LineEdit = painel.get_node("CampoNome")
@onready var botao_salvar: Button = painel.get_node("BotaoSalvar")
@onready var label_status: Label = painel.get_node("LabelStatus")
@onready var lista_ranking: VBoxContainer = painel.get_node("ListaRanking")
@onready var botao_reiniciar: Button = painel.get_node("BotaoReiniciar")


func _ready() -> void:

	# Exibe os dados da partida
	label_pontos.text = "Pontos: %d" % DadosJogo.pontos

	label_tempo.text = "Tempo: %s" % DadosJogo.formatar_tempo(
		DadosJogo.tempo_partida
	)

	campo_nome.placeholder_text = "Digite seu nome"
	campo_nome.max_length = 20
	if not DisplayServer.is_touchscreen_available():
		campo_nome.grab_focus()

	botao_salvar.pressed.connect(salvar)
	botao_reiniciar.pressed.connect(reiniciar)

	atualizar_ranking()


# =====================================
# SALVAR
# =====================================

func salvar() -> void:

	var nome = campo_nome.text.strip_edges()

	if nome.is_empty():
		label_status.text = "Digite seu nome!"
		return

	DadosJogo.registrar_resultado(nome)

	label_status.text = "Resultado registrado!"

	botao_salvar.disabled = true
	campo_nome.editable = false

	atualizar_ranking()


# =====================================
# ATUALIZAR TOP 5
# =====================================

func atualizar_ranking() -> void:

	# Limpa os registros antigos da interface
	for filho in lista_ranking.get_children():
		filho.queue_free()

	var quantidade = min(
		5,
		DadosJogo.ranking.size()
	)

	if quantidade == 0:
		var vazio = Label.new()
		vazio.text = "Nenhum resultado ainda!"
		lista_ranking.add_child(vazio)
		return

	for i in range(quantidade):

		var resultado = DadosJogo.ranking[i]

		var nome = str(resultado["nome"])
		var pontos = int(resultado["pontos"])
		var tempo = float(resultado["tempo"])

		var linha = Label.new()

		linha.text = "%dº  %s | %d pts | %s" % [
			i + 1,
			nome,
			pontos,
			DadosJogo.formatar_tempo(tempo)
		]

		lista_ranking.add_child(linha)


# =====================================
# REINICIAR
# =====================================

func reiniciar() -> void:

	DadosJogo.iniciar_partida()

	get_tree().change_scene_to_file(
		"res://Cenas/main.tscn"
	)
