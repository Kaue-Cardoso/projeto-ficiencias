extends Control

const TAMANHO_BOTAO := Vector2(58, 58)
const MARGEM := 12.0
const ESPACO := 8.0
const PONTEIRO_MOUSE := -1

var botoes: Dictionary[StringName, Panel] = {}
var ponteiros: Dictionary[int, StringName] = {}


func _ready() -> void:
	botoes[&"move_left"] = criar_botao("←")
	botoes[&"move_right"] = criar_botao("→")
	botoes[&"jump"] = criar_botao("↑")
	resized.connect(posicionar_botoes)
	posicionar_botoes()


func criar_botao(simbolo: String) -> Panel:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.13, 0.14, 0.72)
	estilo.border_color = Color(1, 1, 1, 0.75)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(14)

	var painel := Panel.new()
	painel.size = TAMANHO_BOTAO
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_theme_stylebox_override("panel", estilo)
	add_child(painel)

	var texto := Label.new()
	texto.text = simbolo
	texto.size = TAMANHO_BOTAO
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 28)
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(texto)

	return painel


func posicionar_botoes() -> void:
	var base := size.y - TAMANHO_BOTAO.y - MARGEM
	botoes[&"move_left"].position = Vector2(MARGEM, base)
	botoes[&"move_right"].position = Vector2(MARGEM + TAMANHO_BOTAO.x + ESPACO, base)
	botoes[&"jump"].position = Vector2(size.x - TAMANHO_BOTAO.x - MARGEM, base)


func _input(evento: InputEvent) -> void:
	if evento.device == InputEvent.DEVICE_ID_EMULATION:
		return

	if evento is InputEventScreenTouch:
		atualizar_ponteiro(evento.index, evento.position, evento.pressed and not evento.canceled)
	elif evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		atualizar_ponteiro(PONTEIRO_MOUSE, evento.position, evento.pressed and not evento.canceled)


func atualizar_ponteiro(id: int, posicao: Vector2, pressionado: bool) -> void:
	if not pressionado:
		if ponteiros.has(id):
			soltar_ponteiro(id)
			get_viewport().set_input_as_handled()
		return

	for acao in botoes:
		var botao := botoes[acao]
		var posicao_local := botao.get_global_transform_with_canvas().affine_inverse() * posicao
		if Rect2(Vector2.ZERO, botao.size).has_point(posicao_local):
			if not ponteiros.values().has(acao):
				Input.action_press(acao)
				botao.modulate = Color(0.68, 1.0, 0.74)
			ponteiros[id] = acao
			get_viewport().set_input_as_handled()
			return


func soltar_ponteiro(id: int) -> void:
	var acao := ponteiros[id]
	ponteiros.erase(id)
	if not ponteiros.values().has(acao):
		Input.action_release(acao)
		botoes[acao].modulate = Color.WHITE


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		soltar_botoes()


func _exit_tree() -> void:
	soltar_botoes()


func soltar_botoes() -> void:
	for id in ponteiros.keys():
		soltar_ponteiro(id)
