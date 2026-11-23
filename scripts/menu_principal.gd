class_name MenuPrincipal
extends Control

@onready var boton_jugar: Button = $Centro/VBox/BotonJugar
@onready var boton_salir: Button = $Centro/VBox/BotonSalir


func _ready() -> void:
	boton_jugar.pressed.connect(_al_jugar)
	boton_salir.pressed.connect(_al_salir)


func _al_jugar() -> void:
	DatosJuego.reiniciar_partida()
	get_tree().change_scene_to_file("res://escenas/juego_principal.tscn")


func _al_salir() -> void:
	get_tree().quit()
