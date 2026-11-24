
extends Area2D

signal coletada

var foi_coletado = false


func _ready():
	# Garante que a colisão esteja conectada
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("jogador") and not foi_coletado:
		foi_coletado = true

		# Avisa ao Main que o pinhão foi coletado
		coletada.emit()

		# Remove o pinhão
		queue_free()
