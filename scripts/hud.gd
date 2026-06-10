extends PanelContainer

# Panel lateral de telemetría. Las etiquetas ya existen; conéctalas a las
# señales de game.gd, por ejemplo en _ready():
#   var game = get_parent().get_parent()   # CanvasLayer -> Game
#   game.pasos_cambiados.connect(update_pasos)
#   game.fase_cambiada.connect(update_fase)

@onready var fase_label: Label = $margen/columna/fase_label
@onready var pasos_label: Label = $margen/columna/pasos_label
@onready var visitadas_label: Label = $margen/columna/visitadas_label
@onready var tiempo_label: Label = $margen/columna/tiempo_label
@onready var record_label: Label = $margen/columna/record_label


func update_fase(nombre: String) -> void:
	# TODO (PARCIAL · B3): refleja la fase actual (EXPLORANDO, SPEED RUN...).
	pass


func update_pasos(pasos: int) -> void:
	# TODO (PARCIAL · B1): refleja los pasos en pasos_label.text.
	pass


func update_visitadas(cantidad: int) -> void:
	# TODO (PARCIAL · B1): refleja las celdas visitadas (y, si quieres, el
	# porcentaje del laberinto explorado).
	pass


func update_tiempo(segundos: float) -> void:
	# TODO (PARCIAL · B1): cronómetro de la corrida.
	pass


func update_record(pasos: int) -> void:
	# TODO (PARCIAL · M4): mejor marca guardada para el laberinto actual.
	pass
