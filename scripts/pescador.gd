class_name Pescador
extends Node2D

signal estado_cambiado(nuevo_estado: int)
signal captura_completada(valor_dinero: int, nombre: String, es_basura: bool)

enum EstadoPesca {
	MOVIENDO,
	CARGANDO,
	LANZANDO_AIRE,
	HUNDIENDO,
	RECOGIENDO,
	RETORNANDO,
}

const LIMITE_IZQ_X: float = 48.0
const LIMITE_DER_X: float = 592.0
const VELOCIDAD_MOVIMIENTO: float = 135.0
const VELOCIDAD_CARGA: float = 1.35
const VELOCIDAD_AUTO_REEL: float = 220.0

const TEX_IDLE := preload("res://assets/1 Fisherman/Fisherman_idle.png")
const TEX_ROW := preload("res://assets/1 Fisherman/Fisherman_row.png")
const TEX_FISH := preload("res://assets/1 Fisherman/Fisherman_fish.png")
const TEX_HOOK := preload("res://assets/1 Fisherman/Fisherman_hook.png")

var estado: EstadoPesca = EstadoPesca.MOVIENDO
var direccion_mirada: int = 1
var fuerza_carga: float = 0.0
var carrete_automatico_activo: bool = false

var _fuerza_tapping: float = 20.0
var _velocidad_retorno: float = 260.0
var _direccion_carga: float = 1.0
var _eje_tactil_x: float = 0.0
var _partida_activa: bool = true

var _tiempo_anim: float = 0.0
const INTERVALO_ANIM: float = 0.14

@onready var sprite_pescador: Sprite2D = $SpritePescador
@onready var sprite_bote: Sprite2D = $SpriteBote
@onready var punta_cana: Marker2D = $PuntaCana
@onready var anzuelo: Anzuelo = $Anzuelo
@onready var hilo_pesca: Line2D = $HiloPesca
@onready var barra_carga: ProgressBar = $BarraCarga


func _ready() -> void:
	anzuelo.velocidad_hundimiento = DatosJuego.obtener_velocidad_hundimiento()
	_fuerza_tapping = DatosJuego.obtener_fuerza_tapping()
	_velocidad_retorno = DatosJuego.obtener_velocidad_retorno()

	anzuelo.toco_agua.connect(_al_tocar_agua)
	anzuelo.toco_fondo.connect(_al_tocar_fondo)
	anzuelo.captura_enganchada.connect(_al_enganchar_captura)
	barra_carga.visible = false
	hilo_pesca.visible = false
	_cambiar_estado(EstadoPesca.MOVIENDO)


func establecer_movimiento_tactil(p_eje_x: float) -> void:
	_eje_tactil_x = clampf(p_eje_x, -1.0, 1.0)


func detener_por_fin_nivel() -> void:
	_partida_activa = false
	barra_carga.visible = false


func _physics_process(delta: float) -> void:
	if not _partida_activa:
		return

	match estado:
		EstadoPesca.MOVIENDO:
			_procesar_movimiento(delta)
		EstadoPesca.CARGANDO:
			_procesar_carga(delta)
		EstadoPesca.LANZANDO_AIRE, EstadoPesca.HUNDIENDO:
			anzuelo.actualizar_vuelo_y_hundimiento(delta)
			_actualizar_hilo()
		EstadoPesca.RECOGIENDO:
			_procesar_recogida(delta)
			_actualizar_hilo()
		EstadoPesca.RETORNANDO:
			_procesar_retorno(delta)
			_actualizar_hilo()

	_actualizar_animacion(delta)


func _procesar_movimiento(delta: float) -> void:
	var eje_teclado := Input.get_axis("mover_izquierda", "mover_derecha")
	var eje_total := clampf(eje_teclado + _eje_tactil_x, -1.0, 1.0)

	if absf(eje_total) > 0.05:
		global_position.x = clampf(
			global_position.x + eje_total * VELOCIDAD_MOVIMIENTO * delta,
			LIMITE_IZQ_X,
			LIMITE_DER_X
		)
		var nueva_dir := 1 if eje_total > 0.0 else -1
		if nueva_dir != direccion_mirada:
			direccion_mirada = nueva_dir
			_aplicar_orientacion()

	if Input.is_action_just_pressed("accion_pesca"):
		fuerza_carga = 0.05
		_direccion_carga = 1.0
		barra_carga.value = fuerza_carga * 100.0
		barra_carga.visible = true
		_cambiar_estado(EstadoPesca.CARGANDO)


