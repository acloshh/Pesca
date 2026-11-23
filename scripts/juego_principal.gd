class_name JuegoPrincipal
extends Node2D

const ESCENA_CAPTURA := preload("res://escenas/entidad_captura.tscn")
const DURACION_CARRETE_AUTO: float = 10.0
const DURACION_CEBO_DORADO: float = 12.0
const SEGUNDOS_TIEMPO_EXTRA: float = 10.0

const CATALOGO_ENTIDADES := [
	{
		"nombre": "Sardina",
		"textura": preload("res://assets/3 Objects/Catch/1.png"),
		"hframes": 2,
		"escala": 2.0,
		"valor": 20,
		"peso": 0.7,
		"velocidad": 75.0,
		"es_basura": false,
		"profundidad_min": 145.0,
		"profundidad_max": 220.0,
		"peso_prob": 30,
		"nivel_min": 1,
	},
	{
		"nombre": "Pez Dorado",
		"textura": preload("res://assets/3 Objects/Catch/2.png"),
		"hframes": 2,
		"escala": 2.0,
		"valor": 45,
		"peso": 1.1,
		"velocidad": 62.0,
		"es_basura": false,
		"profundidad_min": 165.0,
		"profundidad_max": 265.0,
		"peso_prob": 24,
		"nivel_min": 1,
	},
	{
		"nombre": "Atun",
		"textura": preload("res://assets/3 Objects/Catch/3.png"),
		"hframes": 2,
		"escala": 2.0,
		"valor": 85,
		"peso": 1.8,
		"velocidad": 52.0,
		"es_basura": false,
		"profundidad_min": 210.0,
		"profundidad_max": 320.0,
		"peso_prob": 16,
		"nivel_min": 1,
	},
	{
		"nombre": "Trucha",
		"textura": preload("res://assets/3 Objects/Catch/4.png"),
		"hframes": 2,
		"escala": 2.0,
		"valor": 65,
		"peso": 1.4,
		"velocidad": 68.0,
		"es_basura": false,
		"profundidad_min": 175.0,
		"profundidad_max": 285.0,
		"peso_prob": 18,
		"nivel_min": 1,
	},
	{
		"nombre": "Pez Globo",
		"textura": preload("res://assets/3 Objects/Catch/5.png"),
		"hframes": 2,
		"escala": 1.5,
		"valor": 115,
		"peso": 2.2,
		"velocidad": 42.0,
		"es_basura": false,
		"profundidad_min": 225.0,
		"profundidad_max": 325.0,
		"peso_prob": 14,
		"nivel_min": 2,
	},
	{
		"nombre": "Anguila",
		"textura": preload("res://assets/3 Objects/Catch/7.png"),
		"hframes": 2,
		"escala": 1.5,
		"valor": 130,
		"peso": 1.9,
		"velocidad": 85.0,
		"es_basura": false,
		"profundidad_min": 235.0,
		"profundidad_max": 330.0,
		"peso_prob": 12,
		"nivel_min": 2,
	},
	{
		"nombre": "Pez Espada",
		"textura": preload("res://assets/3 Objects/Catch/8.png"),
		"hframes": 2,
		"escala": 1.5,
		"valor": 170,
		"peso": 2.5,
		"velocidad": 92.0,
		"es_basura": false,
		"profundidad_min": 250.0,
		"profundidad_max": 330.0,
		"peso_prob": 10,
		"nivel_min": 3,
	},
	{
		"nombre": "Tiburon",
		"textura": preload("res://assets/3 Objects/Catch/6.png"),
		"hframes": 2,
		"escala": 1.5,
		"valor": 240,
		"peso": 3.4,
		"velocidad": 58.0,
		"es_basura": false,
		"profundidad_min": 265.0,
		"profundidad_max": 330.0,
		"peso_prob": 8,
		"nivel_min": 3,
	},
	{
		"nombre": "Cofre Tesoro",
		"textura": preload("res://assets/3 Objects/Catch/Chest.png"),
		"hframes": 1,
		"escala": 2.0,
		"valor": 220,
		"peso": 3.2,
		"velocidad": 22.0,
		"es_basura": false,
		"profundidad_min": 285.0,
		"profundidad_max": 332.0,
		"peso_prob": 8,
		"nivel_min": 2,
	},
	{
		"nombre": "Barril",
		"textura": preload("res://assets/3 Objects/Catch/Barrel.png"),
		"hframes": 1,
		"escala": 2.0,
		"valor": 5,
		"peso": 2.6,
		"velocidad": 28.0,
		"es_basura": true,
		"profundidad_min": 190.0,
		"profundidad_max": 330.0,
		"peso_prob": 12,
		"nivel_min": 1,
	},
	{
		"nombre": "Caja Vieja",
		"textura": preload("res://assets/3 Objects/Catch/Box.png"),
		"hframes": 1,
		"escala": 2.0,
		"valor": 5,
		"peso": 2.2,
		"velocidad": 32.0,
		"es_basura": true,
		"profundidad_min": 170.0,
		"profundidad_max": 310.0,
		"peso_prob": 10,
		"nivel_min": 1,
	},
]

