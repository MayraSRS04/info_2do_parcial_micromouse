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

var juego = null

func _ready() -> void:
	juego = get_parent().get_parent()
	juego.pasos_cambiados.connect(update_pasos)
	juego.visitadas_cambiadas.connect(update_visitadas)
	juego.fase_cambiada.connect(update_fase)
	juego.corrida_terminada.connect(_mostrar_pantalla_final)
	
func _process(_delta: float) -> void:
	if juego != null:
		update_tiempo(juego.tiempo_corrida)

func update_fase(nombre: String) -> void:
	# TODO (PARCIAL · B3): refleja la fase actual (EXPLORANDO, SPEED RUN...).
	fase_label.text = "fase: " + nombre


func update_pasos(pasos: int) -> void:
	# TODO (PARCIAL · B1): refleja los pasos en pasos_label.text.
	pasos_label.text = "pasos: " + str(pasos)


func update_visitadas(cantidad: int) -> void:
	# TODO (PARCIAL · B1): refleja las celdas visitadas (y, si quieres, el
	# porcentaje del laberinto explorado).
	var total: int = juego.laberinto.ancho * juego.laberinto.alto
	var porcentaje := 0.0
	if total > 0:
		porcentaje = 100.0 * cantidad / total
	visitadas_label.text = "visitadas: %d / %d (%.0f%%)" % [cantidad, total, porcentaje]


func update_tiempo(segundos: float) -> void:
	# TODO (PARCIAL · B1): cronómetro de la corrida.
	tiempo_label.text = "tiempo: %.1f s" % segundos


func update_record(pasos: int) -> void:
	# TODO (PARCIAL · M4): mejor marca guardada para el laberinto actual.
	if pasos < 0:
		record_label.text = "récord: —"
	else:
		record_label.text = "récord: %d pasos" % pasos
		
func _mostrar_pantalla_final(exito: bool, pasos_exploracion: int, pasos_speed: int) -> void:
	var capa: CanvasLayer = get_parent()

	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.6)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fondo)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -170
	panel.offset_right = 170
	panel.offset_top = -120
	panel.offset_bottom = 120
	fondo.add_child(panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 24)
	margen.add_theme_constant_override("margin_right", 24)
	margen.add_theme_constant_override("margin_top", 18)
	margen.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 8)
	margen.add_child(columna)

	var titulo := Label.new()
	titulo.text = "¡META ALCANZADA!" if exito else "CORRIDA TERMINADA"
	columna.add_child(titulo)

	var resumen_exploracion := Label.new()
	resumen_exploracion.text = "Exploración: %d pasos" % pasos_exploracion
	columna.add_child(resumen_exploracion)

	var resumen_speed := Label.new()
	resumen_speed.text = "Speed run: %d pasos" % pasos_speed
	columna.add_child(resumen_speed)

	var ahorro := pasos_exploracion - pasos_speed
	var resumen_ahorro := Label.new()
	resumen_ahorro.text = "Ahorro: %d pasos" % ahorro
	columna.add_child(resumen_ahorro)

	var boton_reiniciar := Button.new()
	boton_reiniciar.text = "Reiniciar"
	boton_reiniciar.pressed.connect(juego._on_boton_reiniciar_pressed)
	columna.add_child(boton_reiniciar)
