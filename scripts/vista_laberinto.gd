class_name VistaLaberinto
extends Node2D

# Dibuja un Laberinto con _draw(): rejilla tenue, paredes, inicio y metas.
#
# La "vista de dios" (el laberinto real completo) ya viene configurada desde
# game.gd. Para la mecánica M2 puedes reutilizar esta misma clase sobre el
# nodo "vista_mapa_raton": mantén un Laberinto.vacio() con las paredes que tu
# cerebro va descubriendo, llama configurar() una vez y queue_redraw() cada
# vez que aprendas algo. Lo que esta vista NO hace (y te toca a ti) es
# distinguir celdas visitadas / no visitadas — puedes extender esta clase o
# dibujar encima desde otro nodo.

var laberinto: Laberinto = null
var origen := Vector2.ZERO
var tam := 32.0
var celdas_visitadas: Array[Vector2i] = []
var ruta_exploracion: Array[Vector2i] = []
var ruta_speed: Array[Vector2i] = []

@export var color_paredes := Color(0.92, 0.92, 0.95)
@export var color_rejilla := Color(0.22, 0.22, 0.28)
@export var color_meta := Color(0.25, 0.65, 0.30, 0.45)
@export var color_inicio := Color(0.25, 0.45, 0.85, 0.45)
@export var color_visitada := Color(0.95, 0.80, 0.25, 0.20)
@export var color_ruta_exploracion := Color(0.95, 0.55, 0.20, 0.85)
@export var color_ruta_speed := Color(0.30, 0.90, 0.60, 0.95)
@export var grosor_pared := 3.0
@export var grosor_ruta := 4.0


func configurar(laberinto_: Laberinto, origen_: Vector2, tam_: float) -> void:
	laberinto = laberinto_
	origen = origen_
	tam = tam_
	queue_redraw()


func actualizar_progreso(visitadas_: Array[Vector2i], ruta_exploracion_: Array[Vector2i],
		ruta_speed_: Array[Vector2i]) -> void:
	celdas_visitadas = visitadas_
	ruta_exploracion = ruta_exploracion_
	ruta_speed = ruta_speed_
	queue_redraw()


func celda_a_pixel(celda: Vector2i) -> Vector2:
	# centro de la celda en píxeles
	return origen + (Vector2(celda) + Vector2(0.5, 0.5)) * tam


func _draw() -> void:
	if laberinto == null:
		return
	# rejilla tenue de fondo
	for col in laberinto.ancho + 1:
		draw_line(origen + Vector2(col * tam, 0),
				origen + Vector2(col * tam, laberinto.alto * tam), color_rejilla, 1.0)
	for fila in laberinto.alto + 1:
		draw_line(origen + Vector2(0, fila * tam),
				origen + Vector2(laberinto.ancho * tam, fila * tam), color_rejilla, 1.0)
	for celda in celdas_visitadas:
		draw_rect(Rect2(origen + Vector2(celda) * tam, Vector2(tam, tam)), color_visitada)
	# inicio y metas
	var rect_inicio = Rect2(origen + Vector2(laberinto.inicio) * tam, Vector2(tam, tam))
	draw_rect(rect_inicio, color_inicio)
	for meta in laberinto.metas:
		draw_rect(Rect2(origen + Vector2(meta) * tam, Vector2(tam, tam)), color_meta)
	# paredes
	for fila in laberinto.alto:
		for col in laberinto.ancho:
			var celda = Vector2i(col, fila)
			var esquina = origen + Vector2(celda) * tam
			if laberinto.tiene_pared(celda, Laberinto.NORTE):
				draw_line(esquina, esquina + Vector2(tam, 0), color_paredes, grosor_pared)
			if laberinto.tiene_pared(celda, Laberinto.OESTE):
				draw_line(esquina, esquina + Vector2(0, tam), color_paredes, grosor_pared)
			# bordes sur y este solo en la última fila / columna
			if fila == laberinto.alto - 1 and laberinto.tiene_pared(celda, Laberinto.SUR):
				draw_line(esquina + Vector2(0, tam), esquina + Vector2(tam, tam),
						color_paredes, grosor_pared)
			if col == laberinto.ancho - 1 and laberinto.tiene_pared(celda, Laberinto.ESTE):
				draw_line(esquina + Vector2(tam, 0), esquina + Vector2(tam, tam),
						color_paredes, grosor_pared)

	_dibujar_ruta(ruta_exploracion, color_ruta_exploracion, -grosor_ruta * 0.6)
	_dibujar_ruta(ruta_speed, color_ruta_speed, grosor_ruta * 0.6)

func _dibujar_ruta(ruta: Array[Vector2i], color: Color, desplazamiento: float) -> void:
	if ruta.size() < 2:
		return
	for i in ruta.size() - 1:
		var desde := celda_a_pixel(ruta[i]) + Vector2(desplazamiento, desplazamiento)
		var hasta := celda_a_pixel(ruta[i + 1]) + Vector2(desplazamiento, desplazamiento)
		draw_line(desde, hasta, color, grosor_ruta)
