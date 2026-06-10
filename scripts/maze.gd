class_name Laberinto
extends RefCounted

# Representación de un laberinto micromouse y cargador del formato .maz de texto:
#
#   o---o---o
#   |   | G |
#   o   o---o
#   | S     |
#   o---o---o
#
# 'o' postes, '---' pared horizontal, '|' pared vertical, 'S' inicio, 'G' meta(s).
# La fila 0 es la de ARRIBA (igual que en el archivo); el inicio clásico queda
# en la esquina inferior izquierda.

# Direcciones (índices 0..3, en sentido horario). El bit de pared es 1 << dir.
enum { NORTE, ESTE, SUR, OESTE }

# Desplazamiento de celda por dirección, indexado por NORTE..OESTE.
const DELTAS = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const NOMBRES_DIR = ["N", "E", "S", "O"]

var ancho: int = 0
var alto: int = 0
var inicio: Vector2i = Vector2i.ZERO
var metas: Array[Vector2i] = []
# paredes[fila][columna] -> máscara de bits (1 << NORTE | 1 << ESTE | ...)
var _paredes: Array = []


static func desde_archivo(ruta: String) -> Laberinto:
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo abrir el laberinto: " + ruta)
		return null
	var lineas: Array[String] = []
	while not archivo.eof_reached():
		var linea = archivo.get_line()
		if linea.strip_edges() != "":
			lineas.append(linea)
	return desde_lineas(lineas)


static func desde_lineas(lineas: Array[String]) -> Laberinto:
	var lab = Laberinto.new()
	lab.alto = (lineas.size() - 1) / 2
	lab.ancho = (lineas[0].length() - 1) / 4
	for fila in lab.alto:
		var fila_paredes = []
		fila_paredes.resize(lab.ancho)
		fila_paredes.fill(0)
		lab._paredes.append(fila_paredes)

	for fila in lab.alto:
		var linea_horizontal = lineas[fila * 2]
		var linea_vertical = lineas[fila * 2 + 1]
		for col in lab.ancho:
			if linea_horizontal[col * 4 + 1] == "-":
				lab.poner_pared(Vector2i(col, fila), NORTE)
			if linea_vertical[col * 4] == "|":
				lab.poner_pared(Vector2i(col, fila), OESTE)
			var contenido = linea_vertical[col * 4 + 2]
			if contenido == "S":
				lab.inicio = Vector2i(col, fila)
			elif contenido == "G":
				lab.metas.append(Vector2i(col, fila))
		if linea_vertical[lab.ancho * 4] == "|":
			lab.poner_pared(Vector2i(lab.ancho - 1, fila), ESTE)
	# pared sur del borde inferior
	var ultima = lineas[lab.alto * 2]
	for col in lab.ancho:
		if ultima[col * 4 + 1] == "-":
			lab.poner_pared(Vector2i(col, lab.alto - 1), SUR)
	return lab


# Laberinto sin paredes internas (solo el borde exterior). Útil para que el
# ratón mantenga su propio mapa de paredes DESCUBIERTAS (mecánica M2).
static func vacio(ancho_: int, alto_: int) -> Laberinto:
	var lab = Laberinto.new()
	lab.ancho = ancho_
	lab.alto = alto_
	for fila in alto_:
		var fila_paredes = []
		fila_paredes.resize(ancho_)
		fila_paredes.fill(0)
		lab._paredes.append(fila_paredes)
	for col in ancho_:
		lab.poner_pared(Vector2i(col, 0), NORTE)
		lab.poner_pared(Vector2i(col, alto_ - 1), SUR)
	for fila in alto_:
		lab.poner_pared(Vector2i(0, fila), OESTE)
		lab.poner_pared(Vector2i(ancho_ - 1, fila), ESTE)
	return lab


func en_rango(celda: Vector2i) -> bool:
	return celda.x >= 0 and celda.x < ancho and celda.y >= 0 and celda.y < alto


func tiene_pared(celda: Vector2i, dir: int) -> bool:
	if not en_rango(celda):
		return true
	return _paredes[celda.y][celda.x] & (1 << dir) != 0


# Marca una pared en ambos lados (la celda y su vecina), como en la realidad.
func poner_pared(celda: Vector2i, dir: int) -> void:
	if not en_rango(celda):
		return
	_paredes[celda.y][celda.x] |= 1 << dir
	var vecina = celda + DELTAS[dir]
	if en_rango(vecina):
		var opuesta = (dir + 2) % 4
		_paredes[vecina.y][vecina.x] |= 1 << opuesta


func es_meta(celda: Vector2i) -> bool:
	return celda in metas
