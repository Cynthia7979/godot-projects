extends Area2D


export var getting_pet = false;
var screen_resolution;
var screen_radius;
var mouse_speed_sequence = [];
var last_mouse_position : Vector2;
var in_idle_mode = false;
const maximum_displacement_length = 70;  # In pixels


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_resolution = self.get_viewport().size;
	screen_radius = sqrt(pow(screen_resolution.x, 2) + pow(screen_resolution.y, 2));
	$BlinkTimer.wait_time = rand_range(0, 3.0);
	$BlinkTimer.start();
	last_mouse_position = get_viewport().get_mouse_position();


func _process(delta):
	var new_mouse_position = get_viewport().get_mouse_position();
	mouse_speed_sequence.append(
		(last_mouse_position - new_mouse_position).length()
	);
	var sequence_of_interest = mouse_speed_sequence.slice(
		mouse_speed_sequence.size()-90, 
		mouse_speed_sequence.size()
	)
	if avg(sequence_of_interest) <= 1:  # No large motions
		if not self.in_idle_mode:
			self.idle_mode(0.3);
			self.in_idle_mode = true;
			self.stop_getting_pet();
	else:
		self.in_idle_mode = false;

	if self.getting_pet and $EyeAnimationPlayer.get_queue().size() < 2:
		$EyeAnimationPlayer.queue("get_pet");
		
	last_mouse_position = new_mouse_position;
	

func _input(event):
	if event is InputEventMouseMotion:
		# I actually don't know why but sometimes it's triggered without
		# moving the mouse
		if last_mouse_position == event.position:
			return;
		# We want to keep the eye inside the body
		# Meanwhile move it to a point on a line between the mouse and the origin
		# Depending on how far the mouse is from the origin
		var mouse_pos = event.position - self.position;
#		print(mouse_pos);
		var distance = mouse_pos.length();
		# First rotate the path we're going to follow
		var direction;
		if mouse_pos.x == 0 and mouse_pos.y == 0:
			$Eyes.position = Vector2.ZERO;
			return;  # No need to move eyes. Return to center.
		if mouse_pos.x > 0:
			# First or fourth quadrant, use atan() directly
			direction = atan(mouse_pos.y / float(mouse_pos.x));
		elif mouse_pos.x < 0:
			# Second or third quadrant, atan() + pi
			direction = atan(mouse_pos.y / float(mouse_pos.x)) + PI;
		elif mouse_pos.x == 0:
			direction = PI / 2.0 if mouse_pos.y > 0 else - PI / 2.0;
		else:  # y == 0
			direction = 0.0 if mouse_pos.x > 0 else 3 * PI / 2.0;
			
		# You know what? Screw that. I'm gonna freaking do it myself.
		var r = clamp_displacement_length(distance);
		$Eyes.position = Vector2(r * cos(direction), r * sin(direction))
		# And it works. Take that you muffin!
		# (28 lines of buggy codes deleted)


func clamp_displacement_length(r):
	# A curve that approaches the maximum length smoothly
	# Plug this into geogebra if you want to configure.
	# No docs here because I hate myself
	return (
		(
			0.65 * maximum_displacement_length * atan(
				0.015 * (r - 100)
			)
		) / (PI / 2) + maximum_displacement_length / 2 - (
			(
				0.65 * maximum_displacement_length * atan(
					0.015 * (0 - 100)
				)
			) / (PI / 2) + maximum_displacement_length / 2
		)
	)


func _on_BlinkTimer_timeout():
	if randi() % 2 == 1:  # Single blink
		get_tree().call_group('eye', 'blink', 0.5);
		$BlinkTimer.wait_time = rand_range(2.0, 5.0);
		$BlinkTimer.start();
	else:  # Double blink
		get_tree().call_group('eye', 'blink', 0.5);
		get_tree().call_group('eye', 'blink', 0.5);
		$BlinkTimer.wait_time = rand_range(3.0, 6.0);
		$BlinkTimer.start();


func idle_mode(animation_length: float):
	print('idle mode triggered. Speed:', 1 / animation_length)
	# Adjust speed of AnimationPlayer to preferred length (seconds)
	# Originall animation duration is 1s
	$EyeAnimationPlayer.set_speed_scale(1 / animation_length);
	reset_eye_return_animation_position();
	# Play the animtaion
	$EyeAnimationPlayer.play("eye_return");


func reset_eye_return_animation_position():
	# Adjust initial position values to current ones
	var animation = $EyeAnimationPlayer.get_animation('eye_return');
	var track_position = animation.find_track('Eyes:position');
	animation.track_set_key_value(track_position, 0, $Eyes.position);
	animation.track_set_key_value(track_position, 1, $Eyes.position * 0.8)
	animation.track_set_key_value(track_position, 2, $Eyes.position * 0.1);


func get_pet():
	$StopGettingPetTimer.stop();
	print('getting pet:', self.getting_pet);
	if not self.getting_pet:
		get_tree().call_group('eye', 'close', 0.5);
		$BlinkTimer.stop();
	self.getting_pet = true;


func stop_getting_pet():
	$EyeAnimationPlayer.stop();
	reset_eye_return_animation_position();
	$EyeAnimationPlayer.play("eye_return");
	get_tree().call_group('eye', 'open', 0.3);
	$BlinkTimer.start();
	self.getting_pet = false;


func _on_Pet_mouse_entered():
	print('ENTER')
	self.get_pet();


func _on_Pet_mouse_exited():
	if self.getting_pet:
		$StopGettingPetTimer.start();


static func avg(l: Array):
	var sum = 0.0;
	for item in l:
		sum += item;
	return sum / float(l.size());


# Very, very ugly implementation
static func abs_(k):
	return abs(k);


# This IS static what do you mean it's non-static
func map(l: Array, f):
	var new_l = [];
	for item in l:
		new_l.append(call(f, item));
	return new_l;

