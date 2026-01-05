extends Control

var widthInput: SpinBox
var heightInput: SpinBox
var tileEditBrushLabel: Label
var tileEditBrushSlider: HSlider

var selectedTileType

var randomizeSure = false

var width = 0 :
	set (value):
		width = value
		if (widthInput):
			widthInput.value = value
var height = 0 :
	set (value):
		height = value
		if (heightInput):
			heightInput.value = value
var tileEditBrushSize = 1 :
	set (value):
		tileEditBrushSize = value
		tileEditBrushLabel.text = "Tile edit brush size ["+str(value)+"]"
		tileEditBrushSlider.value = value

func _ready() -> void:
	widthInput = $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/MapSizeContainer/MapSize/InputWidth
	heightInput = $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/MapSizeContainer/MapSize/InputHeight
	tileEditBrushLabel = $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/LabelTileEditor
	tileEditBrushSlider = $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/TileEditorSize
	generateTileSelection()
	selectTile(null) # Default tile selected is null

func generateTileSelection():
	for tileType in Classes.TileType:
		var button = Button.new()
		button.text = tileType
		button.name = tileType
		button.connect("button_down", func(): selectTile(tileType))
		$ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/TileEditorContainer/TileEditor.add_child(button)

func selectTile(tileType = null):
	if tileType:
		selectedTileType = Classes.TileType[tileType]
	else:
		selectedTileType = null
	for tileButton: Button in $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/TileEditorContainer/TileEditor.get_children():
		if tileButton.name == tileType or (tileType == null and tileButton.name == 'NULL'):
			# Create a new style look
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.2, 0.2, 0.2) # Dark background
			# Set the border
			style.set_border_width_all(2) # 2px border on all sides
			style.border_color = Color.GOLD # Gold outline
			# Apply it to the 'normal' state
			tileButton.add_theme_stylebox_override("normal", style)
		else:
			tileButton.remove_theme_stylebox_override("normal")

signal sizeChangeApply(width: int, height: int)

signal randomizeMapApply(seedValue: String)

func randomizeMap():
	if !randomizeSure:
		# Ask if sure
		randomizeSure = true
		$ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/RandomizeContainer/RandomizeList/OverwriteWarning.visible = true
	else:
		randomizeSure = false
		$ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/RandomizeContainer/RandomizeList/OverwriteWarning.visible = false
		var seedValue = $ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/RandomizeContainer/RandomizeList/SeedInput.text
		randomizeMapApply.emit(seedValue)

func _on_button_apply_pressed() -> void:
	sizeChangeApply.emit(width, height)

func _on_input_width_value_changed(value: float) -> void:
	width = value

func _on_input_height_value_changed(value: float) -> void:
	height = value

func _on_check_button_toggled(toggled_on: bool) -> void:
	$ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/MapSizeContainer.visible = toggled_on

func _on_null_button_down() -> void:
	selectTile(null)

func _on_tile_editor_toggle_toggled(toggled_on: bool) -> void:
	$ScrollContainer/VBoxContainer/PanelContainer/GridContainer/Menu/TileEditorContainer.visible = toggled_on

func _on_tile_editor_size_value_changed(value: float) -> void:
	tileEditBrushSize = int(value)

func _on_button_pressed() -> void:
	randomizeMap()
