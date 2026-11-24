
extends Node2D

# =====================================
# EVOLUCAO DAS FASES
# =====================================

const TELA_FIM_DE_JOGO = preload("res://fim_de_jogo.tscn")

@export_group("Evolucao")

@export var proxima_fase: PackedScene
@export var ano_para_proxima_fase: int = 75_000_000
@export var anos_por_segundo: float = 2_500_000.0
@onready var label_fase: Label = $Label

# =====================================
# GERACAO DE OBSTACULOS
# =====================================

@export_group("Obstaculos")

# Lista configurada pelo Inspetor
@export var cenas_obstaculos: Array[PackedScene] = []

# Tempo entre os sorteios
@export var intervalo_minimo: float = 1.0
@export var intervalo_maximo: float = 2.5

# Velocidade dos inimigos
@export var velocidade: float = 350.0

# Distancia adicional fora da tela
@export var margem_direita: float = 100.0

# Tipo de obstaculos
@export var obstaculos_voadores: bool = false

# Alturas
@export var altura_chao: float = 580.0
@export var altura_minima_voo: float = 150.0
@export var altura_maxima_voo: float = 470.0


@onready var spawn_terrestre: Marker2D = $SpawnTerrestre
@onready var spawn_voador: Marker2D = $SpawnVoador



# =====================================
# VARIAVEIS
# =====================================

var jogo_ativo: bool = true

var cenas_validas: Array[PackedScene] = []



# =====================================
# PERSONAGEM DA FASE
# =====================================

@export_group("Personagem")

@export var cena_jogador: PackedScene

@export var iniciar_modo_nave: bool = false

var jogador: Jogador


@onready var obstaculos = $Obstaculos
@onready var timer = $TimerObstaculos
@onready var label_anos = $Interface/LabelAnos


# =====================================
# INICIAR JOGO
# =====================================

func _ready():

	randomize()

	criar_jogador()
	atualizar_anos()
	
	mostrar_label_fase() # Mostra por 3 segundos

	# Limpar e configurar o timer
	timer.stop()
	timer.one_shot = true

	timer.timeout.connect(_ao_timer_obstaculos)

	# Carregar lista de obstaculos
	for cena in cenas_obstaculos:
		if cena != null:
			cenas_validas.append(cena)

	print("Obstaculos configurados: ", cenas_validas.size())

	if cenas_validas.is_empty():

		push_warning(
            "Adicione obstaculos no Inspetor!"
		)

	else:

		programar_proximo_obstaculo()



# =====================================
# CONTAGEM DOS ANOS
# =====================================

func _process(delta):

	if not jogo_ativo:
		return

	if EstadoJogo.anos > 0:

		EstadoJogo.anos -= anos_por_segundo * delta

		EstadoJogo.anos = maxf(
			EstadoJogo.anos,
			0.0
		)

	atualizar_anos()

	# Evoluir para proxima fase
	if proxima_fase != null:

		if EstadoJogo.anos <= ano_para_proxima_fase:
			avancar_fase()


# =====================================
# ATUALIZAR ANOS
# =====================================

func atualizar_anos():

	var numero = int(EstadoJogo.anos)

	if numero <= 0:

		label_anos.text = "Anos: 0 (Tempo atual)"

	else:

		label_anos.text = "Anos: " + formatar_numero(numero)


func formatar_numero(numero: int) -> String:

	var texto = str(numero)
	var i = texto.length() - 3

	while i > 0:
		texto = texto.insert(i, ".")
		i -= 3

	return texto


# =====================================
# TIMER ALEATORIO
# =====================================

func programar_proximo_obstaculo():

	if not jogo_ativo:
		return

	if cenas_validas.is_empty():
		return

	var tempo_min = maxf(
		0.1,
		minf(intervalo_minimo, intervalo_maximo)
	)

	var tempo_max = maxf(
		tempo_min,
		maxf(intervalo_minimo, intervalo_maximo)
	)

	var tempo_sorteado = randf_range(
		tempo_min,
		tempo_max
	)

	timer.start(tempo_sorteado)


# =====================================
# TIMER TERMINOU
# =====================================

func _ao_timer_obstaculos():

	if not jogo_ativo:
		return

	criar_obstaculo()

	# Preparar proximo sorteio
	programar_proximo_obstaculo()


# =====================================
# CRIAR OBSTACULO ALEATORIO
# =====================================



func criar_obstaculo():

	if not jogo_ativo:
		return

	if cenas_validas.is_empty():
		return

	# Sortear obstaculo
	var cena_escolhida = cenas_validas.pick_random()

	# Criar instancia
	var instancia = cena_escolhida.instantiate()

	if not instancia is Area2D:
		push_error("Obstaculo precisa ser Area2D!")
		instancia.free()
		return

	var obstaculo = instancia as Area2D

	# Adicionar na cena
	obstaculos.add_child(obstaculo)

	# Aplicar velocidade
	obstaculo.set("velocidade", velocidade)

	# Verificar se e voador
	if obstaculo.get("voador") == true:

		# Nascer no Marker2D voador
		obstaculo.global_position = spawn_voador.global_position

	else:

		# Nascer no Marker2D terrestre
		obstaculo.global_position = spawn_terrestre.global_position

	print("Obstaculo criado: ", obstaculo.name)



# =====================================
# EVOLUIR DE FASE
# =====================================

func avancar_fase():

	if not jogo_ativo:
		return

	jogo_ativo = false

	timer.stop()

	get_tree().call_deferred(
		"change_scene_to_packed",
		proxima_fase
	)


# =====================================
# GAME OVER
# =====================================

func game_over():

	if not jogo_ativo:
		return

	jogo_ativo = false

	timer.stop()

	obstaculos.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	$Interface.call_deferred("add_child", TELA_FIM_DE_JOGO.instantiate())
	
	
	
	
# =====================================
# CRIAR PERSONAGEM DA FASE
# =====================================

func criar_jogador():

	if cena_jogador == null:
		push_error("Configure a cena do jogador no Inspetor!")
		return

	var instancia = cena_jogador.instantiate()

	if not instancia is Jogador:
		push_error("A cena precisa utilizar jogador.gd!")
		instancia.free()
		return

	jogador = instancia as Jogador

	add_child(jogador)

	jogador.global_position = $SpawnJogador.global_position

	# Conectar sinal de morte
	jogador.morreu.connect(game_over)

	# Configurar modo de movimento
	if iniciar_modo_nave:
		jogador.transformar_em_nave()


# =====================================
# MOSTRAR NOME DA FASE
# =====================================

func mostrar_label_fase():
	label_fase.show()

	await get_tree().create_timer(3.0).timeout

	if is_instance_valid(label_fase):
		label_fase.hide()