@export var max_entidades_activas: int = 12

var meta_dinero: int = 150
var dinero_nivel: int = 0
var tiempo_restante: float = 60.0
var partida_terminada: bool = false
var _nivel_superado: bool = false

var _tiempo_carrete_auto: float = 0.0
var _tiempo_cebo_dorado: float = 0.0

@onready var pescador: Pescador = $Pescador
@onready var contenedor_entidades: Node2D = $ContenedorEntidades
@onready var timer_spawn: Timer = $TimerSpawn
@onready var label_nivel: Label = $HUD/MargenHUD/BarraSuperior/LabelNivel
@onready var label_dinero: Label = $HUD/MargenHUD/BarraSuperior/LabelDinero
@onready var label_tiempo: Label = $HUD/MargenHUD/BarraSuperior/LabelTiempo
@onready var boton_carrete_auto: Button = $HUD/MargenInferior/BarraPotenciadores/BotonCarreteAuto
@onready var boton_tiempo_extra: Button = $HUD/MargenInferior/BarraPotenciadores/BotonTiempoExtra
@onready var boton_cebo_dorado: Button = $HUD/MargenInferior/BarraPotenciadores/BotonCeboDorado
@onready var panel_resultado: PanelContainer = $HUD/PanelResultado
@onready var label_resultado: Label = $HUD/PanelResultado/VBox/LabelResultado
@onready var boton_principal: Button = $HUD/PanelResultado/VBox/BotonPrincipal
@onready var boton_secundario: Button = $HUD/PanelResultado/VBox/BotonSecundario


func _ready() -> void:
	meta_dinero = DatosJuego.obtener_meta_nivel()
	tiempo_restante = DatosJuego.obtener_duracion_nivel()
	dinero_nivel = 0
	partida_terminada = false
	_nivel_superado = false
	_tiempo_carrete_auto = 0.0
	_tiempo_cebo_dorado = 0.0
	panel_resultado.visible = false

	pescador.captura_completada.connect(_al_completar_captura)
	timer_spawn.timeout.connect(_al_generar_entidad)
	boton_carrete_auto.pressed.connect(_activar_carrete_auto)
	boton_tiempo_extra.pressed.connect(_activar_tiempo_extra)
	boton_cebo_dorado.pressed.connect(_activar_cebo_dorado)
	boton_principal.pressed.connect(_al_pulsar_principal)
	boton_secundario.pressed.connect(_al_volver_menu)

	for i in range(6):
		_generar_entidad(true)

	_actualizar_hud()


func _process(delta: float) -> void:
	if partida_terminada:
		return

	_procesar_potenciadores(delta)

	tiempo_restante = maxf(0.0, tiempo_restante - delta)
	_actualizar_hud()

	if tiempo_restante <= 0.0:
		_terminar_partida()


func _procesar_potenciadores(delta: float) -> void:
	if Input.is_action_just_pressed("potenciador_1"):
		_activar_carrete_auto()
	if Input.is_action_just_pressed("potenciador_2"):
		_activar_tiempo_extra()
	if Input.is_action_just_pressed("potenciador_3"):
		_activar_cebo_dorado()

	if _tiempo_carrete_auto > 0.0:
		_tiempo_carrete_auto = maxf(0.0, _tiempo_carrete_auto - delta)
		pescador.carrete_automatico_activo = _tiempo_carrete_auto > 0.0

	if _tiempo_cebo_dorado > 0.0:
		_tiempo_cebo_dorado = maxf(0.0, _tiempo_cebo_dorado - delta)


func _activar_carrete_auto() -> void:
	if partida_terminada or _tiempo_carrete_auto > 0.0:
		return
	if DatosJuego.cant_carrete_auto <= 0:
		return
	DatosJuego.cant_carrete_auto -= 1
	_tiempo_carrete_auto = DURACION_CARRETE_AUTO
	pescador.carrete_automatico_activo = true
	_actualizar_hud()


