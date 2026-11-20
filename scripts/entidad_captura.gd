class_name EntidadCaptura
extends Area2D

@export var nombre: String = "Pez"
@export var valor_dinero: int = 25
@export var peso: float = 1.0
@export var velocidad_nado: float = 55.0
@export var es_basura: bool = false

var direccion: int = 1
var enganchado: bool = false

var _tiempo_animacion: float = 0.0
const INTERVALO_FRAME: float = 0.2

@onready var sprite: Sprite2D = $Sprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	monitorable = true
	monitoring = false


func configurar(
	p_textura: Texture2D,
	p_hframes: int,
	p_nombre: String,
	p_valor: int,
	p_peso: float,
	p_velocidad: float,
	p_es_basura: bool,
	p_direccion: int
) -> void:
	nombre = p_nombre
	valor_dinero = p_valor
	peso = p_peso
	velocidad_nado = p_velocidad
	es_basura = p_es_basura
	direccion = 1 if p_direccion >= 0 else -1

	if sprite:
		sprite.texture = p_textura
		sprite.hframes = maxi(1, p_hframes)
		sprite.frame = 0
		sprite.flip_h = direccion < 0

		if colision and colision.shape is RectangleShape2D and p_textura:
			var ancho_frame := float(p_textura.get_width()) / float(maxi(1, p_hframes))
			var alto_frame := float(p_textura.get_height())
			var forma := colision.shape.duplicate() as RectangleShape2D
			forma.size = Vector2(maxf(8.0, ancho_frame), maxf(6.0, alto_frame))
			colision.shape = forma


func _physics_process(delta: float) -> void:
	if enganchado:
		return

	position.x += float(direccion) * velocidad_nado * delta

	if sprite and sprite.hframes > 1:
		_tiempo_animacion += delta
		if _tiempo_animacion >= INTERVALO_FRAME:
			_tiempo_animacion = 0.0
			sprite.frame = (sprite.frame + 1) % sprite.hframes

	if global_position.x < -80.0 or global_position.x > 720.0:
		queue_free()


func marcar_enganchado() -> void:
	enganchado = true
	set_deferred("monitorable", false)
