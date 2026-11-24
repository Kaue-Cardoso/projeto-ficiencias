extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/main.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
