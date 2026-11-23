class_name Tienda
extends Control

@onready var label_titulo: Label = $Margen/VBox/LabelTitulo
@onready var label_dinero: Label = $Margen/VBox/LabelDinero
@onready var boton_fuerza: Button = $Margen/VBox/SeccionMejoras/BotonFuerza
@onready var boton_carrete: Button = $Margen/VBox/SeccionMejoras/BotonCarrete
@onready var boton_carrete_auto: Button = $Margen/VBox/SeccionPotenciadores/BotonCarreteAuto
@onready var boton_tiempo_extra: Button = $Margen/VBox/SeccionPotenciadores/BotonTiempoExtra
@onready var boton_cebo_dorado: Button = $Margen/VBox/SeccionPotenciadores/BotonCeboDorado
@onready var boton_siguiente: Button = $Margen/VBox/PieBotones/BotonSiguiente
@onready var boton_menu: Button = $Margen/VBox/PieBotones/BotonMenu


func _ready() -> void:
	boton_fuerza.pressed.connect(_al_comprar_fuerza)
	boton_carrete.pressed.connect(_al_comprar_carrete)
	boton_carrete_auto.pressed.connect(_al_comprar_carrete_auto)
	boton_tiempo_extra.pressed.connect(_al_comprar_tiempo_extra)
	boton_cebo_dorado.pressed.connect(_al_comprar_cebo_dorado)
	boton_siguiente.pressed.connect(_al_siguiente_nivel)
	boton_menu.pressed.connect(_al_volver_menu)

	_actualizar_ui()


func _actualizar_ui() -> void:
	label_titulo.text = "TIENDA - Nivel %d completado" % DatosJuego.nivel_actual
	label_dinero.text = "Dinero disponible: $%d" % DatosJuego.dinero_total

	if DatosJuego.nivel_fuerza >= DatosJuego.MAX_NIVEL_MEJORA:
		boton_fuerza.text = "Fuerza de Caña (Nv. MAX)"
		boton_fuerza.disabled = true
	else:
		var costo_f := DatosJuego.obtener_costo_fuerza()
		boton_fuerza.text = "Fuerza de Caña (Nv. %d/%d) - $%d" % [
			DatosJuego.nivel_fuerza,
			DatosJuego.MAX_NIVEL_MEJORA,
			costo_f,
		]
		boton_fuerza.disabled = DatosJuego.dinero_total < costo_f

	if DatosJuego.nivel_carrete >= DatosJuego.MAX_NIVEL_MEJORA:
		boton_carrete.text = "Velocidad de Carrete (Nv. MAX)"
		boton_carrete.disabled = true
	else:
		var costo_c := DatosJuego.obtener_costo_carrete()
		boton_carrete.text = "Velocidad de Carrete (Nv. %d/%d) - $%d" % [
			DatosJuego.nivel_carrete,
			DatosJuego.MAX_NIVEL_MEJORA,
			costo_c,
		]
		boton_carrete.disabled = DatosJuego.dinero_total < costo_c

	boton_carrete_auto.text = "Carrete Automático (Stock: %d) - $%d" % [
		DatosJuego.cant_carrete_auto,
		DatosJuego.PRECIO_CARRETE_AUTO,
	]
	boton_carrete_auto.disabled = DatosJuego.dinero_total < DatosJuego.PRECIO_CARRETE_AUTO

	boton_tiempo_extra.text = "Tiempo Extra +10s (Stock: %d) - $%d" % [
		DatosJuego.cant_tiempo_extra,
		DatosJuego.PRECIO_TIEMPO_EXTRA,
	]
	boton_tiempo_extra.disabled = DatosJuego.dinero_total < DatosJuego.PRECIO_TIEMPO_EXTRA

	boton_cebo_dorado.text = "Cebo Dorado x2$ (Stock: %d) - $%d" % [
		DatosJuego.cant_cebo_dorado,
		DatosJuego.PRECIO_CEBO_DORADO,
	]
	boton_cebo_dorado.disabled = DatosJuego.dinero_total < DatosJuego.PRECIO_CEBO_DORADO


func _al_comprar_fuerza() -> void:
	if DatosJuego.comprar_fuerza():
		_actualizar_ui()


func _al_comprar_carrete() -> void:
	if DatosJuego.comprar_carrete():
		_actualizar_ui()


func _al_comprar_carrete_auto() -> void:
	if DatosJuego.comprar_potenciador("carrete_auto"):
		_actualizar_ui()


func _al_comprar_tiempo_extra() -> void:
	if DatosJuego.comprar_potenciador("tiempo_extra"):
		_actualizar_ui()


func _al_comprar_cebo_dorado() -> void:
	if DatosJuego.comprar_potenciador("cebo_dorado"):
		_actualizar_ui()


func _al_siguiente_nivel() -> void:
	DatosJuego.avanzar_nivel()
	get_tree().change_scene_to_file("res://escenas/juego_principal.tscn")


func _al_volver_menu() -> void:
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")
