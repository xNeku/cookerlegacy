extends CanvasLayer
## HUD de la noche: barra de luna a sol (lo que queda de noche), metros recorridos,
## bichos tumbados y el loot que va llegando al almacén.

@export var run: NightRun
@export var night: NightCycle
## Fila de loot (icono + cantidad).
@export var loot_row_scene: PackedScene
## Color de la barra al empezar y al acercarse el amanecer.
@export var night_color: Color = Color(0.45, 0.55, 0.95)
@export var dawn_color: Color = Color(1.0, 0.7, 0.35)

@onready var _bar: ProgressBar = %NightBar
@onready var _distance: Label = %Distance
@onready var _kills: Label = %Kills
@onready var _loot: VBoxContainer = %LootList

var _rows: Dictionary = {}


func _ready() -> void:
	Storage.item_added.connect(_on_item_added)


func _process(_delta: float) -> void:
	var t := night.get_progress()
	_bar.value = t
	var fill := _bar.get_theme_stylebox(&"fill") as StyleBoxFlat
	if fill:
		fill.bg_color = night_color.lerp(dawn_color, smoothstep(0.55, 1.0, t))
	_distance.text = "%d m" % roundi(run.best_distance)
	_kills.text = str(run.get_kills())


func _on_item_added(item: ItemData, amount: int, _total: int) -> void:
	var row: LootRow = _rows.get(item.id)
	if row == null:
		row = loot_row_scene.instantiate()
		_loot.add_child(row)
		row.setup(item, 0)
		_rows[item.id] = row
	var night_amount := 0
	for entry in Storage.night_loot():
		if entry.item.id == item.id:
			night_amount = entry.amount
	row.bump(night_amount if night_amount > 0 else amount)
