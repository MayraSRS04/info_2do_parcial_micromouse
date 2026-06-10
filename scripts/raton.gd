class_name Raton
extends Node2D

# El ratón. Vive en una celda, mira hacia un rumbo (N/E/S/O) y solo puede:
#   - sensar las paredes de SU celda actual: pared_frente/izquierda/derecha()
#   - girar_izquierda() / girar_derecha()
#   - avanzar() una celda (falla y emite "choque" si hay pared)
#
# REGLA DEL PARCIAL: tu cerebro recibe este nodo y SOLO puede usar esta API
# pública. Leer el laberinto real (game.laberinto o _laberinto) desde tu
# cerebro anula las mecánicas M1/M3 — el ratón de verdad no ve a través de
# las paredes. El mapa que construyas debe salir únicamente del sensado.

signal paso_terminado
signal choque

var celda: Vector2i = Vector2i.ZERO
var rumbo: int = Laberinto.NORTE
var pasos: int = 0

var _laberinto: Laberinto = null
var _origen := Vector2.ZERO
var _tam := 32.0
var _rotacion_objetivo := 0.0
var _tween: Tween = null

@export var color := Color(0.95, 0.80, 0.25)
@export var duracion_paso := 0.10


func configurar(laberinto_: Laberinto, origen_: Vector2, tam_: float) -> void:
	_laberinto = laberinto_
	_origen = origen_
	_tam = tam_
	celda = laberinto_.inicio
	rumbo = Laberinto.NORTE
	pasos = 0
	_rotacion_objetivo = 0.0
	position = _celda_a_pixel(celda)
	rotation = 0.0
	queue_redraw()


# --- API de sensado (lo único que tu cerebro debería consultar) ---

func pared_frente() -> bool:
	return _laberinto.tiene_pared(celda, rumbo)


func pared_izquierda() -> bool:
	return _laberinto.tiene_pared(celda, (rumbo + 3) % 4)


func pared_derecha() -> bool:
	return _laberinto.tiene_pared(celda, (rumbo + 1) % 4)


# --- API de movimiento (una acción por paso del cerebro) ---

func girar_izquierda() -> void:
	rumbo = (rumbo + 3) % 4
	_animar_giro(-PI / 2)


func girar_derecha() -> void:
	rumbo = (rumbo + 1) % 4
	_animar_giro(PI / 2)


func avanzar() -> bool:
	if pared_frente():
		choque.emit()
		return false
	celda += Laberinto.DELTAS[rumbo]
	pasos += 1
	_animar_a(_celda_a_pixel(celda))
	return true


func ocupado() -> bool:
	return _tween != null and _tween.is_running()


# --- interno ---

func _celda_a_pixel(celda_: Vector2i) -> Vector2:
	return _origen + (Vector2(celda_) + Vector2(0.5, 0.5)) * _tam


func _animar_a(destino: Vector2) -> void:
	_tween = create_tween()
	_tween.tween_property(self, "position", destino, duracion_paso)
	_tween.tween_callback(func(): paso_terminado.emit())


func _animar_giro(delta_rotacion: float) -> void:
	_rotacion_objetivo += delta_rotacion
	_tween = create_tween()
	_tween.tween_property(self, "rotation", _rotacion_objetivo, duracion_paso)
	_tween.tween_callback(func(): paso_terminado.emit())


func _draw() -> void:
	var r = _tam * 0.32
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -r), Vector2(r * 0.8, r), Vector2(0, r * 0.55), Vector2(-r * 0.8, r),
	]), color)