func _procesar_carga(delta: float) -> void:
	fuerza_carga += _direccion_carga * VELOCIDAD_CARGA * delta
	if fuerza_carga >= 1.0:
		fuerza_carga = 1.0
		_direccion_carga = -1.0
	elif fuerza_carga <= 0.1:
		fuerza_carga = 0.1
		_direccion_carga = 1.0

	barra_carga.value = fuerza_carga * 100.0

	if Input.is_action_just_released("accion_pesca"):
		barra_carga.visible = false
		_lanzar_anzuelo()


func _lanzar_anzuelo() -> void:
	var vx := float(direccion_mirada) * lerpf(70.0, 260.0, fuerza_carga)
	var vy := lerpf(-70.0, -175.0, fuerza_carga)
	anzuelo.lanzar(punta_cana.global_position, Vector2(vx, vy))
	hilo_pesca.visible = true
	_actualizar_hilo()
	_cambiar_estado(EstadoPesca.LANZANDO_AIRE)


func _procesar_recogida(delta: float) -> void:
	if carrete_automatico_activo:
		var completado_auto := anzuelo.actualizar_recogida_automatica(punta_cana.global_position, VELOCIDAD_AUTO_REEL, delta)
		if completado_auto:
			_finalizar_captura()
		return

	if Input.is_action_just_pressed("accion_pesca"):
		var completado := anzuelo.impulsar_recogida(punta_cana.global_position, _fuerza_tapping)
		if completado:
			_finalizar_captura()


func _procesar_retorno(delta: float) -> void:
	if anzuelo.actualizar_retorno_vacio(punta_cana.global_position, _velocidad_retorno, delta):
		anzuelo.reiniciar(punta_cana.global_position)
		hilo_pesca.visible = false
		_cambiar_estado(EstadoPesca.MOVIENDO)


func _finalizar_captura() -> void:
	var captura := anzuelo.captura_actual
	if captura != null:
		captura_completada.emit(captura.valor_dinero, captura.nombre, captura.es_basura)
		captura.queue_free()
	anzuelo.reiniciar(punta_cana.global_position)
	hilo_pesca.visible = false
	_cambiar_estado(EstadoPesca.MOVIENDO)


func _al_tocar_agua() -> void:
	_cambiar_estado(EstadoPesca.HUNDIENDO)


func _al_tocar_fondo() -> void:
	_cambiar_estado(EstadoPesca.RETORNANDO)


func _al_enganchar_captura(_captura: EntidadCaptura) -> void:
	_cambiar_estado(EstadoPesca.RECOGIENDO)


func _aplicar_orientacion() -> void:
	var mirando_izq := direccion_mirada < 0
	sprite_pescador.flip_h = mirando_izq
	sprite_bote.flip_h = mirando_izq
	punta_cana.position.x = absf(punta_cana.position.x) * float(direccion_mirada)


func _actualizar_hilo() -> void:
	hilo_pesca.clear_points()
	hilo_pesca.add_point(hilo_pesca.to_local(punta_cana.global_position))
	hilo_pesca.add_point(hilo_pesca.to_local(anzuelo.global_position))


func _cambiar_estado(nuevo_estado: EstadoPesca) -> void:
	estado = nuevo_estado
	_tiempo_anim = 0.0
	match estado:
		EstadoPesca.MOVIENDO:
			sprite_pescador.texture = TEX_IDLE
			sprite_pescador.hframes = 4
		EstadoPesca.CARGANDO:
			sprite_pescador.texture = TEX_FISH
			sprite_pescador.hframes = 4
		EstadoPesca.LANZANDO_AIRE, EstadoPesca.HUNDIENDO:
			sprite_pescador.texture = TEX_FISH
			sprite_pescador.hframes = 4
		EstadoPesca.RECOGIENDO, EstadoPesca.RETORNANDO:
			sprite_pescador.texture = TEX_HOOK
			sprite_pescador.hframes = 6
	sprite_pescador.frame = 0
	estado_cambiado.emit(estado)


func _actualizar_animacion(delta: float) -> void:
	if estado == EstadoPesca.MOVIENDO:
		var moviendo := absf(Input.get_axis("mover_izquierda", "mover_derecha") + _eje_tactil_x) > 0.05
		var tex_esperada := TEX_ROW if moviendo else TEX_IDLE
		if sprite_pescador.texture != tex_esperada:
			sprite_pescador.texture = tex_esperada
			sprite_pescador.hframes = 4
			sprite_pescador.frame = 0

	_tiempo_anim += delta
	if _tiempo_anim >= INTERVALO_ANIM:
		_tiempo_anim = 0.0
		sprite_pescador.frame = (sprite_pescador.frame + 1) % sprite_pescador.hframes
