
extends Area2D

# =====================================
# CONFIGURACOES
# =====================================

@export var velocidade: float = 450.0
@export var tempo_vida: float = 5.0

# =====================================
# VARIAVEIS
# =====================================

var direcao: Vector2 = Vector2.RIGHT


# =====================================
# INICIO
# =====================================

func _ready() -> void:
	body_entered.connect(_ao_atingir)


# =====================================
# MOVIMENTO DO TIRO
# =====================================

func _physics_process(delta: float) -> void:

	global_position += direcao * velocidade * delta

	# Remove o tiro depois de um tempo
	tempo_vida -= delta

	if tempo_vida <= 0.0:
		queue_free()


# =====================================
# COLISAO COM O JOGADOR
# =====================================

func _ao_atingir(corpo: Node2D) -> void:

	if corpo.is_in_group("jogador"):

		if corpo.has_method("morrer"):
			corpo.morrer()

		queue_free()
