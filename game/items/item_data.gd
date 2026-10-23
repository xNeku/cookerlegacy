class_name ItemData
extends Resource
## Un tipo de cosa que va al almacén: carne de rata, huesos, pescado, verdura...
## Cada uno es un .tres en game/items/data/.

## Nombre interno único (no lo cambies una vez usado: es la clave en el almacén y el guardado).
@export var id: StringName
## Nombre que ve el jugador.
@export var display_name: String = ""
## Icono (16×16).
@export var icon: Texture2D
## Color de su brillo y estela al volar al almacén.
@export var color: Color = Color.WHITE
