
extends Node2D

# =====================================
# CONFIGURACOES
# =====================================

var pontos: int = 0

@export var cena_pinhao: PackedScene

@export var limite_esquerdo: float = 50
@export var limite_direito: float = 1000
@export var limite_superior: float = 100
@export var limite_inferior: float = 500


# =====================================
# INICIO DA PARTIDA
# =====================================

func _ready() -> void:

	randomize()

	# Inicia a pontuacao e o cronometro
	if not DadosJogo.partida_ativa:
		DadosJogo.iniciar_partida()

	# Sincroniza os pontos
	pontos = DadosJogo.pontos

	atualizar_pontuacao()

	# Cria o primeiro pinhao
	gerar_pinhao.call_deferred()


# =====================================
# ADICIONAR PONTOS
# =====================================

func adicionar_ponto() -> void:

	# Adiciona ao gerenciador global
	DadosJogo.adicionar_pontos(1)

	# Atualiza a variavel local
	pontos = DadosJogo.pontos

	atualizar_pontuacao()


# =====================================
# ATUALIZAR INTERFACE
# =====================================

func atualizar_pontuacao() -> void:

	$CanvasLayer/PontuacaoLabel.text = (
		"Pontos: " + str(pontos)
	)


# =====================================
# PINHAO COLETADO
# =====================================

func _on_pinhao_coletada() -> void:

	print("Pinhao coletado!")

	adicionar_ponto()

	# Cria outro pinhao
	gerar_pinhao.call_deferred()


# =====================================
# GERAR PINHAO
# =====================================

func gerar_pinhao() -> void:

	if cena_pinhao == null:
		push_error(
			"ERRO: A cena do pinhao nao foi configurada!"
		)
		return

	# Instancia o pinhao
	var novo_pinhao = cena_pinhao.instantiate()

	# Posicao aleatoria
	var x = randf_range(
		limite_esquerdo,
		limite_direito
	)

	var y = randf_range(
		limite_superior,
		limite_inferior
	)

	novo_pinhao.position = Vector2(x, y)

	# Conecta o sinal de coleta
	novo_pinhao.connect(
		"coletada",
		_on_pinhao_coletada
	)

	# Adiciona na cena
	add_child(novo_pinhao)

	print(
		"Novo pinhao criado em: ",
		novo_pinhao.position
	)
