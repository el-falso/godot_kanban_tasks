@tool
extends VBoxContainer

## The visual representation of a kanban board.


const __Singletons := preload("res://addons/kanban_tasks/plugin_singleton/singletons.gd")
const __Shortcuts := preload("res://addons/kanban_tasks/view/shortcuts.gd")
const __EditContext := preload("res://addons/kanban_tasks/view/edit_context.gd")
const __BoardData := preload("res://addons/kanban_tasks/data/board.gd")
const __StageScript := preload("res://addons/kanban_tasks/view/stage/stage.gd")
const __StageScene := preload("res://addons/kanban_tasks/view/stage/stage.tscn")

var board_data: __BoardData

@onready var search_bar: LineEdit = $%SearchBar
@onready var button_advanced_search: Button = $%AdvancedSearch
@onready var button_settings: Button = $%Help
@onready var button_help: Button = $%Settings
@onready var column_holder: HBoxContainer = $%ColumnHolder


func _ready():
	update()
	board_data.layout.changed.connect(update)

	search_bar.text_changed.connect(__on_filter_changed)
	search_bar.text_submitted.connect(__on_filter_entered)
	button_advanced_search.toggled.connect(__on_filter_changed)

	notification(NOTIFICATION_THEME_CHANGED)


func _shortcut_input(event: InputEvent) -> void:
	if not __Shortcuts.should_handle_shortcut(self):
		return
	var shortcuts: __Shortcuts = __Singletons.instance_of(__Shortcuts, self)
	if not event.is_echo() and event.is_pressed():
		if shortcuts.search.matches_event(event):
			search_bar.grab_focus()
			get_viewport().set_input_as_handled()
		elif shortcuts.undo.matches_event(event):
			__Singletons.instance_of(__EditContext, self).undo_redo.undo()
			get_viewport().set_input_as_handled()
		elif shortcuts.redo.matches_event(event):
			__Singletons.instance_of(__EditContext, self).undo_redo.redo()
			get_viewport().set_input_as_handled()


func _notification(what):
	match(what):
		NOTIFICATION_THEME_CHANGED:
			if is_instance_valid(search_bar):
				search_bar.right_icon = get_theme_icon(&"Search", &"EditorIcons")
			if is_instance_valid(button_settings):
				button_settings.icon = get_theme_icon(&"Tools", &"EditorIcons")
			if is_instance_valid(button_help):
				button_help.icon = get_theme_icon(&"Help", &"EditorIcons")
			if is_instance_valid(button_advanced_search):
				button_advanced_search.icon = get_theme_icon(&"FileList", &"EditorIcons")


func update() -> void:
	for column in column_holder.get_children():
		column.queue_free()

	for column_data in board_data.layout.columns:
		var column_scroll = ScrollContainer.new()
		column_scroll.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		column_scroll.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		var column = VBoxContainer.new()
		column.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		column.set_h_size_flags(Control.SIZE_EXPAND_FILL)

		column_scroll.add_child(column)
		column_holder.add_child(column_scroll)

		for uuid in column_data:
			var stage := __StageScene.instantiate()
			stage.board_data = board_data
			stage.data_uuid = uuid
			column.add_child(stage)


func reset_filter():
	search_bar.text = ""
	__update_filter()


func __update_filter():
	#for t in tasks:
	#	t.apply_filter(search_bar.text, button_search_details.button_pressed)
	pass

# do not use parameters
# method is bound to diffrent signals
func __on_filter_changed(param1=null):
	__update_filter()

func __on_filter_entered(filter):
	button_advanced_search.grab_focus()

#func __on_documentation_button_clicked():
#	show_documentation()

#func __on_settings_button_clicked():
#	show_settings()
