# Micromouse — Segundo Parcial (Infografía I/2026)

Proyecto de Mayra Rosas(77944) y Timothy Kuno(78533) para la pista B (micromouse) del
segundo parcial. Es un fork del proyecto base de la materia, con el cerebro,
la telemetría, las vistas y los extras implementados.

## Cómo correr

Abre esta carpeta en Godot 4.6 y presiona Play (F5). La escena principal es
`scenes/game.tscn`. El nodo `Game` ya tiene activado "Usar Cerebro
Estudiante".

Para cambiar de laberinto hay un selector debajo de los botones del panel de
telemetría — lista automáticamente todo lo que haya en `mazes/`, así que
agregar un `.maz` nuevo a esa carpeta lo hace aparecer sin tocar código.

## Controles

- **Pausa** — pausa/reanuda la corrida.
- **Paso** — avanza un solo tick (solo funciona en pausa, útil para depurar).
- **Vel x1 / x2 / x4** — cicla la velocidad de la simulación.
- **Reiniciar** — recarga la escena desde cero.

## Mecánicas implementadas

**Base**

- Telemetría en vivo: fase, pasos, celdas visitadas (con %) y cronómetro,
  actualizados cada tick.
- Controles de pausa, paso a paso, velocidad y reinicio.
- Máquina de estados explícita (EXPLORANDO → VOLVIENDO → SPEED RUN → FIN) con
  pantalla final mostrando el resumen y botón de reinicio.
- Sonidos de paso, choque y meta usando los `.wav` provistos.

**Mecánicas obligatorias**

- Exploración con flood-fill: el cerebro mantiene su propio mapa
  (`Laberinto.vacio()`), lo va llenando con lo que sensa, y se mueve siempre
  hacia la celda vecina con menor distancia a la meta.
- Mapa dual: el panel derecho dibuja lo que el ratón fue descubriendo,
  distinguiendo celdas visitadas de no visitadas.
- Speed run: tras llegar a la meta, el ratón vuelve al inicio y corre la
  mejor ruta sobre lo que descubrió, sin volver a sensar. Ambas rutas
  (exploración y speed run) se dibujan superpuestas.
- Selector de laberintos dinámico + récord persistente por laberinto en
  `user://records.cfg`.

## Extras

- **Juice al chocar**: al recibir la señal `choque`, el ratón hace un flash
  rojo + un pequeño "pop" de escala. En la práctica casi nunca se ve, porque
  el cerebro evita avanzar hacia paredes que ya sensó — lo cual es
  justamente el comportamiento correcto. Se probó disparando la señal
  manualmente desde el árbol remoto de Godot.
- **Ruta óptima real + animación de ola**: al llegar a `FIN`, se corre un
  BFS desde la meta sobre el laberinto real (solo para mostrar, nunca para
  guiar al ratón) y se anima anillo por anillo cómo se expande la búsqueda,
  terminando con la ruta óptima dibujada en dorado. La pantalla final agrega
  "Óptimo real: N pasos" para comparar contra la exploración y el speed run.

## Recursos externos consultados

- Documentación oficial de Godot 4.6: `Tween`, `ConfigFile`, `DirAccess`,
  `CanvasItem.modulate` — https://docs.godotengine.org/en/4.6/
- Wikipedia, artículo de Micromouse, para entender la competencia y el
  algoritmo flood-fill clásico — https://en.wikipedia.org/wiki/Micromouse.