func _activar_tiempo_extra() -> void:
	if partida_terminada:
		return
	if DatosJuego.cant_tiempo_extra <= 0:
		return
	DatosJuego.cant_tiempo_extra -= 1
	tiempo_restante += SEGUNDOS_TIEMPO_EXTRA
	_actualizar_hud()


func _activar_cebo_dorado() -> void:
	if partida_terminada or _tiempo_cebo_dorado > 0.0:
		return
	if DatosJuego.cant_cebo_dorado <= 0:
		return
	DatosJuego.cant_cebo_dorado -= 1
	_tiempo_cebo_dorado = DURACION_CEBO_DORADO
	_actualizar_hud()


func _al_completar_captura(valor_dinero: int, _nombre: String, _es_basura: bool) -> void:
	if partida_terminada:
		return
	var multiplicador := 2 if _tiempo_cebo_dorado > 0.0 else 1
	dinero_nivel += valor_dinero * multiplicador
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
		pos_x = -48.0 if direccion == 1 else 688.0
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
		direccion,
		plantilla["escala"]
	)


func _elegir_entidad_aleatoria() -> Dictionary:
	var disponibles: Array[Dictionary] = []
	var total := 0
	for item in CATALOGO_ENTIDADES:
		if DatosJuego.nivel_actual >= item["nivel_min"]:
			disponibles.append(item)
			total += item["peso_prob"]

	var tirada := randi_range(1, maxi(1, total))
	var acumulado := 0
	for item in disponibles:
		acumulado += item["peso_prob"]
		if tirada <= acumulado:
			return item
	return CATALOGO_ENTIDADES[0]


func _actualizar_hud() -> void:
	label_nivel.text = "Nivel %d" % DatosJuego.nivel_actual
	label_dinero.text = "Meta: $%d / $%d  |  Banco: $%d" % [dinero_nivel, meta_dinero, DatosJuego.dinero_total]
	label_tiempo.text = "Tiempo: %02d" % ceili(tiempo_restante)

	if _tiempo_carrete_auto > 0.0:
		boton_carrete_auto.text = "[1] Auto (%.0fs)" % ceilf(_tiempo_carrete_auto)
		boton_carrete_auto.disabled = true
	else:
		boton_carrete_auto.text = "[1] Auto (%d)" % DatosJuego.cant_carrete_auto
		boton_carrete_auto.disabled = DatosJuego.cant_carrete_auto <= 0

	boton_tiempo_extra.text = "[2] +10s (%d)" % DatosJuego.cant_tiempo_extra
	boton_tiempo_extra.disabled = DatosJuego.cant_tiempo_extra <= 0

	if _tiempo_cebo_dorado > 0.0:
		boton_cebo_dorado.text = "[3] x2$ (%.0fs)" % ceilf(_tiempo_cebo_dorado)
		boton_cebo_dorado.disabled = true
	else:
		boton_cebo_dorado.text = "[3] x2$ (%d)" % DatosJuego.cant_cebo_dorado
		boton_cebo_dorado.disabled = DatosJuego.cant_cebo_dorado <= 0


func _terminar_partida() -> void:
	partida_terminada = true
	timer_spawn.stop()
	pescador.detener_por_fin_nivel()
	pescador.carrete_automatico_activo = false

	_nivel_superado = dinero_nivel >= meta_dinero
	if _nivel_superado:
		DatosJuego.dinero_total += dinero_nivel
		label_resultado.text = "¡NIVEL %d SUPERADO!\nGanado: $%d (Meta: $%d)\nBanco total: $%d" % [
			DatosJuego.nivel_actual,
			dinero_nivel,
			meta_dinero,
			DatosJuego.dinero_total,
		]
		boton_principal.text = "Continuar a la Tienda"
		boton_secundario.text = "Salir al Menú Principal"
	else:
		label_resultado.text = "GAME OVER\nGanado: $%d / $%d" % [dinero_nivel, meta_dinero]
		boton_principal.text = "Reintentar Nivel"
		boton_secundario.text = "Menú Principal"

	panel_resultado.visible = true


func _al_pulsar_principal() -> void:
	if _nivel_superado:
		get_tree().change_scene_to_file("res://escenas/tienda.tscn")
	else:
		get_tree().reload_current_scene()


func _al_volver_menu() -> void:
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")
