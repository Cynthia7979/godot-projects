extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var btn = get_node('Button')
onready var label = get_node('Label')
var seconds = 0
var labelText = "I'm a label!"

# Called when the node enters the scene tree for the first time.
func _ready():
	btn.connect('button_down', self, '_on_Button_button_down')
	btn.connect('button_up', self, '_on_Button_button_up')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	seconds += delta
	label.text = labelText + ' ' + str(int(seconds) % 60)

func _on_Button_button_down():
	labelText = "I'M NOT A LABEL"

func _on_Button_button_up():
	labelText = "I'm a label!"
	
