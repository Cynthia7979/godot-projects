extends Area2D


var screen_resolution;
var screen_radius;
const center = Vector2(300, 300);
const maximum_displacement_length = 70;  # In pixels


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_resolution = self.get_viewport().size;
	screen_radius = sqrt(pow(screen_resolution.x, 2) + pow(screen_resolution.y, 2));
	self.position = self.center;
	$BlinkTimer.wait_time = rand_range(0, 3.0);
	$BlinkTimer.start()


func _process(delta):
	if Input.is_action_just_released("left_click"):
		get_tree().call_group('eye', 'blink', 0.5);
		$BlinkTimer.stop();
		$BlinkTimer.start();


func _input(event):
	if event is InputEventMouseMotion:		
		# We want to keep the eye inside the body
		# Meanwhile move it to a point on a line between the mouse and the origin
		# Depending on how far the mouse is from the origin
		var mouse_pos = event.position - self.center;
		print(mouse_pos);
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
		# No need to add self.center because child's position is already relative.
		$Eyes.position = Vector2(r * cos(direction), r * sin(direction))
		# And it works. Take that you muffin!
		# (28 lines of buggy codes deleted)

func clamp_displacement_length(r):
#	var k = 0.0008;  # Makes it smoother
#	var b = 60;  # Translates the curve horizontally
#	var x_intercept = (1 / (k * maximum_displacement_length)) + b;
#	if r <= x_intercept: return r / 5.0;
#	else:
#		return (1 / (-k * (r - b))) + maximum_displacement_length;
#	# A curve that approaches the maximum length smoothly

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
