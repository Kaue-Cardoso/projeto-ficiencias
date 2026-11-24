
extends CharacterBody2D

# =====================================
# CONFIGURACOES
# =====================================

const SPEED = 250.0
const JUMP_FORCE = -450.0
const GRAVITY = 1000.0

const MAX_JUMPS = 2

var jumps: int = 0
var vida: int = 1
var morto: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# =====================================
# INICIO
# =====================================

func _ready() -> void:

	# Identifica o jogador para os inimigos
	add_to_group("jogador")


# =====================================
# MOVIMENTACAO
# =====================================

func _physics_process(delta: float) -> void:

	if morto:
		return

	# Gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		jumps = 0

	# Movimentacao horizontal
	var direction = Input.get_axis(
		"move_left",
		"move_right"
	)

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			SPEED
		)

	# Pulo duplo
	if Input.is_action_just_pressed("jump"):
		if jumps < MAX_JUMPS:
			velocity.y = JUMP_FORCE
			jumps += 1

	move_and_slide()

	# =================================
	# ANIMACOES
	# =================================

	if not is_on_floor():

		if animated_sprite_2d.animation != "jump":
			animated_sprite_2d.play("jump")

	elif abs(velocity.x) > 1:

		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")

	else:

		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")

	# Virar personagem
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0


# =====================================
# RECEBER DANO
# =====================================

func receber_dano(quantidade: int) -> void:

	if morto:
		return

	vida -= quantidade

	print("Vida restante: ", vida)

	if vida <= 0:
		morrer()


# =====================================
# MORTE
# =====================================

func morrer() -> void:

	# Impede morrer duas vezes
	if morto:
		return

	morto = true

	# Para o personagem
	velocity = Vector2.ZERO
	set_physics_process(false)

	# Finaliza o cronometro
	DadosJogo.finalizar_partida()

	print("GAME OVER!")
	print("Pontos: ", DadosJogo.pontos)
	print(
		"Tempo: ",
		DadosJogo.formatar_tempo(
			DadosJogo.tempo_partida
		)
	)

	# Abre a tela de Game Over
	get_tree().call_deferred(
		"change_scene_to_file",
		"res://Cenas/tela_game_over.tscn"
	)
