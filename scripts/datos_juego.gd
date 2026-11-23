extends Node

const MAX_NIVEL_MEJORA: int = 5

const PRECIO_CARRETE_AUTO: int = 60
const PRECIO_TIEMPO_EXTRA: int = 50
const PRECIO_CEBO_DORADO: int = 70

var nivel_actual: int = 1
var dinero_total: int = 0

var nivel_fuerza: int = 0
var nivel_carrete: int = 0

var cant_carrete_auto: int = 1
var cant_tiempo_extra: int = 1
var cant_cebo_dorado: int = 1


func reiniciar_partida() -> void:
	nivel_actual = 1
	dinero_total = 0
	nivel_fuerza = 0
	nivel_carrete = 0
	cant_carrete_auto = 1
	cant_tiempo_extra = 1
	cant_cebo_dorado = 1


func avanzar_nivel() -> void:
	nivel_actual += 1


func obtener_meta_nivel() -> int:
	return 150 + (nivel_actual - 1) * 120


func obtener_duracion_nivel() -> float:
	return 60.0


func obtener_fuerza_tapping() -> float:
	return 20.0 + float(nivel_fuerza) * 5.0


func obtener_velocidad_hundimiento() -> float:
	return 100.0 + float(nivel_carrete) * 22.0


func obtener_velocidad_retorno() -> float:
	return 260.0 + float(nivel_carrete) * 40.0


func obtener_costo_fuerza() -> int:
	return 80 * (nivel_fuerza + 1)


func obtener_costo_carrete() -> int:
	return 90 * (nivel_carrete + 1)


func comprar_fuerza() -> bool:
	if nivel_fuerza >= MAX_NIVEL_MEJORA:
		return false
	var costo := obtener_costo_fuerza()
	if dinero_total < costo:
		return false
	dinero_total -= costo
	nivel_fuerza += 1
	return true


func comprar_carrete() -> bool:
	if nivel_carrete >= MAX_NIVEL_MEJORA:
		return false
	var costo := obtener_costo_carrete()
	if dinero_total < costo:
		return false
	dinero_total -= costo
	nivel_carrete += 1
	return true


func comprar_potenciador(tipo: String) -> bool:
	match tipo:
		"carrete_auto":
			if dinero_total < PRECIO_CARRETE_AUTO:
				return false
			dinero_total -= PRECIO_CARRETE_AUTO
			cant_carrete_auto += 1
			return true
		"tiempo_extra":
			if dinero_total < PRECIO_TIEMPO_EXTRA:
				return false
			dinero_total -= PRECIO_TIEMPO_EXTRA
			cant_tiempo_extra += 1
			return true
		"cebo_dorado":
			if dinero_total < PRECIO_CEBO_DORADO:
				return false
			dinero_total -= PRECIO_CEBO_DORADO
			cant_cebo_dorado += 1
			return true
	return false
