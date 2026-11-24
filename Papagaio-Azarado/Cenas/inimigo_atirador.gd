
extends Area2D

# =====================================
# CONFIGURACOES
# =====================================

@export var jogador: CharacterBody2D
@export var cena_tiro: PackedScene

@export var tempo_visivel: float = 8.0

@export var primeiro_tiro: float = 3.0
@export var segundo_tiro: float = 6.0

@export var tempo_para_matar: float = 3.0

@export var margem_esquerda: float = 30.0
@export var margem_vertical: float = 35.0

# =====================================
# VARIAVEIS
# =====================================

@onready var ponto_tiro: Marker2D = $PontoTiro

var tempo_aparecido: float = 0.0
var tempo_encostado: float = 0.0

var atirou_1: bool = false
var atirou_2: bool = false

# =====================================
# INICIO
# =====================================

func _ready() -> void:

	if jogador == null:
		push_error("Configure o Jogador!")
		return

	if cena_tiro == null:
		push_error("Configure a Cena Tiro!")
		return

	posicionar_aleatoriamente()


# =====================================
# PROCESSAMENTO
# =====================================

func _physics_process(delta: float) -> void:
	tempo_aparecido += delta

	if not atirou_1 and tempo_aparecido >= primeiro_tiro:
		atirar()
		atirou_1 = true

	if not atirou_2 and tempo_aparecido >= segundo_tiro:
		atirar()
		atirou_2 = true

	verificar_contato(delta)

	if tempo_aparecido >= tempo_visivel:
		queue_free()


func posicionar_aleatoriamente() -> void:

	var tamanho_tela = get_viewport_rect().size

	# Sorteia uma posicao no lado esquerdo
	var x = randf_range(
		margem_esquerda,
		maxf(margem_esquerda, tamanho_tela.x * 0.18)
	)

	var y = randf_range(
		margem_vertical,
		maxf(
			margem_vertical,
			tamanho_tela.y - margem_vertical
		)
	)

	# Converte coordenadas da tela para o mundo
	global_position = (
		get_canvas_transform().affine_inverse()
		* Vector2(x, y)
	)


# =====================================
# SISTEMA DE TIROS
# =====================================

func atirar() -> void:

	if jogador == null:
		return

	if cena_tiro == null:
		return

	var tiro = cena_tiro.instantiate() as Area2D

	if tiro == null:
		return

	# Direcao do tiro ate o jogador
	var direcao = (
		jogador.global_position
		- ponto_tiro.global_position
	).normalized()

	if direcao == Vector2.ZERO:
		direcao = Vector2.RIGHT

	# Configura a direcao
	tiro.set("direcao", direcao)

	# Adiciona o tiro na fase
	get_tree().current_scene.add_child(tiro)

	# Posicao inicial do tiro
	tiro.global_position = ponto_tiro.global_position

	# Gira o tiro na direcao do jogador
	tiro.rotation = direcao.angle()


# =====================================
# CONTATO COM O JOGADOR
# =====================================

func verificar_contato(delta: float) -> void:

	var encostando: bool = false

	for corpo in get_overlapping_bodies():

		if corpo == jogador:
			encostando = true
			break

	if encostando:

		tempo_encostado += delta

		# MORRE APOS 3 SEGUNDOS ENCOSTADO
		if tempo_encostado >= tempo_para_matar:

			tempo_encostado = 0.0

			if jogador.has_method("morrer"):
				jogador.morrer()

	else:

		# Saiu do contato, zera a contagem
		tempo_encostado = 0.0
