class_name Anzuelo
extends Area2D

signal toco_agua
signal toco_fondo
signal captura_enganchada(captura: EntidadCaptura)

const GRAVEDAD_AIRE: float = 420.0
const LIMITE_IZQ_X: float = 24.0
const LIMITE_DER_X: float = 616.0

@export var superficie_agua_y: float = 120.0
@export var fondo_rio_y: float = 344.0
@export var velocidad_hundimiento: float = 95.0

var velocidad: Vector2 = Vector2.ZERO
var en_aire: bool = false
var en_agua: bool = false
var retornando: bool = false
var captura_actual: EntidadCaptura = null


func _ready() -> void:
	visible = false
	monitoring = false
	monitorable = false
	area_entered.connect(_al_entrar_area)


func reiniciar(p_origen: Vector2) -> void:
	global_position = p_origen
	velocidad = Vector2.ZERO
	en_aire = false
	en_agua = false
	retornando = false
	captura_actual = null
	visible = false
	set_deferred("monitoring", false)


func lanzar(p_origen: Vector2, p_velocidad_inicial: Vector2) -> void:
	global_position = p_origen
	velocidad = p_velocidad_inicial
	en_aire = true
	en_agua = false
	retornando = false
	captura_actual = null
	visible = true
	monitoring = false


func actualizar_vuelo_y_hundimiento(delta: float) -> void:
	if en_aire:
		velocidad.y += GRAVEDAD_AIRE * delta
		global_position += velocidad * delta
		global_position.x = clampf(global_position.x, LIMITE_IZQ_X, LIMITE_DER_X)

		if global_position.y >= superficie_agua_y:
			global_position.y = superficie_agua_y
			velocidad = Vector2(0.0, velocidad_hundimiento)
			en_aire = false
			en_agua = true
			monitoring = true
			toco_agua.emit()
	elif en_agua and not retornando and captura_actual == null:
		global_position.y += velocidad_hundimiento * delta
		if global_position.y >= fondo_rio_y:
			global_position.y = fondo_rio_y
			en_agua = false
			retornando = true
			set_deferred("monitoring", false)
			toco_fondo.emit()


func impulsar_recogida(p_origen: Vector2, p_avance_base: float) -> bool:
	if captura_actual == null:
		return true

	var peso_efectivo := maxf(captura_actual.peso, 0.35)
	var paso := p_avance_base / peso_efectivo
	global_position = global_position.move_toward(p_origen, paso)
	captura_actual.global_position = global_position + Vector2(0.0, 6.0)

	return global_position.distance_to(p_origen) <= 8.0 or global_position.y <= superficie_agua_y - 4.0


func actualizar_retorno_vacio(p_origen: Vector2, p_velocidad_retorno: float, delta: float) -> bool:
	global_position = global_position.move_toward(p_origen, p_velocidad_retorno * delta)
	return global_position.distance_to(p_origen) <= 6.0


func _al_entrar_area(area: Area2D) -> void:
	if captura_actual != null or not en_agua or retornando:
		return
	if area is EntidadCaptura and not area.enganchado:
		captura_actual = area
		captura_actual.marcar_enganchado()
		captura_actual.global_position = global_position + Vector2(0.0, 6.0)
		en_agua = false
		set_deferred("monitoring", false)
		captura_enganchada.emit(captura_actual)
