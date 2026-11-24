
extends Area2D

@export var velocidade: float = 350.0
@export var margem_esquerda: float = 120.0

# Marque no Inspetor se o obstaculo voa
@export var voador: bool = false


func _ready():
	body_entered.connect(_ao_colidir)


func _process(delta):

	global_position.x -= velocidade * delta

	if global_position.x < -margem_esquerda:
		queue_free()


func _ao_colidir(corpo):

	if corpo.has_method("morrer"):
		corpo.morrer()
