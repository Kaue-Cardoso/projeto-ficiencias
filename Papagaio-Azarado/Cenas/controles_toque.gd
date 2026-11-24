extends Control

const TAMANHO_BOTAO := Vector2(58, 58)
const MARGEM := 12.0
const ESPACO := 8.0

var esquerda: TouchScreenButton
var direita: TouchScreenButton
var pulo: TouchScreenButton


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	esquerda = criar_botao(&"move_left", "←")
	direita = criar_botao(&"move_right", "→")
	pulo = criar_botao(&"jump", "↑")
	resized.connect(posicionar_botoes)
	posicionar_botoes()


func criar_botao(acao: StringName, simbolo: String) -> TouchScreenButton:
	var botao := TouchScreenButton.new()
	botao.action = acao
	var area := RectangleShape2D.new()
	area.size = TAMANHO_BOTAO
	botao.shape = area
	botao.shape_centered = false
	botao.shape_visible = false
	add_child(botao)

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.13, 0.14, 0.72)
	estilo.border_color = Color(1, 1, 1, 0.75)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(14)

	var painel := Panel.new()
	painel.size = TAMANHO_BOTAO
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_theme_stylebox_override("panel", estilo)
	botao.add_child(painel)

	var texto := Label.new()
	texto.text = simbolo
	texto.size = TAMANHO_BOTAO
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 28)
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(texto)

	botao.pressed.connect(func() -> void: painel.modulate = Color(0.68, 1.0, 0.74))
	botao.released.connect(func() -> void: painel.modulate = Color.WHITE)
	return botao


func posicionar_botoes() -> void:
	var base := size.y - TAMANHO_BOTAO.y - MARGEM
	esquerda.position = Vector2(MARGEM, base)
	direita.position = Vector2(MARGEM + TAMANHO_BOTAO.x + ESPACO, base)
	pulo.position = Vector2(size.x - TAMANHO_BOTAO.x - MARGEM, base)
