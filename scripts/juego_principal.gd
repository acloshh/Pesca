class_name JuegoPrincipal
extends Node2D

const ESCENA_CAPTURA := preload("res://escenas/entidad_captura.tscn")

const CATALOGO_ENTIDADES := [
	{
		"nombre": "Sardina",
		"textura": preload("res://assets/3 Objects/Catch/1.png"),
		"hframes": 2,
		"valor": 20,
		"peso": 0.7,
		"velocidad": 75.0,
		"es_basura": false,
		"profundidad_min": 145.0,
		"profundidad_max": 220.0,
		"peso_prob": 35,
	},
	{
		"nombre": "Pez Dorado",
		"textura": preload("res://assets/3 Objects/Catch/2.png"),
		"hframes": 2,
		"valor": 45,
		"peso": 1.1,
		"velocidad": 60.0,
		"es_basura": false,
		"profundidad_min": 165.0,
		"profundidad_max": 270.0,
		"peso_prob": 25,
	},
	{
		"nombre": "Atun",
		"textura": preload("res://assets/3 Objects/Catch/3.png"),
		"hframes": 2,
		"valor": 90,
		"peso": 2.0,
		"velocidad": 48.0,
		"es_basura": false,
		"profundidad_min": 220.0,
		"profundidad_max": 325.0,
		"peso_prob": 15,
	},
	{
		"nombre": "Barril",
		"textura": preload("res://assets/3 Objects/Catch/Barrel.png"),
		"hframes": 1,
		"valor": 5,
		"peso": 2.6,
		"velocidad": 28.0,
		"es_basura": true,
		"profundidad_min": 190.0,
		"profundidad_max": 330.0,
		"peso_prob": 15,
	},
	{
		"nombre": "Caja Vieja",
		"textura": preload("res://assets/3 Objects/Catch/Box.png"),
		"hframes": 1,
		"valor": 5,
		"peso": 2.2,
		"velocidad": 32.0,
		"es_basura": true,
		"profundidad_min": 170.0,
		"profundidad_max": 310.0,
		"peso_prob": 10,
	},
]

@export var duracion_nivel: float = 60.0
@export var meta_dinero: int = 200
@export var max_entidades_activas: int = 12

var dinero_actual: int = 0
var tiempo_restante: float = 60.0
var partida_terminada: bool = false

@onready var pescador: Pescador = $Pescador
@onready var contenedor_entidades: Node2D = $ContenedorEntidades
@onready var timer_spawn: Timer = $TimerSpawn
@onready var label_dinero: Label = $HUD/MargenHUD/BarraSuperior/LabelDinero
@onready var label_tiempo: Label = $HUD/MargenHUD/BarraSuperior/LabelTiempo
@onready var panel_resultado: PanelContainer = $HUD/PanelResultado
@onready var label_resultado: Label = $HUD/PanelResultado/VBox/LabelResultado
@onready var boton_reintentar: Button = $HUD/PanelResultado/VBox/BotonReintentar


func _ready() -> void:
	tiempo_restante = duracion_nivel
	dinero_actual = 0
	partida_terminada = false
	panel_resultado.visible = false

	pescador.captura_completada.connect(_al_completar_captura)
	timer_spawn.timeout.connect(_al_generar_entidad)
	boton_reintentar.pressed.connect(_al_reintentar)

	for i in range(6):
		_generar_entidad(true)

	_actualizar_hud()


func _process(delta: float) -> void:
	if partida_terminada:
		return

	tiempo_restante = maxf(0.0, tiempo_restante - delta)
	_actualizar_hud()

	if tiempo_restante <= 0.0:
		_terminar_partida()


func _al_completar_captura(valor_dinero: int, _nombre: String, _es_basura: bool) -> void:
	if partida_terminada:
		return
	dinero_actual += valor_dinero
	_actualizar_hud()


func _al_generar_entidad() -> void:
	if partida_terminada:
		return
	if contenedor_entidades.get_child_count() >= max_entidades_activas:
		return
	_generar_entidad(false)


func _generar_entidad(posicion_inicial_en_pantalla: bool) -> void:
	var plantilla := _elegir_entidad_aleatoria()
	var entidad := ESCENA_CAPTURA.instantiate() as EntidadCaptura
	var direccion := 1 if randf() < 0.5 else -1
	var pos_x: float
	if posicion_inicial_en_pantalla:
		pos_x = randf_range(60.0, 580.0)
	else:
		pos_x = -36.0 if direccion == 1 else 676.0
	var pos_y := randf_range(plantilla["profundidad_min"], plantilla["profundidad_max"])

	entidad.global_position = Vector2(pos_x, pos_y)
	contenedor_entidades.add_child(entidad)
	entidad.configurar(
		plantilla["textura"],
		plantilla["hframes"],
		plantilla["nombre"],
		plantilla["valor"],
		plantilla["peso"],
		plantilla["velocidad"],
		plantilla["es_basura"],
		direccion
	)


func _elegir_entidad_aleatoria() -> Dictionary:
	var total := 0
	for item in CATALOGO_ENTIDADES:
		total += item["peso_prob"]
	var tirada := randi_range(1, total)
	var acumulado := 0
	for item in CATALOGO_ENTIDADES:
		acumulado += item["peso_prob"]
		if tirada <= acumulado:
			return item
	return CATALOGO_ENTIDADES[0]


func _actualizar_hud() -> void:
	label_dinero.text = "Dinero: $%d / $%d" % [dinero_actual, meta_dinero]
	label_tiempo.text = "Tiempo: %02d" % ceili(tiempo_restante)


func _terminar_partida() -> void:
	partida_terminada = true
	timer_spawn.stop()
	pescador.detener_por_fin_nivel()
	if dinero_actual >= meta_dinero:
		label_resultado.text = "¡NIVEL SUPERADO!\n$%d / $%d" % [dinero_actual, meta_dinero]
	else:
		label_resultado.text = "TIEMPO AGOTADO\n$%d / $%d" % [dinero_actual, meta_dinero]
	panel_resultado.visible = true


func _al_reintentar() -> void:
	get_tree().reload_current_scene()
