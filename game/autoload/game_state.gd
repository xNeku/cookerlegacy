extends Node
## Autoload "GameState": estado de la partida que sobrevive al cambiar de escena.
## De momento solo el día. (El guardado/carga de Fase 3 vivirá aquí.)

## Al empezar un día nuevo.
signal day_started(day: int)

## Día actual (empieza en 1).
var day: int = 1


## Pasa al día siguiente (al volver del valle).
func next_day() -> void:
	day += 1
	day_started.emit(day)
