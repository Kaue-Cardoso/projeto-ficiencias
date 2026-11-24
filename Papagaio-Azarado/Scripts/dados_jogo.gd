
extends Node

const ARQUIVO = "user://ranking.json"

var pontos: int = 0
var tempo_partida: float = 0.0
var partida_ativa: bool = false

var ranking: Array[Dictionary] = []


func _ready() -> void:
	carregar_ranking()


func _process(delta: float) -> void:
	if partida_ativa:
		tempo_partida += delta


# INICIAR PARTIDA
func iniciar_partida() -> void:
	pontos = 0
	tempo_partida = 0.0
	partida_ativa = true

func reiniciar() -> void:

	# Zera pontos e tempo
	DadosJogo.iniciar_partida()

	# Volta ao jogo de coletar pinhoes
	get_tree().change_scene_to_file(
		"res://main.tscn"
	)

# FINALIZAR PARTIDA
func finalizar_partida() -> void:
	partida_ativa = false


# ADICIONAR PONTOS
func adicionar_pontos(valor: int) -> void:
	pontos += valor


# FORMATAR TEMPO EM MM:SS
func formatar_tempo(valor: float) -> String:
	var total = int(valor)
	var minutos = int(total / 60)
	var segundos = total % 60

	return "%02d:%02d" % [minutos, segundos]


# REGISTRAR RESULTADO
func registrar_resultado(nome: String) -> void:

	nome = nome.strip_edges()

	if nome.is_empty():
		return

	var resultado = {
		"nome": nome.substr(0, 20),
		"pontos": pontos,
		"tempo": tempo_partida
	}

	ranking.append(resultado)

	ordenar_ranking()
	salvar_ranking()


# ORDENAR POR PONTOS E DEPOIS TEMPO
func ordenar_ranking() -> void:
	ranking.sort_custom(comparar_resultados)


func comparar_resultados(
	a: Dictionary,
	b: Dictionary
) -> bool:

	if int(a["pontos"]) == int(b["pontos"]):
		return float(a["tempo"]) > float(b["tempo"])

	return int(a["pontos"]) > int(b["pontos"])

# SALVAR EM ARQUIVO
func salvar_ranking() -> void:

	var arquivo = FileAccess.open(
		ARQUIVO,
		FileAccess.WRITE
	)

	if arquivo == null:
		push_error("Erro ao salvar ranking!")
		return

	arquivo.store_string(JSON.stringify(ranking))
	arquivo.close()


# CARREGAR ARQUIVO
func carregar_ranking() -> void:

	ranking.clear()

	if not FileAccess.file_exists(ARQUIVO):
		return

	var arquivo = FileAccess.open(
		ARQUIVO,
		FileAccess.READ
	)

	if arquivo == null:
		return

	var dados = JSON.parse_string(
		arquivo.get_as_text()
	)

	arquivo.close()

	if dados is Array:
		for item in dados:
			if item is Dictionary:
				if (
					item.has("nome")
					and item.has("pontos")
					and item.has("tempo")
				):
					ranking.append(item)

	ordenar_ranking()
