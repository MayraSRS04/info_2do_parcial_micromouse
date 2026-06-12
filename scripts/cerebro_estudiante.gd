class_name CerebroEstudiante
extends RefCounted

# === TU CEREBRO (M1, M2, M3) ===
#
# Contrato: game.gd llama paso(raton) en cada tick y tu cerebro ejecuta UNA
# acción (girar_izquierda / girar_derecha / avanzar). Solo puedes usar la API
# pública del ratón — sensar paredes de la celda actual y moverte. Nada de
# leer el laberinto real.
#
# Para activarlo: en el Inspector de la escena game.tscn, marca la casilla
# "Usar Cerebro Estudiante" del nodo raíz (o cambia el valor por defecto en
# game.gd).
#
# Plan sugerido (es el algoritmo clásico de la competencia micromouse):
#
#   FASE 1 — EXPLORAR (M1):
#     - Mantén tu propio mapa: un Laberinto.vacio(ancho, alto) donde anotas
#       (con poner_pared) cada pared que sensas, y un diccionario de celdas
#       visitadas. El ratón conoce su celda y rumbo (raton.celda, raton.rumbo).
#     - Flood-fill: calcula la distancia de CADA celda a la meta inundando
#       desde la meta sobre tu mapa (las celdas no exploradas se asumen sin
#       paredes — por eso se vuelve a calcular cada vez que descubres una).
#     - Muévete siempre hacia la celda vecina accesible con menor distancia.
#     - Cuando llegues a la meta, puedes seguir explorando o volver al inicio.
#
#   FASE 2 — SPEED RUN (M3):
#     - De vuelta en el inicio, calcula la mejor ruta sobre el mapa que
#       DESCUBRISTE (otro flood-fill, esta vez solo por celdas conocidas) y
#       ejecútala sin sensar. Compárala en pantalla con la ruta de exploración.
#
#   El mapa que mantienes aquí es exactamente lo que la vista "mapa del ratón"
#   (M2) debe dibujar: expón tu Laberinto descubierto y tus visitadas para que
#   game.gd se los pase a la vista derecha.

# TODO (PARCIAL · M1): declara aquí tu estado: el mapa descubierto
# (Laberinto.vacio), las celdas visitadas, las distancias del flood-fill y la
# fase actual (EXPLORANDO / VOLVIENDO / SPEED_RUN).

# TODO (PARCIAL · M1): necesitarás saber dónde están la meta y el inicio. El
# tamaño del laberinto, las metas y la celda de inicio son datos "del
# concurso" (se conocen de antemano): game.gd te los entrega en preparar().
# Las PAREDES no.
enum Fase { EXPLORANDO, VOLVIENDO, SPEED_RUN, FIN }

var ancho: int = 0
var alto: int = 0
var metas: Array[Vector2i] = []
var inicio: Vector2i = Vector2i.ZERO
var fase: int = Fase.EXPLORANDO
var mapa_descubierto: Laberinto = null
var visitadas: Dictionary = {}
var visitas: Dictionary = {}
var abiertas: Dictionary = {}
var ruta_exploracion: Array[Vector2i] = []
var ruta_regreso: Array[Vector2i] = []
var ruta_speed: Array[Vector2i] = []
var pasos_exploracion: int = 0
var pasos_speed: int = 0
var finalizo: bool = false
var _speed_inicio_pasos: int = 0


func preparar(ancho_: int, alto_: int, metas_: Array[Vector2i],
		inicio_: Vector2i = Vector2i.ZERO) -> void:
	ancho = ancho_
	alto = alto_
	metas = metas_
	inicio = inicio_
	# TODO (PARCIAL · M1): inicializa tu mapa descubierto y tu estado aquí.
	mapa_descubierto = Laberinto.vacio(ancho, alto)
	mapa_descubierto.inicio = inicio
	mapa_descubierto.metas = _copiar_vector2i(metas)
	visitadas.clear()
	visitas.clear()
	abiertas.clear()
	ruta_exploracion.clear()
	ruta_regreso.clear()
	ruta_speed.clear()
	pasos_exploracion = 0
	pasos_speed = 0
	finalizo = false
	fase = Fase.EXPLORANDO


func paso(raton: Raton) -> void:
	# TODO (PARCIAL · M1): 1) sensa y anota las paredes de la celda actual en
	# tu mapa; 2) recalcula el flood-fill; 3) ejecuta UNA acción hacia la
	# vecina con menor distancia.
	# Mientras no implementes nada, el ratón se queda quieto.
	if finalizo:
		return
	_anotar_paredes(raton)

# TODO (PARCIAL · M1): funciones sugeridas.
# func _anotar_paredes(raton: Raton) -> void:
func _anotar_paredes(raton: Raton) -> void:
	_marcar_visitada(raton.celda)
	var sensores = [
		[raton.rumbo, raton.pared_frente()],
		[(raton.rumbo + 3) % 4, raton.pared_izquierda()],
		[(raton.rumbo + 1) % 4, raton.pared_derecha()],
	]
	for dato in sensores:
		var dir: int = dato[0]
		var hay_pared: bool = dato[1]
		if hay_pared:
			mapa_descubierto.poner_pared(raton.celda, dir)
		else:
			_poner_abierta(raton.celda, dir)
# func _flood_fill(hasta: Array[Vector2i], solo_conocidas: bool) -> Array:
func _flood_fill(hasta: Array, solo_conocidas: bool) -> Dictionary:
	var distancias: Dictionary = {}
	var cola: Array[Vector2i] = []

	for objetivo in hasta:
		if mapa_descubierto.en_rango(objetivo):
			distancias[objetivo] = 0
			cola.append(objetivo)

	var indice: int = 0
	while indice < cola.size():
		var celda: Vector2i = cola[indice]
		indice += 1

		for dir in range(4):
			var vecina: Vector2i = celda + Laberinto.DELTAS[dir]

			if not mapa_descubierto.en_rango(vecina):
				continue

			if mapa_descubierto.tiene_pared(celda, dir):
				continue

			if not distancias.has(vecina):
				distancias[vecina] = int(distancias[celda]) + 1
				cola.append(vecina)

	return distancias

# func _mejor_vecina(desde: Vector2i, distancias: Array) -> int:  # rumbo



# TODO (PARCIAL · M3): cuando termines de explorar y estés en el inicio,
# calcula la ruta del speed run y guárdala para que game.gd la dibuje.
# func ruta_speed_run() -> Array[Vector2i]:
	

func _marcar_visitada(celda: Vector2i) -> void:
	visitadas[celda] = true
	visitas[celda] = int(visitas.get(celda, 0)) + 1


func _poner_abierta(celda: Vector2i, dir: int) -> void:
	var vecina: Vector2i = celda + Laberinto.DELTAS[dir]
	if not mapa_descubierto.en_rango(vecina):
		return
	abiertas[_clave_arista(celda, dir)] = true
	abiertas[_clave_arista(vecina, (dir + 2) % 4)] = true


func _clave_arista(celda: Vector2i, dir: int) -> String:
	return str(celda.x) + "," + str(celda.y) + ":" + str(dir)

func _copiar_vector2i(origen_array: Array) -> Array[Vector2i]:
	var copia: Array[Vector2i] = []
	for celda in origen_array:
		copia.append(celda)
	return copia

func _arista_abierta(celda: Vector2i, dir: int) -> bool:
	return abiertas.has(_clave_arista(celda, dir))
