extends Area2D


export var eye_initial_height = 235;
export var initial_eye_position: Vector2;
var initial_scale = eye_initial_height / 235.0;
var last_blink = OS.get_unix_time();
var _open = true;
var _closed = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	$EyeSprite.animation = 'open';
	self.scale = Vector2(initial_scale, initial_scale);
	self.initial_eye_position = self.position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# Debug
#	if Input.is_action_just_released('left_click'):
#		if (OS.get_unix_time() - last_blink > 0.05 or
#		$AnimationPlayer.get_queue().size() <= 2):
#			self.blink(0.3);
#			last_blink = OS.get_unix_time();


func blink(duration: float):
	$AnimationPlayer.playback_speed = 0.5 / duration;
	$AnimationPlayer.queue('blink');


func close(duration: float):
	if not self._closed:
		$AnimationPlayer.stop();
		$AnimationPlayer.playback_speed = 1 / duration;
		$AnimationPlayer.play('close');
		self._closed = true;
		self._open = false;


func open(duration: float):
	if not self._open:
		$AnimationPlayer.playback_speed = 1 / duration;
		var animation = $AnimationPlayer.get_animation('open');
		var track_scale = animation.find_track('.:scale');
		animation.track_set_key_value(track_scale, 0, self.scale);
		$AnimationPlayer.stop();
		$AnimationPlayer.play('open');
		self._open = true;
		self._closed = false;
