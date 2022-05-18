extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$Message.text = 'Dodge the Creeps!';

func show_message(text):
	$Message.text = text;
	$Message.show();
	$MessageTimer.start();

func show_game_over():
	show_message('Game Over!');
	yield($MessageTimer, 'timeout');
	# Restart the game
	$Message.text = 'Dodge the Creeps!';
	$Message.show();
	yield(self.get_tree().create_timer(1), 'timeout');
	$StartButton.show();

func update_score(score):
	$ScoreLabel.text = str(score);

func _on_StartButton_pressed():
	$StartButton.hide();
	emit_signal('start_game');

func _on_MessageTimer_timeout():
	$Message.hide();
