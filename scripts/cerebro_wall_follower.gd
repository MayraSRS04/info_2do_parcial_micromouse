class_name CerebroWallFollower
extends RefCounted

# Cerebro de demostración: seguidor de pared izquierda. Ejecuta UNA acción por
# paso (girar O avanzar), que es el contrato de todos los cerebros.
#
# Sirve para ver el proyecto funcionando y entender la API del ratón, pero es
# un mal micromouse: en el laberinto 01 (perfecto, sin ciclos) llega a la
# meta; en los laberintos 02 y 03 (con ciclos y meta en el centro, como en la
# competencia real) puede dar vueltas PARA SIEMPRE. Ese es exactamente el
# motivo por el que la mecánica M1 te pide exploración con flood-fill.

# Tras girar hacia una abertura hay que avanzar en el paso siguiente (si se
# vuelve a aplicar la regla, el ratón gira de nuevo hacia donde vino y queda
# en un bucle de dos celdas).
var _giro_pendiente := false


func paso(raton: Raton) -> void:
	if _giro_pendiente:
		_giro_pendiente = false
		if raton.avanzar():
			return
	if not raton.pared_izquierda():
		raton.girar_izquierda()
		_giro_pendiente = true
	elif not raton.pared_frente():
		raton.avanzar()
	elif not raton.pared_derecha():
		raton.girar_derecha()
		_giro_pendiente = true
	else:
		# callejón sin salida: media vuelta (en dos pasos, sin avance forzado)
		raton.girar_derecha()
